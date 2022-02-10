DROP PROCEDURE IF EXISTS Json2Relational_production_countries;
DELIMITER //
CREATE PROCEDURE Json2Relational_production_countries()
BEGIN
    DECLARE a INT Default 0 ;
DROP TABLE IF EXISTS tmp_production_countries ;
CREATE TABlE tmp_production_countries
      (id_movie INT, name VARCHAR (200),iso_3166_1 VARCHAR (200));
simple_loop: LOOP
INSERT INTO tmp_production_countries (id_movie, name, iso_3166_1)
        SELECT id_movie, 
            JSON_EXTRACT(CONVERT(production_countries using utf8mb4), CONCAT("$[",a,"].name")) AS name,
            JSON_EXTRACT(CONVERT(production_countries using utf8mb4), CONCAT("$[",a,"].iso_3166_1")) AS iso_3166_1
            FROM movie_cleaned mc
            WHERE id_movie IN (SELECT id_movie FROM movie_cleaned WHERE a <= JSON_LENGTH (production_countries));
        SET a=a+1;
          IF a=6 THEN
            LEAVE simple_loop;
      END IF;
   END LOOP simple_loop;
     DELETE FROM tmp_production_countries WHERE name IS NULL ;
  END //
DELIMITER ;
Call Json2Relational_production_countries();

DROP PROCEDURE IF EXISTS Json2Relational_spoken_languages;
DELIMITER //
CREATE PROCEDURE Json2Relational_spoken_languages()
BEGIN
    DECLARE a INT Default 0 ;
DROP TABLE IF EXISTS tmp_spoken_languages ;
CREATE TABlE tmp_spoken_languages
      (id_movie INT, name VARCHAR (200),iso_639_1 VARCHAR (200));
simple_loop: LOOP
INSERT INTO tmp_spoken_Languages (id_movie, name, iso_639_1)
        SELECT id as id_movie, 
            JSON_EXTRACT(CONVERT(spoken_languages using utf8mb4), CONCAT("$[",a,"].name")) AS name,
            JSON_EXTRACT(CONVERT(spoken_languages using utf8mb4), CONCAT("$[",a,"].iso_639_1")) AS id_spoken
            FROM movie_cleaned mc
            WHERE id IN (SELECT id FROM movie_cleaned WHERE a <= JSON_LENGTH (spoken_languages));
        SET a=a+1;
          IF a=6 THEN
            LEAVE simple_loop;
      END IF;
   END LOOP simple_loop;
     DELETE FROM tmp_spoken_languages WHERE name IS NULL ;
  END //
DELIMITER ;
Call Json2Relational_spoken_Languages();

DROP PROCEDURE IF EXISTS Json2Relational_production_companies ;
DELIMITER //
CREATE PROCEDURE Json2Relational_production_companies()
BEGIN
	DECLARE a INT Default 0 ;
	DROP TABLE IF EXISTS tmp_production_companies ;
	CREATE TABlE tmp_production_companies (id_movie INTEGER, id_production_company INT, name_company VARCHAR (100) );
  simple_loop: LOOP
		INSERT INTO tmp_production_companies (id_movie, name_company,id_production_company)
		SELECT id_movie,
		    JSON_EXTRACT(mc.production_companies , CONCAT('$[',a,'].name')),
			JSON_EXTRACT(mc.production_companies, CONCAT('$[',a,'].id'))
		FROM movie_cleaned mc 
        WHERE id_movie IN (SELECT id_movie FROM movie_cleaned WHERE a <= JSON_LENGTH (production_companies));
			SET a=a+1;
     	IF a=10 THEN
            LEAVE simple_loop;
      END IF;
   END LOOP simple_loop;
   DELETE FROM tmp_production_companies WHERE id_production_company IS NULL ;
END //
DELIMITER ;
Call Json2Relational_production_companies();

DROP PROCEDURE IF EXISTS Json2Relational_crew ;
DELIMITER //
CREATE PROCEDURE Json2Relational_crew()
BEGIN
	DECLARE a INT Default 0 ;
	DROP TABLE IF EXISTS tmp_crew;
	CREATE TABlE tmp_crew
	  (id_movie INT, id_crew INT, job VARCHAR (200), name VARCHAR (400), gender INT, credit_id VARCHAR (50), department VARCHAR (50) );
simple_loop: LOOP
		INSERT INTO tmp_crew (id_movie, id_crew, job, name, gender, credit_id, department)
		SELECT id_movie,
			JSON_EXTRACT(CONVERT(crew using utf8mb4), CONCAT("$[",a,"].id")) AS id_crew,
			JSON_EXTRACT(CONVERT(crew using utf8mb4), CONCAT("$[",a,"].job")) AS job,
			JSON_EXTRACT(CONVERT(crew using utf8mb4), CONCAT("$[",a,"].name")) AS name,
			JSON_EXTRACT(CONVERT(crew using utf8mb4), CONCAT("$[",a,"].gender")) AS gender,
			JSON_EXTRACT(CONVERT(crew using utf8mb4), CONCAT("$[",a,"].credit_id")) AS credit_id,
			JSON_EXTRACT(CONVERT(crew using utf8mb4), CONCAT("$[",a,"].department")) AS department
		FROM movie_cleaned mc
		WHERE id_movie IN (SELECT id_Movie FROM movie_cleaned WHERE a <= JSON_LENGTH (crew) );
