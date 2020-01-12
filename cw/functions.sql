--- Запрещяем добавлять информации о сериях для фильмов.
CREATE OR REPLACE FUNCTION CheckSerias()
    RETURNS TRIGGER AS $$
BEGIN
    IF NEW.FilmId IN (SELECT FilmId FROM Film WHERE FType = 'series') THEN 
        RETURN NEW;
    ELSE 
        RETURN NULL;
    END IF;
END;
$$ language plpgsql;

CREATE TRIGGER VerifyFilmType 
BEFORE INSERT OR UPDATE ON Series
FOR EACH ROW EXECUTE PROCEDURE CheckSerias();

--- Запрещяем вручать профессиональные награды людям занимающиеся другим родом деятельности 
--- (нельзя вручать актерские награды операторам и наоборот)
CREATE OR REPLACE FUNCTION CheckAwardProfession()
    RETURNS TRIGGER AS $$
DECLARE 
    AwardProfessionId INT;
BEGIN
    SELECT p.ProfessionId INTO AwardProfessionId
    FROM PersonNomination p 
    WHERE p.PNominationId = NEW.PNominationId;
    IF AwardProfessionId IS NULL OR NEW.ProfessionId = AwardProfessionId THEN
        RETURN NEW;
    ELSE 
        RETURN NULL;
    END IF;
END;
$$ language plpgsql;

CREATE TRIGGER VerifyAwardProfession
BEFORE INSERT OR UPDATE ON PersonAward
FOR EACH ROW EXECUTE PROCEDURE CheckAwardProfession();

--- Проверяем что победить в каждой номинации в рамках фестиваля один
CREATE OR REPLACE FUNCTION CheckOneFilmWinner()
    RETURNS TRIGGER AS $$
DECLARE
    CurrentWinners INT;
BEGIN
    IF NEW.Win = False THEN
        RETURN NEW;
    END IF;
    SELECT COUNT(*) INTO CurrentWinners
    FROM FilmAward FA
    WHERE FA.AwardId = NEW.AwardId AND FA.FNominationId = NEW.FNominationId AND FA.Win = True;
    IF CurrentWinners = 0 THEN
        RETURN NEW;
    ELSE 
        RETURN NULL;
    END IF;
END;
$$ language plpgsql;


CREATE TRIGGER VerifyOneFilmAwardWinner
BEFORE INSERT OR UPDATE ON FilmAward
FOR EACH ROW EXECUTE PROCEDURE CheckOneFilmWinner();

--- Тоже для личных наград
CREATE OR REPLACE FUNCTION CheckOnePersonWinner()
    RETURNS TRIGGER AS $$
DECLARE
    CurrentWinners INT;
BEGIN
    IF NEW.Win = False THEN
        RETURN NEW;
    END IF;
    SELECT COUNT(*) INTO CurrentWinners
    FROM PersonAward PA
    WHERE PA.AwardId = NEW.AwardId AND PA.PNominationId = NEW.PNominationId AND PA.Win = True;
    IF CurrentWinners = 0 THEN
        RETURN NEW;
    ELSE 
        RETURN NULL;
    END IF;
END;
$$ language plpgsql;


CREATE TRIGGER VerifyOnePersonAwardWinner
BEFORE INSERT OR UPDATE ON PersonAward
FOR EACH ROW EXECUTE PROCEDURE CheckOnePersonWinner();


--- Получить текущую оценку фильма
CREATE OR REPLACE FUNCTION CurrentFilmScore(FId INT) RETURNS FLOAT
AS $$ 
    SELECT AVG(Score) 
    FROM Score S
    WHERE S.FilmId = FId;
$$ language sql;

--- Получить следующий ключ для таблицы
CREATE OR REPLACE FUNCTION NextKey(KName VARCHAR(50)) RETURNS INT
AS $$
DECLARE
    NextKey INT;
BEGIN
    SELECT MinKey INTO NextKey FROM Keys WHERE Keys.TableName = KName;
    UPDATE Keys SET MinKey = MinKey + 1 WHERE Keys.TableName = KName;
    RETURN NextKey;
END;
$$ language plpgsql;

--- Создать профиль человека в системе
CREATE OR REPLACE FUNCTION CreatePerson(
    FName VARCHAR(100),
    LName VARCHAR(100),
    PMic VARCHAR(100),
    Birthdate DATE,
    PCountry VARCHAR(100)) 
