-----------
-- Views --
-----------

--- Топ 250 самых высокооцененных фильмов
CREATE VIEW TopFilms AS 
    SELECT FilmName, AVG(Score) as FilmScore 
    FROM Film NATURAL JOIN Score
    WHERE FType = 'film'
    GROUP BY FilmId 
    ORDER BY FilmScore DESC
    LIMIT 250;

--- Самые прибыльные фильмы в американском прокате за последний год
CREATE VIEW USATopBoxofficeFilms AS 
    SELECT FilmName, Budget, Income AS Boxoffice, (Income).Qnt - (Budget).Qnt AS Profit
    FROM Film F NATURAL JOIN Boxoffice B NATURAL JOIN ReleasePlan RP
    WHERE 
        F.FType = 'film' AND 
        (F.Budget).Currency = 'USD' AND 
        (B.Income).Currency = 'USD' AND
        NOW() - RP.Date < INTERVAL '1 year' AND 
        B.CountryId = 1 AND
        RP.CountryId = 1
    ORDER BY Profit DESC 
    LIMIT 100;

--- Список фильмов и сериалов, которые скоро должны выйти в россии, их жанр и дата выхода
CREATE VIEW SoonRelease AS
    SELECT FilmName, FType, STRING_AGG(concat(GenreName), ', ') AS Genres, Date, CountryId 
    FROM Film NATURAL JOIN ReleasePlan P NATURAL JOIN FilmGenre NATURAL JOIN Genre
    WHERE 
        P.Date > now() AND
        P.Date - now() < INTERVAL '6 month'
    GROUP BY FilmId, Date, CountryId
    ORDER BY Date;

--- Сериалы, количество серий и продолжительность серии
CREATE VIEW SeriesDuration AS 
    SELECT FilmName, COUNT(*) AS Series, Duration
    FROM Film NATURAL JOIN Series
    WHERE 
        FType = 'series' 
    GROUP BY FilmId;
   
--- Продолжительность непрерывного просмотра сериала 
CREATE VIEW TotalSeriesDuration AS 
    SELECT FilmName, (Series * Duration) AS TotalDuration FROM SeriesDuration;

--- Личные и специальные награды челочека 
CREATE VIEW OnlyPersonAward 
AS SELECT AwardId, PersonId, PNominationName as Nomination, Position from PersonAward NATURAL JOIN PersonNomination; 

CREATE VIEW OnlySpecialAward
AS SELECT AwardId, PersonId, SNominationName as Nomination, Position from SpecialAward NATURAL JOIN SpecialNomination; 

CREATE VIEW PersonAwards AS 
    SELECT PersonId, AwardName, Nomination, AwardDate, Position FROM AwardingOrg NATURAL JOIN
        (SELECT * FROM
        (SELECT * FROM OnlyPersonAward) A 
        UNION 
        (SELECT * FROM OnlySpecialAward)) B;

--- Самые титулованные работники киноиндустрии
CREATE VIEW MostAwardFilmmakers AS 
    SELECT FirstName || COALESCE(' ' || LastName, '') AS Name, Count(*) AS Nominations
    FROM Person NATURAL JOIN PersonAwards 
    GROUP BY PersonId
    ORDER BY Nominations DESC;

--- Фильмы собравшие наибольнее количество номинаций на кино-премии
CREATE VIEW OnlyFilms AS 
    SELECT * FROM Film 
    WHERE FType = 'film';

CREATE VIEW FilmByNomination AS 
    SELECT FilmId, AwardId, COUNT(FNominationId) AS Nomination 
        FROM FilmAward
        GROUP BY FilmId, AwardId;

CREATE VIEW BestFilmAward AS
    SELECT FilmId, FilmName, AwardId, Nomination FROM 
    OnlyFilms NATURAL JOIN FilmByNomination WHERE
        (AwardId, Nomination) IN (SELECT AwardId, MAX(Nomination)
        FROM FilmByNomination 
        GROUP BY AwardId); 
