dropdb FilmDB
createdb FilmDB
psql -d FilmDB -f create.sql
psql -d FilmDB -f functions.sql   
psql -d FilmDB -f views.sql   
psql -d FilmDB -f roles.sql   
psql -d FilmDB -f fill.sql   

curl -d '{"login":"reestro-test@yandex.ru", "password":"Q1w2e3"}' -H "Content-Type: application/json" -X POST http://localhost:8080/realty/auth/v2/authenticate-by-pass