RETURNS INT
AS $$
DECLARE
    PId INT;
    CId INT;
BEGIN
    SELECT * FROM NextKey('Person') INTO PId;
    SELECT CountryId INTO CId FROM Country WHERE Country.CountryName = PCountry;
    INSERT INTO Person
        (PersonId, FirstName,LastName,Birthday,Patronymic, CountryId)
    VALUES
        (PId, FName, LName, Birthdate, PMic, CId);
    RETURN PId;
END;
$$ language plpgsql;

--- Создать профиль фильма в системе 
CREATE OR REPLACE FUNCTION CreateFilm(
    mFilmName VARCHAR(100),
    mReleaseDate DATE,
    mDuration INTERVAL,
    mFType FilmType,
    mSlogan VARCHAR(200),
    mBudget MoneyType,
    mDescription VARCHAR(1000)) 
RETURNS INT
AS $$
DECLARE
    FId INT;
BEGIN
    SELECT * FROM NextKey('Film') INTO FId;
    INSERT INTO Film
        (FilmId,FilmName,ReleaseDate,Duration,FType,Slogan,Budget, Description)
    VALUES
        (FId, mFilmName, mReleaseDate, mDescription, mFType, mSlogan, mBudget, mDescription);
    RETURN FId;
END;
$$ language plpgsql;

--- Добавить новую информацию о сборах.
--- Возвращяет суммарное заработанное количество денег фильмом в конкретной стране или NULL 
--- если пытаемся увеличить сборы в друго валюте
CREATE OR REPLACE FUNCTION UpdateBoxoffice(mFilmId INT,  mCountryId INT, newBoxOffice MoneyType) 
RETURNS MoneyType
AS $$
DECLARE
    CurrentBoxoffice MoneyType;
BEGIN
    SELECT (Income).Qnt, (Income).Currency INTO CurrentBoxoffice
    FROM Boxoffice 
    WHERE FilmId = mFilmId AND CountryId = mCountryId;

    IF NOT FOUND THEN
        INSERT INTO Boxoffice(FilmId, CountryId, Income) VALUES (mFilmId, mCountryId, newBoxOffice);
        RETURN newBoxOffice;
    END IF;

    IF CurrentBoxoffice.Currency = newBoxOffice.Currency THEN
        UPDATE Boxoffice SET Income.Qnt = (Income).Qnt + (newBoxOffice).Qnt 
        WHERE FilmId = mFilmId AND CountryId = mCountryId;
        RETURN ((CurrentBoxoffice).Qnt + (newBoxOffice).Qnt, newBoxOffice.Currency);
    ELSE
        RETURN NULL;
    END IF;
END;
$$ language plpgsql;

--- Добавить оценку фильму 
CREATE OR REPLACE FUNCTION AddScore(mUserId INT, mFilmId INT, mScore FLOAT)
RETURNS VOID
AS $$
BEGIN
    INSERT INTO Score(UserId, FilmId, Score) VALUES (mUserId, mFilmId, mScore)
    ON CONFLICT (UserId, FilmId) DO UPDATE SET Score = mScore;
END;
$$ language plpgsql;

--- Самые лучшие фильмы или сериалы в которых человек принимал участие с оценкой выше 7
CREATE OR REPLACE FUNCTION BestPersonFilms(mPersonId INT, mFilmType FilmType) 
RETURNS Table(FilmName VARCHAR(100), ProfessionName VARCHAR(100), FilmScore FLOAT) 
AS $$
    SELECT FilmName, ProfessionName, FilmScore FROM 
     (SELECT FilmId, FilmName, ProfessionId FROM Film NATURAL JOIN
        (SELECT FilmId, ProfessionId 
        FROM Filmmaker
        WHERE PersonId = mPersonId) AS PF 
    WHERE FType = mFilmType)AS FN
    NATURAL JOIN
    (SELECT FilmId, AVG(Score) AS FilmScore 
     FROM Score  
     GROUP BY FilmId) AS FS
    NATURAL JOIN Film NATURAL JOIN Profession
    WHERE FilmScore > 7
    ORDER BY FilmScore DESC;
$$ language sql;
