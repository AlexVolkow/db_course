INSERT INTO Country
    (CountryId, CountryName)
VALUES
    (1, 'United States of America (USA)'),
    (2, 'Russia'),
    (3, 'France'),
    (4, 'United Kingdom (UK)'),
    (5, 'Germany');

INSERT INTO Person
    (PersonId,
    FirstName,
    LastName,
    Birthday,
    Patronymic,
    CountryId)
VALUES
    (1, 'Tom', 'Hanks', '1956-07-09', null, 1),
    (2, 'Robert', 'Zemeckis', '1951-05-14', null, 1),
    (3, 'Ramin', 'Djawadi', '1974-07-19', null, 5),
    (4, 'David', 'Benioff', '1970-09-25', null, 1),
    (5, 'D.B', 'Weiss', '1971-06-23', null, 1),
    (6, 'Peter', 'Dinklage', '1969-06-11', null, 1),
    (7, 'Lena', 'Headey', '1973-10-03', null, 4),
    (8, 'Deborah', 'Riley', '1973-05-16', null, 4),
    (9, 'Эльдар', 'Рязанов', '1927-11-18', 'Александрович', 2),
    (10, 'Вадим', 'Алисов', '1941-02-20', 'Валентинович', 2),
    (11, 'Лазарь', 'Милькис', '1923-11-15', 'Наумович', 2),
    (12, 'Лариса', 'Гузеева', '1959-05-23', 'Андреевна', 2),
    (13, 'Никита', 'Михалков', '1945-10-21', 'Сергеевич', 2),
    (14, 'Алиса', 'Фрейндлих', '1934-12-08', 'Брунова', 2);

INSERT INTO Genre
    (GenreId, GenreName)
VALUES
    (1, 'фэнтези'),
    (2, 'драма'),
    (3, 'мелодрама'),
    (4, 'боевик'),
    (5, 'военное'),
    (6, 'детектив');

INSERT INTO Film
    (FilmId,
    FilmName,
    ReleaseDate,
    Duration,
    FType,
    Slogan,
    Budget,
    Description)
VALUES
     (1,
    'Forrest Gump',
    '1994-06-23',
    '142m',
    'film',
    'Мир уже никогда не будет прежним, после того как вы увидите его глазами Форреста Гампа',
     (55000000, 'USD'),
    'От лица главного героя Форреста Гампа, слабоумного безобидного человека с благородным и открытым сердцем, рассказывается история его необыкновенной жизни'
     ),
    (2,
    'Game of Thrones',
    '2011-05-21',
    '55m',
    'series',
    'Победа или смерть',
    null,
    'К концу подходит время благоденствия, и лето, длившееся почти десятилетие, угасает. Вокруг средоточия власти Семи королевств, Железного трона, зреет заговор'
    ),
    (3,
    'Жестокий романс',
    '1984-10-23',
    '137m',
    'film',
    null,
    null,
    'Действие разворачивается на берегу Волги в вымышленном провинциальном городке Бряхимове в 1877-1878 годах.'
    ),
    (4,
    'Knives Out',
    '2019-12-12',
    '130m',
    'film',
    'У каждого свой мотив',
    (40000000, 'USD'),
    null),
    (5,
    'The Lighthouse',
    '2020-05-19',
    '109m',
    'film',
    null,
    (1000000, 'USD'),
    null);
    
INSERT INTO FilmGenre 
    (FilmId, GenreId) 
VALUES 
    (1, 2),
    (1, 4),
    (1, 5),
    (2, 1),
    (2, 2),
    (3, 3),
    (3, 2),
    (4, 6),
    (5, 2),
    (5, 5);

INSERT INTO FilmCountry 
    (FilmId, CountryId) 
VALUES 
    (1, 1),
    (2, 1),
    (2, 4),
    (3, 2),
    (4, 1);

INSERT INTO Series
    (FilmId,
    Season,
    SeriesNo,
    SeriesName,
    ReleaseDate)
VALUES
    (2, 1, 1, 'Winter Is Coming', '2011-06-14'),
    (2, 1, 2, 'The Kingsroad', '2011-06-24'),
    (2, 1, 3, 'Lord Snow', '2011-07-01'),
    (2, 1, 4, 'Cripples, Bastards, and Broken Things', '2011-07-08'),
    (2, 1, 5, 'The Wolf and the Lion', '2011-07-15'),
    (2, 1, 6, 'A Golden Crown', '2011-07-22'),
    (2, 1, 7, 'You Win or You Die', '2011-07-29'),
    (2, 1, 8, 'The Pointy End', '2011-08-05'),
    (2, 1, 9, 'Baelor', '2011-08-12'),
    (2, 1, 10, 'Fire and Blood', '2011-08-19'),
    (2, 2, 1, 'The North Remembers', '2012-06-01'),
    (2, 3, 1, 'Valar Dohaeris', '2013-05-31'),
    (2, 4, 1, 'Two Swords', '2014-06-06'),
    (2, 5, 1, 'The Wars to Come', '2015-06-12'),
    (2, 6, 1, 'The Red Woman', '2016-06-24'),
    (2, 7, 1, 'Dragonstone', '2017-06-16'),
    (2, 8, 1, 'Winterfell', '2019-06-14');

