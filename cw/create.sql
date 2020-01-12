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
CREATE INDEX ON Country USING (CountryName, CountryId);

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
CREATE INDEX ON Person USING HASH (CountryId);

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
CREATE INDEX ON Film USING BTREE(ReleaseDate);

CREATE TABLE FilmGenre(
    FilmId INT NOT NULL,
    GenreId INT NOT NULL,
    PRIMARY KEY (FilmId, GenreId),
    FOREIGN KEY (FilmId) REFERENCES Film(FilmId),
    FOREIGN KEY (GenreId) REFERENCES Genre(GenreId)
);
CREATE INDEX ON FilmGenre USING HASH (FilmId);
CREATE INDEX ON FilmGenre USING HASH (GenreId);

CREATE TABLE FilmCountry(
    FilmId INT NOT NULL,
    CountryId INT NOT NULL,
    PRIMARY KEY (FilmId, CountryId),
    FOREIGN KEY (FilmId) REFERENCES Film(FilmId),
    FOREIGN KEY (CountryId) REFERENCES Country(CountryId)
);
CREATE INDEX ON FilmCountry USING HASH (FilmId);
CREATE INDEX ON FilmCountry USING HASH (CountryId);

CREATE TABLE Score(
    FilmId INT NOT NULL,
    UserId INT NOT NULL,
    Score FLOAT NOT NULL,
    PRIMARY KEY (FilmId, UserId),
    FOREIGN KEY (FilmId) REFERENCES Film(FilmId),
    CHECK (Score BETWEEN 0 AND 10)
);
CREATE INDEX ON Score USING HASH (FilmId);

CREATE TABLE Series(
    FilmId INT NOT NULL,
    Season INT NOT NULL,
    SeriesNo INT NOT NULL,
    SeriesName VARCHAR(100) NOT NULL,
    ReleaseDate DATE NOT NULL,
    PRIMARY KEY (FilmId, Season, SeriesNo),
    FOREIGN KEY (FilmId) REFERENCES Film(FilmId)
);
CREATE INDEX ON Series USING HASH (FilmId);
CREATE INDEX ON Series USING BTREE (ReleaseDate);

CREATE TABLE Boxoffice(
    FilmId INT NOT NULL,
    CountryId INT NOT NULL,
    Income MoneyType NOT NULL,
    PRIMARY KEY (FilmId, CountryId),
    FOREIGN KEY (FilmId) REFERENCES Film(FilmId),
    FOREIGN KEY (CountryId) REFERENCES Country(CountryId)
);
CREATE INDEX ON Boxoffice USING HASH (FilmId);
CREATE INDEX ON Boxoffice USING HASH (CountryId);

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
CREATE INDEX ON Filmmaker USING HASH (FilmId);
CREATE INDEX ON Filmmaker USING HASH (PersonId);
CREATE INDEX ON Filmmaker USING HASH (ProfessionId);
CREATE INDEX ON Filmmaker(PersonId, FilmId);
CREATE INDEX ON Filmmaker(FilmId, PersonId);

CREATE TABLE AwardingOrg(
    AwardId INT NOT NULL,
    AwardName VARCHAR(100) NOT NULL,
    AwardDate DATE NOT NULL,
    PRIMARY KEY (AwardId)
);
CREATE INDEX ON AwardingOrg USING HASH (AwardName);
CREATE INDEX ON AwardingOrg USING BTREE (AwardDate);

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
CREATE INDEX ON PersonNomination USING HASH (ProfessionId);

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
CREATE INDEX ON FilmAward USING HASH (FilmId);
CREATE INDEX ON FilmAward USING HASH (AwardId);
CREATE INDEX ON FilmAward USING HASH (FNominationId);

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
CREATE INDEX ON PersonAward(FilmId, PersonId, ProfessionId);
CREATE INDEX ON PersonAward USING HASH (AwardId);
CREATE INDEX ON PersonAward USING HASH (PNominationId);

CREATE TABLE Keys(
    TableName VARCHAR(50) NOT NULL,
    MinKey INT NOT NULL,
    PRIMARY KEY (TableName)
);