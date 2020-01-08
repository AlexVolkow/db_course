dropdb FilmDB
createdb FilmDB
psql -d FilmDB -f create.sql
psql -d FilmDB -f functions.sql   
psql -d FilmDB -f views.sql   
psql -d FilmDB -f roles.sql   
psql -d FilmDB -f fill.sql   
