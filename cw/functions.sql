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

--- Проверяем что победить в каждой номинации в рамках фестиваля один
CREATE OR REPLACE FUNCTION CheckFilmWinner()
    RETURNS TRIGGER AS $$
DECLARE
    CurrentWinners INT;
    NominationRanking Ranking;
BEGIN
    SELECT (Ranking).RankingType, (Ranking).RankingPositions INTO NominationRanking 
    FROM FilmNomination 
    WHERE FNominationId = NEW.FNominationId;

    IF NominationRanking.RankingPositions <= NEW.Position THEN
        RETURN NULL;
    END IF;

    IF NominationRanking.RankingType = 'ranking_duplicate' 
     OR (NominationRanking.RankingType = 'nomination' AND NEW.Position != 0 AND NominationRanking.RankingPositions > 1) THEN
        RETURN NEW;
    END IF;

    SELECT COUNT(*) INTO CurrentWinners
    FROM FilmAward FA
    WHERE FA.AwardId = NEW.AwardId AND FA.FNominationId = NEW.FNominationId AND FA.Position = NEW.Position;
    
    IF CurrentWinners = 0 THEN
        RETURN NEW;
    ELSE 
        RETURN NULL;
    END IF;
END;
$$ language plpgsql;


CREATE TRIGGER VerifyOneFilmAwardWinner
BEFORE INSERT OR UPDATE ON FilmAward
FOR EACH ROW EXECUTE PROCEDURE CheckFilmWinner();

--- Тоже для личных наград
CREATE OR REPLACE FUNCTION CheckPersonWinner()
    RETURNS TRIGGER AS $$
DECLARE
    CurrentWinners INT;
    NominationRanking Ranking;
BEGIN
    SELECT (Ranking).RankingType, (Ranking).RankingPositions INTO NominationRanking 
    FROM PersonNomination 
    WHERE PNominationId = NEW.PNominationId;

    IF NominationRanking.RankingPositions <= NEW.Position THEN
        RETURN NULL;
    END IF;

    IF NominationRanking.RankingType = 'ranking_duplicate' 
     OR (NominationRanking.RankingType = 'nomination' AND NEW.Position != 0 AND NominationRanking.RankingPositions > 1) THEN
        RETURN NEW;
    END IF;

    SELECT COUNT(*) INTO CurrentWinners
    FROM PersonAward FA
    WHERE FA.AwardId = NEW.AwardId AND FA.PNominationId = NEW.PNominationId AND FA.Position = NEW.Position;
    
    IF CurrentWinners = 0 THEN
        RETURN NEW;
    ELSE 
        RETURN NULL;
    END IF;
END;
$$ language plpgsql;

CREATE TRIGGER VerifyOnePersonAwardWinner
BEFORE INSERT OR UPDATE ON PersonAward
FOR EACH ROW EXECUTE PROCEDURE CheckPersonWinner();

--- Тоже для специальных личных наград
CREATE OR REPLACE FUNCTION CheckSpecialPersonWinner()
    RETURNS TRIGGER AS $$
DECLARE
    CurrentWinners INT;
    NominationRanking Ranking;
BEGIN
    SELECT (Ranking).RankingType, (Ranking).RankingPositions INTO NominationRanking 
    FROM SpecialNomination 
    WHERE SNominationId = NEW.SNominationId;

    IF NominationRanking.RankingPositions <= NEW.Position THEN
        RETURN NULL;
    END IF;

    IF NominationRanking.RankingType = 'ranking_duplicate'
     OR (NominationRanking.RankingType = 'nomination' AND NEW.Position != 0 AND NominationRanking.RankingPositions > 1) THEN
        RETURN NEW;
    END IF;

    SELECT COUNT(*) INTO CurrentWinners
    FROM SpecialAward FA
    WHERE FA.AwardId = NEW.AwardId AND FA.SNominationId = NEW.SNominationId AND FA.Position = NEW.Position;
    
    IF CurrentWinners = 0 THEN
        RETURN NEW;
    ELSE 
        RETURN NULL;
    END IF;
END;
$$ language plpgsql;

CREATE TRIGGER VerifyOneSpecialPersonAwardWinner
BEFORE INSERT OR UPDATE ON SpecialAward
FOR EACH ROW EXECUTE PROCEDURE CheckSpecialPersonWinner();

--- Получить текущую оценку фильма
CREATE OR REPLACE FUNCTION CurrentFilmScore(FId INT) RETURNS Table(FilmScore FLOAT)
AS $$ 
BEGIN
    RETURN QUERY
    SELECT AVG(Score) AS FilmScore
    FROM Score S
    WHERE S.FilmId = FId;
END;
$$ language plpgsql;

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
        (FilmId,FilmName,Duration,FType,Slogan,Budget, Description)
    VALUES
        (FId, mFilmName, mDescription, mFType, mSlogan, mBudget, mDescription);
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
    SELECT FilmName, ProfessionName, AVG(Score) AS FilmScore
    FROM Film NATURAL JOIN Filmmaker NATURAL JOIN Score NATURAL JOIN Profession
    WHERE 
        PersonId = mPersonId AND 
        FType = mFilmType
    GROUP BY FilmId, ProfessionName
    HAVING AVG(Score) > 7
    ORDER BY FilmScore DESC;
$$ language sql;
