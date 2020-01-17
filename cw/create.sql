------------
-- Types --
------------
CREATE DOMAIN PINT AS INT CHECK (VALUE >= 0);

CREATE TYPE Currency as enum (
    'USD',
    'RUB',
    'EUR'
);

CREATE TYPE MoneyType as (
    Qnt NUMERIC(20),
    Currency Currency
);

CREATE TYPE FilmType as enum (
    'film', 
    'series'
);

CREATE TYPE RankingType as enum (
    'nomination',
    'ranking',
    'ranking_duplicate'
);

CREATE TYPE Ranking as (
    RankingType RankingType,
    RankingPositions PINT
);
------------
-- Tables --
------------

CREATE TABLE Country(
    CountryId INT NOT NULL,
    CountryName VARCHAR(100) NOT NULL,
    PRIMARY KEY(CountryId)
);
CREATE INDEX ON Country USING BTREE(CountryName, CountryId);

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
CREATE INDEX ON Person USING BTREE (FirstName, LastName);
CREATE INDEX ON Person USING BTREE (LastName, FirstName);

CREATE TABLE Genre(
    GenreId INT NOT NULL,
    GenreName VARCHAR(100) NOT NULL,
    PRIMARY KEY (GenreId)
);
CREATE INDEX ON Genre USING BTREE(GenreName, GenreId);

CREATE TABLE Film(
    FilmId INT NOT NULL,
    FilmName VARCHAR(100) NOT NULL,
    Duration INTERVAL NOT NULL,
    FType FilmType NOT NULL,
    Slogan VARCHAR(200),
    Budget MoneyType,
    Description TEXT,
    PRIMARY KEY (FilmId)
);
CREATE INDEX ON Film USING BTREE (FilmName);

CREATE TABLE ReleasePlan(
    FilmId INT NOT NULL,
    CountryId INT NOT NULL,
    Date Date NOT NULL,
    PRIMARY KEY (FilmId, CountryId),
    FOREIGN KEY (CountryId) REFERENCES Country(CountryId),
    FOREIGN KEY (FilmId) REFERENCES Film(FilmId)
);
CREATE INDEX ON ReleasePlan USING BTREE (Date);
CREATE INDEX ON ReleasePlan USING HASH (CountryId);
CREATE INDEX ON ReleasePlan USING HASH (FilmId);
CREATE INDEX ON ReleasePlan USING BTREE (CountryId, FilmId, Date);

CREATE TABLE FilmGenre(
    FilmId INT NOT NULL,
    GenreId INT NOT NULL,
    PRIMARY KEY (FilmId, GenreId),
    FOREIGN KEY (FilmId) REFERENCES Film(FilmId),
    FOREIGN KEY (GenreId) REFERENCES Genre(GenreId)
);
CREATE INDEX ON FilmGenre USING HASH (FilmId);
CREATE INDEX ON FilmGenre USING HASH (GenreId);
CREATE INDEX ON FilmGenre USING BTREE (GenreId, FilmId);

CREATE TABLE FilmCountry(
    FilmId INT NOT NULL,
    CountryId INT NOT NULL,
    PRIMARY KEY (FilmId, CountryId),
    FOREIGN KEY (FilmId) REFERENCES Film(FilmId),
    FOREIGN KEY (CountryId) REFERENCES Country(CountryId)
);
CREATE INDEX ON FilmCountry USING HASH (FilmId);
CREATE INDEX ON FilmCountry USING HASH (CountryId);
CREATE INDEX ON FilmCountry USING BTREE (CountryId, FilmId);

CREATE TABLE Score(
    FilmId INT NOT NULL,
    UserId INT NOT NULL,
    Score FLOAT NOT NULL,
    PRIMARY KEY (FilmId, UserId),
    FOREIGN KEY (FilmId) REFERENCES Film(FilmId),
    CHECK (Score BETWEEN 0 AND 10)
);
CREATE INDEX ON Score USING HASH (FilmId);
CREATE INDEX ON Score USING BTREE (FilmId, Score);
CREATE INDEX ON Score USING BTREE (UserId, FilmId, Score);

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
CREATE INDEX ON Series USING BTREE (FilmId, Season);


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
CREATE INDEX ON Boxoffice USING BTREE (CountryId, FilmId);

CREATE TABLE Profession(
    ProfessionId INT NOT NULL,
    ProfessionName VARCHAR(100) NOT NULL,
    PRIMARY KEY (ProfessionId)
);
CREATE INDEX ON Profession USING BTREE (ProfessionName, ProfessionId);

