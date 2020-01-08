-----------
-- Views --
-----------

--- Топ 250 самых высокооцененных фильмов
CREATE VIEW TopFilms AS 
    SELECT FilmName, FilmScore 
    FROM Film F LEFT JOIN 
        (SELECT FilmId, AVG(Score) AS FilmScore FROM Score 
        GROUP BY FilmId 
        ORDER BY FilmScore DESC) AS A 
    ON A.FilmId = F.FilmId WHERE F.FType = 'film' LIMIT 250;

--- Самые прибыльные американские фильмы в домашнем прокате за последний год
CREATE VIEW USATopBoxofficeFilms AS 
    SELECT FilmName, Budget, Income AS Boxoffice, (Income).Qnt - (Budget).Qnt AS Profit
    FROM Film F NATURAL JOIN 
        (SELECT FilmId, Income From Boxoffice B WHERE B.CountryId = 1) AS ABO
    WHERE 
        F.FType = 'film' AND 
        (F.Budget).Currency = 'USD' AND 
        NOW() - F.ReleaseDate < INTERVAL '1 year' AND 
        (FilmId, 1) IN (SELECT * FROM FilmCountry)
    ORDER BY Profit DESC LIMIT 100;

--- Список фильмов и сериалов, которые скоро должны выйти, их жанр и дата выхода
CREATE VIEW SoonRelease AS
    SELECT FilmName, FType, Genres, ReleaseDate 
    FROM 
        (SELECT FilmId, FilmName, FType, ReleaseDate
        FROM Film 
        WHERE 
            ReleaseDate > now() AND
            ReleaseDate - now() < INTERVAL '6 month') AS S
        NATURAL JOIN
        (SELECT FilmId, STRING_AGG(concat(GenreName), ', ') AS Genres 
        FROM FilmGenre NATURAL JOIN Genre 
        GROUP BY FilmId) AS G
    ORDER BY ReleaseDate;

--- Сериалы, количество серий и продолжительность непрерывного просмотра
CREATE VIEW SeriesDuration AS 
    SELECT FilmName, Series, (Series * Duration) AS TotalDuration 
    FROM Film NATURAL JOIN 
        (SELECT FilmId, COUNT(*) AS Series FROM Series GROUP BY FilmId) AS D
    WHERE 
        FType = 'series';

--- Самые титулованные работники киноиндустрии
CREATE VIEW MostAwardFilmmakers AS 
    SELECT FirstName || COALESCE(' ' || LastName, '') AS Name, Nominations, Wins, (Nominations + Wins * 2) as Score
    FROM Person NATURAL JOIN 
        (SELECT PersonId, Count(PNominationId) AS Nominations, Sum(CAST(Win as Int)) AS Wins 
        FROM PersonAward 
        GROUP BY PersonId) AS W
    ORDER BY Score DESC;