SET a=a+1;
     	IF a=436 THEN
            LEAVE simple_loop;
      END IF;
   END LOOP simple_loop;
   DELETE FROM tmp_crew WHERE id_crew IS NULL ;
END //
DELIMITER ;
Call Json2Relational_crew();

Alter table tmp_crew add primary key (id_movie,credit_id);
UPDATE tmp_crew
SET gender = 2
WHERE id_crew = 30711 ;

DROP PROCEDURE IF EXISTS Json2Relational_Key_words ;
DELIMITER //
CREATE PROCEDURE Json2Relational_Key_words()
BEGIN
	DECLARE a INT Default 0 ;
	
	-- crear tabla temporal para almacenar datos de Key_words que están en JSON
	DROP TABLE IF EXISTS tmp_Key_Words ;
	CREATE TABlE tmp_Key_Words (id_movie INT, keyWords VARCHAR (100) );
	
	-- ciclo repetitivo para ir cargando datos desde el arreglo JSON hacia la tabla temporal
  simple_loop: LOOP
-- cargando datos del objeto JSON en la tabla temporal 
		INSERT INTO tmp_Key_Words (id_movie, keyWords)  
		SELECT  id_Movie, 
				JSON_EXTRACT(CONCAT('["',REPLACE (REPLACE (keywords, '"', ' '), ' ', '","'), '"]'), CONCAT("$[",a,"]")) AS keyWords
		FROM movie_cleaned mc ; 
			SET a=a+1;	
     	IF a=20 THEN
            LEAVE simple_loop;
      END IF;
   END LOOP simple_loop;
   -- limpieza de registros nulos
   DELETE FROM tmp_Key_Words WHERE keyWords IS NULL ;
END //
DELIMITER ;
Call Json2Relational_Key_words();


DROP PROCEDURE IF EXISTS Json2Relational_genres ;
DELIMITER //
CREATE PROCEDURE Json2Relational_genres()
BEGIN
	DECLARE a INT Default 0 ;
	DROP TABLE IF EXISTS tmp_genres ;
	CREATE TABlE tmp_genres (id_movie INT not null, idGe VARCHAR(100),genre VARCHAR (100) );
	simple_loop: LOOP
		INSERT INTO tmp_genres (id_movie,idGe,genre)
        SELECT * FROM (
			SELECT id_movie as id_movie,MD5(REPLACE(JSON_EXTRACT(CONCAT('["', REPLACE(REPLACE (genres, ' ', '","'),
				    'Science","Fiction', 'Science Fiction'), '"]'), CONCAT("$[",a,"]")), """","")),
				REPLACE(JSON_EXTRACT(CONCAT('["', REPLACE(REPLACE (genres, ' ', '","'),
				    'Science","Fiction', 'Science Fiction'), '"]'), CONCAT("$[",a,"]")), """","") AS genre
			FROM movie_cleaned ) t
        WHERE genre != "";
			SET a=a+1;
     	IF a=6 THEN
            LEAVE simple_loop;
		END IF;
	END LOOP simple_loop;
	DELETE FROM tmp_genres WHERE genre IS NULL;
END //
DELIMITER ;
Call Json2Relational_genres();

-- Borrar si existe una versión anterior (re-crear el procedimiento)
DROP PROCEDURE IF EXISTS Json2Relational_Cast ;
DELIMITER //
CREATE PROCEDURE Json2Relational_Cast()
BEGIN
	DECLARE a INT Default 0 ;
		-- crear tabla temporal para almacenar datos de Cast que están en JSON
	DROP TABLE IF EXISTS tmp_Cast ;
	CREATE TABlE tmp_Cast (id_movie INT, `name` VARCHAR (100) );
			-- ciclo repetitivo para ir cargando datos desde el arreglo JSON hacia la tabla temporal
  simple_loop: LOOP
-- cargando datos del objeto JSON en la tabla temporal 
		INSERT INTO tmp_Cast (id_movie, `name`)  
		SELECT id_movie,
		JSON_EXTRACT(CONVERT(cast using utf8mb4), CONCAT("$[",a,"].id")) AS 'name'
		FROM movie_cleaned mc; 
			SET a=a+1;	
     	IF a=6 THEN
            LEAVE simple_loop;
      END IF;
   END LOOP simple_loop;
   DELETE FROM tmp_Cast WHERE `name` IS NULL ;
END //
DELIMITER ;
Call Json2Relational_Cast();

