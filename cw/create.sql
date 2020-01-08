------------
-- Types --
------------

CREATE TYPE Currency as enum (
    'USD',
    'RUB',
    'EUR'
);

CREATE TYPE MoneyType as (
    Qnt BIGINT,
    Currency Currency
);

CREATE TYPE FilmType as enum (
    'film', 
    'series'
);

------------
-- Tables --
------------

CREATE TABLE Country(
    CountryId INT NOT NULL,
    CountryName VARCHAR(100) NOT NULL,
    PRIMARY KEY(CountryId)
);

CREATE TABLE Person(
    PersonId INT NOT NULL,
    FirstName VARCHAR(100) NOT NULL,
    Birthday DATE NOT NULL,
    LastName VARCHAR(100),
    Patronymic VARCHAR(100),
    CountryId INT,
    PRIMARY KEY (PersonId),
    FOREIGN KEY (CountryId) REFERENCES Country(CountryId)
);

CREATE TABLE Genre(
    GenreId INT NOT NULL,
    GenreName VARCHAR(100) NOT NULL,
    PRIMARY KEY (GenreId)
);

CREATE TABLE Film(
    FilmId INT NOT NULL,
    FilmName VARCHAR(100) NOT NULL,
    ReleaseDate DATE NOT NULL,
    Duration INTERVAL NOT NULL,
    FType FilmType NOT NULL,
    Slogan VARCHAR(200),
    Budget MoneyType,
    Description VARCHAR(1000),
    PRIMARY KEY (FilmId)
);

CREATE TABLE FilmGenre(
    FilmId INT NOT NULL,
    GenreId INT NOT NULL,
    PRIMARY KEY (FilmId, GenreId),
    FOREIGN KEY (FilmId) REFERENCES Film(FilmId),
    FOREIGN KEY (GenreId) REFERENCES Genre(GenreId)
);

CREATE TABLE FilmCountry(
    FilmId INT NOT NULL,
    CountryId INT NOT NULL,
    PRIMARY KEY (FilmId, CountryId),
    FOREIGN KEY (FilmId) REFERENCES Film(FilmId),
    FOREIGN KEY (CountryId) REFERENCES Country(CountryId)
);

CREATE TABLE Score(
    FilmId INT NOT NULL,
    UserId INT NOT NULL,
    Score FLOAT NOT NULL,
    PRIMARY KEY (FilmId, UserId),
    FOREIGN KEY (FilmId) REFERENCES Film(FilmId),
    CHECK (Score BETWEEN 0 AND 10)
);

CREATE TABLE Series(
    FilmId INT NOT NULL,
    Season INT NOT NULL,
    SeriesNo INT NOT NULL,
    SeriesName VARCHAR(100) NOT NULL,
    ReleaseDate DATE NOT NULL,
    PRIMARY KEY (FilmId, Season, SeriesNo),
    FOREIGN KEY (FilmId) REFERENCES Film(FilmId)
);

CREATE TABLE Boxoffice(
    FilmId INT NOT NULL,
    CountryId INT NOT NULL,
    Income MoneyType NOT NULL,
    PRIMARY KEY (FilmId, CountryId),
    FOREIGN KEY (FilmId) REFERENCES Film(FilmId),
    FOREIGN KEY (CountryId) REFERENCES Country(CountryId)
);

CREATE TABLE Profession(
    ProfessionId INT NOT NULL,
    ProfessionName VARCHAR(100) NOT NULL,
    PRIMARY KEY (ProfessionId)
);

CREATE TABLE Filmmaker(
    FilmId INT NOT NULL,
    PersonId INT NOT NULL,
    ProfessionId INT NOT NULL,
    Сharacter VARCHAR(100),
    PRIMARY KEY (FilmId, PersonId, ProfessionId),
    FOREIGN KEY (FilmId) REFERENCES Film(FilmId),
    FOREIGN KEY (PersonId) REFERENCES Person(PersonId),
    FOREIGN KEY (ProfessionId) REFERENCES Profession(ProfessionId)
);

CREATE TABLE AwardingOrg(
    AwardId INT NOT NULL,
    AwardName VARCHAR(100) NOT NULL,
    AwardDate DATE NOT NULL,
    PRIMARY KEY (AwardId)
);

CREATE TABLE FilmNomination(
    FNominationId INT NOT NULL,
    FNominationName VARCHAR(100) NOT NULL,
    PRIMARY KEY (FNominationId)
);

CREATE TABLE PersonNomination(
    PNominationId INT NOT NULL,
    PNominationName VARCHAR(100) NOT NULL,
    ProfessionId INT,
    PRIMARY KEY (PNominationId),
    FOREIGN KEY (ProfessionId) REFERENCES Profession(ProfessionId)
);

CREATE TABLE FilmAward(
    AwardId INT NOT NULL,
    FNominationId INT NOT NULL,
    FilmId INT NOT NULL,
    Win BOOLEAN NOT NULL,
    PRIMARY KEY (AwardId, FNominationId, FilmId),
    FOREIGN KEY (FilmId) REFERENCES Film(FilmId),
    FOREIGN KEY (AwardId) REFERENCES AwardingOrg(AwardId),
    FOREIGN KEY (FNominationId) REFERENCES FilmNomination(FNominationId)
);

CREATE TABLE PersonAward(
    AwardId INT NOT NULL,
    PNominationId INT NOT NULL,
    FilmId INT NOT NULL,
    PersonId INT NOT NULL,
    ProfessionId INT,
    Win BOOLEAN NOT NULL,
    PRIMARY KEY (AwardId, PNominationId, FilmId, PersonId, ProfessionId),
    FOREIGN KEY (FilmId, PersonId, ProfessionId) REFERENCES Filmmaker(FilmId, PersonId, ProfessionId),
    FOREIGN KEY (AwardId) REFERENCES AwardingOrg(AwardId),
    FOREIGN KEY (PNominationId) REFERENCES PersonNomination(PNominationId)
);

CREATE TABLE Keys(
    TableName VARCHAR(50) NOT NULL,
    MinKey INT NOT NULL,
    PRIMARY KEY (TableName)
);