CREATE TABLE Filmmaker(
    FilmId INT NOT NULL,
    PersonId INT NOT NULL,
    ProfessionId INT NOT NULL,
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
CREATE INDEX ON Filmmaker(PersonId, ProfessionId);
CREATE INDEX ON Filmmaker(FilmId, ProfessionId);

CREATE TABLE Character(
    CharacterId INT NOT NULL,
    FilmId INT NOT NULL,
    CharacterName VARCHAR(100) NOT NULL,
    PRIMARY KEY (FilmId, CharacterId),
    FOREIGN KEY (FilmId) REFERENCES Film(FIlmId)
);
CREATE INDEX ON Character USING HASH (FilmId);
CREATE INDEX ON Character(CharacterId, FilmId);

CREATE TABLE FilmmakerCharacter(
    FilmId INT NOT NULL,
    PersonId INT NOT NULL,
    ProfessionId INT NOT NULL,
    CharacterId INT NOT NULL,
    PRIMARY KEY (FilmId, PersonId, ProfessionId, CharacterId),
    FOREIGN KEY (FilmId, PersonId, ProfessionId) REFERENCES Filmmaker(FilmId, PersonId, ProfessionId),
    FOREIGN KEY (FilmId, CharacterId) REFERENCES Character(FilmId, CharacterId)
);
CREATE INDEX ON FilmmakerCharacter USING BTREE (FilmId, CharacterId);
CREATE INDEX ON FilmmakerCharacter USING BTREE (FilmId, PersonId, ProfessionId);

CREATE TABLE AwardingOrg(
    AwardId INT NOT NULL,
    AwardName VARCHAR(100) NOT NULL,
    AwardDate DATE NOT NULL,
    PRIMARY KEY (AwardId)
);
CREATE INDEX ON AwardingOrg USING BTREE (AwardName, AwardId);
CREATE INDEX ON AwardingOrg USING BTREE (AwardDate);

CREATE TABLE FilmNomination(
    FNominationId INT NOT NULL,
    FNominationName VARCHAR(100) NOT NULL,
    Ranking Ranking NOT NULL,
    PRIMARY KEY (FNominationId)
);
CREATE INDEX ON FilmNomination USING BTREE (FNominationName, FNominationId);

CREATE TABLE PersonNomination(
    PNominationId INT NOT NULL,
    PNominationName VARCHAR(100) NOT NULL,
    ProfessionId INT,
    Ranking Ranking NOT NULL,
    PRIMARY KEY (PNominationId, ProfessionId),
    FOREIGN KEY (ProfessionId) REFERENCES Profession(ProfessionId)
);
CREATE INDEX ON PersonNomination USING BTREE (ProfessionId, PNominationId);
CREATE INDEX ON PersonNomination USING BTREE (PNominationName, PNominationId);

CREATE TABLE SpecialNomination(
    SNominationId INT NOT NULL,
    SNominationName VARCHAR(100) NOT NULL,
    Ranking Ranking NOT NULL,
    PRIMARY KEY (SNominationId)
);
CREATE INDEX ON SpecialNomination USING BTREE (SNominationName, SNominationId);

CREATE TABLE FilmAward(
    AwardId INT NOT NULL,
    FNominationId INT NOT NULL,
    FilmId INT NOT NULL,
    Position PINT NOT NULL,
    PRIMARY KEY (AwardId, FNominationId, FilmId),
    FOREIGN KEY (FilmId) REFERENCES Film(FilmId),
    FOREIGN KEY (AwardId) REFERENCES AwardingOrg(AwardId),
    FOREIGN KEY (FNominationId) REFERENCES FilmNomination(FNominationId)
);
CREATE INDEX ON FilmAward USING HASH (FilmId);
CREATE INDEX ON FilmAward USING HASH (AwardId);
CREATE INDEX ON FilmAward USING HASH (FNominationId);
CREATE INDEX ON FilmAward USING BTREE (FilmId, AwardId, FNominationId);

CREATE TABLE PersonAward(
    AwardId INT NOT NULL,
    PNominationId INT NOT NULL,
    FilmId INT NOT NULL,
    PersonId INT NOT NULL,
    ProfessionId INT,
    Position PINT NOT NULL,
    PRIMARY KEY (AwardId, PNominationId, FilmId, PersonId, ProfessionId),
    FOREIGN KEY (FilmId, PersonId, ProfessionId) REFERENCES Filmmaker(FilmId, PersonId, ProfessionId),
    FOREIGN KEY (AwardId) REFERENCES AwardingOrg(AwardId),
    FOREIGN KEY (PNominationId, ProfessionId) REFERENCES PersonNomination(PNominationId, ProfessionId)
);
CREATE INDEX ON PersonAward(FilmId, PersonId, ProfessionId);
CREATE INDEX ON PersonAward USING HASH (AwardId);
CREATE INDEX ON PersonAward USING HASH (PNominationId);
CREATE INDEX ON PersonAward USING BTREE (FilmId, AwardId, FNominationId);
CREATE INDEX ON PersonAward USING BTREE (PersonId, FilmId);

CREATE TABLE SpecialAward(
    AwardId INT NOT NULL,
    SNominationId INT NOT NULL,
    PersonId INT NOT NULL,
    Position PINT NOT NULL,
    PRIMARY KEY (AwardId, SNominationId, PersonId),
    FOREIGN KEY (PersonId) REFERENCES Person(PersonId),
    FOREIGN KEY (AwardId) REFERENCES AwardingOrg(AwardId),
    FOREIGN KEY (SNominationId) REFERENCES SpecialNomination(SNominationId)
);
CREATE INDEX ON SpecialAward USING HASH (PersonId);
CREATE INDEX ON SpecialAward USING HASH (AwardId);
CREATE INDEX ON SpecialAward USING HASH (SNominationId);

CREATE TABLE Keys(
    TableName VARCHAR(50) NOT NULL,
    MinKey INT NOT NULL,
    PRIMARY KEY (TableName)
);
CREATE INDEX ON Keys USING BTREE (TableName, MinKey);
