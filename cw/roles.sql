--- Доступ на чтение - всем
GRANT SELECT 
    ON TABLE Person, Country, Genre, Film, FilmGenre, FilmCountry, Score, Series, Boxoffice,
     Profession, Filmmaker, AwardingOrg, FilmNomination, PersonNomination, FilmAward, PersonAward,
     Character, FilmmakerCharacter, SpecialNomination, SpecialAward
    TO Public;

GRANT SELECT 
    ON TopFilms, USATopBoxofficeFilms, SoonRelease, SeriesDuration, MostAwardFilmmakers
    TO Public;

--- Admin
--- Администратор ресурса имеет право изменять все данные
CREATE ROLE Admin;

GRANT SELECT, INSERT, UPDATE
    ON TABLE Person, Country, Genre, Film, FilmGenre, FilmCountry, Score, Series, Boxoffice,
     Profession, Filmmaker, AwardingOrg, FilmNomination, PersonNomination, FilmAward, PersonAward, Keys, 
      Character, FilmmakerCharacter
    TO GROUP Admin;

GRANT EXECUTE 
    ON FUNCTION
     CreatePerson(VARCHAR, VARCHAR, VARCHAR, DATE, VARCHAR), 
     CreateFilm(VARCHAR, INTERVAL, FilmType, VARCHAR, MoneyType, VARCHAR)
    TO GROUP Admin;

--- User
--- Пользователь ресурса. Может выставлять оценки
CREATE ROLE User;

GRANT INSERT, UPDATE
    ON TABLE Score
    TO GROUP User;

GRANT EXECUTE 
    ON FUNCTION 
        AddScore(INT, INT, FLOAT),
        BestPersonFilms(INT, FilmType)
    TO GROUP User;

--- Boxoffice Integrator
--- Интегратор для обновления данных boxoffice
CREATE ROLE BoxofficeIntegrator;

GRANT INSERT, UPDATE
    ON TABLE Score
    TO GROUP BoxofficeIntegrator;

GRANT EXECUTE 
    ON FUNCTION UpdateBoxoffice(INT, INT, MoneyType)
    TO GROUP BoxofficeIntegrator;

--- Film Award
--- Представитель кино-премии. Может обновлять данные о наградах и номинациях
CREATE ROLE FilmAward;

GRANT INSERT, UPDATE
    ON TABLE FilmNomination, PersonNomination, FilmAward, PersonAward, SpecialNomination, SpecialAward
    TO GROUP FilmAward;
