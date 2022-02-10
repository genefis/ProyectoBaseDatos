-- insert de los datos de la tabla movie
INSERT INTO movie
SELECT mc.`index`,mc.budget,mc.genres,mc.homepage,mc.id_Movie,mc.keywords,mc.original_language,mc.original_title,
       mc.overview,mc.popularity,mc.release_date,mc.revenue,mc.runtime,mc.status,mc.tagline,mc.title,
       mc.vote_average,mc.vote_count,mc.cast,MD5(mc.director)
	FROM movie_cleaned mc;
ALTER TABLE movie_cleaned  ADD Primary Key (id_movie);


-- insert production_companies
-- Una vez que tenemos los datos del JSON Production Companies Los entramos a la tabla production Companies Creada Anteriormente
INSERT INTO production_companies
SELECT DISTINCT t.name_company,t.id_production_company
FROM tmp_production_companies t;


-- Una vez que tenemos la tabla movie y la tabla Production companies se crea la tercera tabla movies_companies que se genera debido a la
-- relacion de muchos a muchos por movie y production_companies
-- PK: id,  id_production_company
INSERT INTO movies_companies
SELECT  DISTINCT m.id_Movie,  pc.id_production_companies
FROM movie m, tmp_production_companies t, production_companies pc
WHERE m.id_Movie = t.id_movie AND t.id_production_company = pc.id_production_companies;

-- Insert Production Companies
-- Una vez que tenemos los datos del JSON Production Companies Los entramos a la tabla production Countries Creada Anteriormente
INSERT INTO production_countries
SELECT DISTINCT tmp_production_countries.iso_3166_1,tmp_production_countries.name
FROM tmp_production_countries;
-- WHERE m.id_Movie = t.id_movie ;

INSERT INTO spoken_languages
SELECT DISTINCT tmp_spoken_languages.iso_639_1 ,spoken_languages.`language`
FROM tmp_spoken_languages;

-- WHERE m.id_Movie = t.id_movie ;
-- Una vez que tenemos la tabla movie y la tabla Production countries se crea la tercera tabla movies_countries que se genera debido a la
-- relacion de muchos a muchos por movie y production_countries
-- PK: id_Movie,  iso_3166_1
INSERT INTO movies_countries
SELECT  DISTINCT m.id_Movie,  pc.iso_3166_1
FROM movie m, tmp_production_countries tpc, production_countries pc
WHERE m.id_Movie = tpc.id_movie AND tpc.iso_3166_1 = pc.iso_3166_1;



-- Una vez que tenemos la tabla movie y la tabla Production countries se crea la tercera tabla movies_countries que se genera debido a la
-- relacion de muchos a muchos por movie y production_countries
-- PK: id_Movie,  iso_3166_1
INSERT INTO movies_languages
SELECT  DISTINCT m.id_Movie,  sl.iso_639_1
FROM movie m, tmp_spoken_languages tsl, spoken_languages sl
WHERE m.id_Movie = tsl.id_movie AND tsl.iso_639_1 = sl.iso_639_1;

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Genero <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
use proyectmovie;
INSERT INTO genero
SELECT DISTINCT tmg.idGe,tmg.genre
FROM  tmp_genres tmg;

INSERT INTO genero_movie
SELECT m.id_Movie,  g.id_Genero
FROM movie m,tmp_genres tmg, genero g
WHERE m.id_Movie = tmg.id_movie AND tmg.idGe = g.id_Genero;

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Crew <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
INSERT INTO crew(
SELECT DISTINCT tmc.id_crew, tmc.name,tmc.gender
FROM movie m,tmp_crew tmc
    WHERE m.id_Movie=tmc.id_movie);

INSERT INTO credit(
SELECT DISTINCT tmc.credit_id, tmc.job,tmc.department,tmc.id_crew
FROM movie m,tmp_crew tmc,crew c
WHERE m.id_Movie = tmc.id_movie AND tmc.id_crew = c.idCrew);

INSERT INTO movies_credit(
SELECT DISTINCT m.id_Movie,c.credit_id
FROM tmp_crew tmc,movie m, credit c
WHERE m.id_Movie = tmc.id_movie AND tmc.credit_id = c.credit_id);
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Director <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
INSERT INTO director(
SELECT distinct MD5(m.director) AS id_director, m.director AS Director
FROM movie_dataset m LEFT JOIN crew c ON m.director = REPLACE(c.name, '"', ''));

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> drops de tables temporales <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
DROP TABLE IF EXISTS tmp_production_companies ;
DROP TABLE IF EXISTS tmp_production_countries ;
DROP TABLE IF EXISTS tmp_spoken_languages ;
DROP TABLE IF EXISTS tmp_crew ;
DROP TABLE IF EXISTS tmp_genres ;