INSERT INTO Score
    (FilmId, UserId, Score)
VALUES
    (1, 1, 7),
    (1, 2, 8.5),
    (1, 3, 6.5),
    (2, 1, 6.5),
    (2, 2, 7.8),
    (2, 3, 9.0),
    (3, 1, 8.0),
    (3, 2, 8.7),
    (3, 3, 7.2);

INSERT INTO Boxoffice
    (FilmId, CountryId, Income)
VALUES
    (1, 1, (340000000, 'USD')),
    (1, 5, (5000000, 'EUR')),
    (3, 2, (22000000, 'RUB')),
    (4, 1, (130000000, 'USD'));

INSERT INTO Profession
    (ProfessionId, ProfessionName)
VALUES
    (1, 'режиссер'),
    (2, 'сценарист'),
    (3, 'актер'),
    (4, 'продюсер'),
    (5, 'директор фильма'),
    (6, 'композитор'),
    (7, 'художник по костюмах'),
    (8, 'оператор');

INSERT INTO Filmmaker
    (FilmId, PersonId, ProfessionId, Сharacter)
VALUES
    (1, 1, 3, 'Forrest Gump'),
    (1, 2, 1, null),
    (2, 3, 6, null),
    (2, 4, 4, null),
    (2, 4, 1, null),
    (2, 4, 2, null),
    (2, 5, 4, null),
    (2, 5, 1, null),
    (2, 5, 2, null),
    (2, 6, 3, 'Tyrion Lannister'),
    (2, 7, 3, 'Cersei Lannister'),
    (2, 8, 7, null),
    (3, 9, 1, null),
    (3, 10, 8, null),
    (3, 11, 5, null),
    (3, 12, 3, 'Лариса Дмитриевна Огудалова'),
    (3, 13, 3, 'Сергей Сергеевич Паратов'),
    (3, 14, 3, 'Харита Игнатьевна Огудалова');

INSERT INTO AwardingOrg
    (AwardId, AwardName, AwardDate)
VALUES
    (1, 'Оскар', '1995-05-27'),
    (2, 'Золотой глобус', '1995-01-21'),
    (3, 'Сатурн', '2019-05-10'),
    (4, 'Премия канала MTV', '1995-03-24'),
    (5, 'Эмми', '2019-04-01');

INSERT INTO FilmNomination
    (FNominationId, FNominationName)
VALUES
    (1, 'ТВ-шоу года'),
    (2, 'Лучший телесериал в жанре фентези'),
    (3, 'Лучший драматический сериал'),
    (4, 'Лучшая драка'),
    (5, 'Лучший фильм'),
    (6, 'Лучший монтаж'),
    (7, 'Лучший адаптивный сценарий'),
    (8, 'Лучшие визуальные эффекты'),
    (9, 'Лучший грим'),
    (10, 'Лучшая работа оператора');

INSERT INTO PersonNomination
    (PNominationId, PNominationName, ProfessionId)
VALUES
    (1, 'Лучшая мужская роль', 3),
    (2, 'Лучший режиссер', 1),
    (3, 'Лучший продюссер', 4),
    (4, 'Лучшая телеакриса', 3),
    (5, 'Лучший актер второго плана в телесериале', 3),
    (6, 'Лучший оператор', 8);

INSERT INTO FilmAward
    (AwardId, FNominationId, FilmId, Win)
VALUES
    (1, 5, 1, True),
    (1, 7, 1, True),
    (1, 9, 1, False),
    (1, 10, 1, False),
    (2, 5, 1, True),
    (2, 8, 1, False),
    (4, 5, 1, False),
    (4, 1, 2, True),
    (4, 4, 2, False),
    (3, 2, 2, True),
    (5, 3, 2, True);

INSERT INTO PersonAward
    (AwardId, PNominationId, FilmId, PersonId, ProfessionId, Win)
VALUES
    (1, 1, 1, 1, 3, True),
    (1, 2, 1, 2, 1, True),
    (2, 1, 1, 1, 3, True),
    (2, 2, 1, 2, 1, False),
    (3, 4, 2, 7, 3, True),
    (3, 5, 2, 6, 3, False),
    (5, 5, 2, 6, 3, True),
    (5, 3, 2, 4, 4, True);

INSERT INTO Keys
    (TableName, MinKey)
VALUES
    ('Country', 6),
    ('Person', 20),
    ('Genre', 20),
    ('Film', 10),
    ('Profession', 10),
    ('AwardingOrg', 10),
    ('PersonNomination', 10),
    ('FilmNomination', 11);