/*Hinweis:
Dieses Skript arbeitet unter der Voraussetzung, dass die Rohdaten zuerst in PowerQuery bereinigt wurden.
Netflix_Titles und credits wurden dann über Staging-Tabellen titles_clean und credits_clean in PgAdmin importiert */


-- Tabelle "titles_clean" erstellen
CREATE TABLE titles_clean (
    title_id TEXT,
    title TEXT,
    type TEXT,
    release_year INTEGER,
    age_certification TEXT,
    runtime INTEGER,
    genres TEXT,
    production_countries TEXT,
    imdb_id TEXT,
    imdb_score NUMERIC(3,1),
    imdb_votes INTEGER,
    seasons INTEGER);

-- Tabelle "credits_clean" erstellen
CREATE TABLE credits_clean (
    person_id INTEGER,
    title_id TEXT,
    name TEXT,
    character TEXT,
    role TEXT);
	
-- Checks
SELECT COUNT(*) FROM credits_clean;							 -- 77213

SELECT COUNT(*) FROM titles_clean;							 -- 5806

SELECT DISTINCT type FROM titles_clean;						 -- MOVIE, SHOW

SELECT DISTINCT role FROM credits_clean;					 -- ACTOR, DIRECTOR

SELECT * FROM titles_clean LIMIT 5;

SELECT * FROM credits_clean LIMIT 5;

SELECT COUNT(*) FROM titles_clean WHERE title_id IS NULL;	-- 0

SELECT COUNT(*) FROM credits_clean WHERE title_id IS NULL;	-- 0

SELECT COUNT(*) FROM credits_clean WHERE person_id IS NULL; -- 0

-- Tabelle "title" anlegen
CREATE TABLE title (
    title_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('MOVIE', 'SHOW')),
    release_year INTEGER,
    age_certification TEXT,
    runtime INTEGER,
    imdb_id TEXT,
    imdb_score NUMERIC(3,1),
    imdb_votes INTEGER,
    seasons INTEGER);

-- Daten einfügen
INSERT INTO title (
    title_id,
    title,
    type,
    release_year,
    age_certification,
    runtime,
    imdb_id,
    imdb_score,
    imdb_votes,
    seasons)
	SELECT
    	title_id,
    	title,
    	type,
    	release_year,
    	age_certification,
    	runtime,
    	imdb_id,
    	imdb_score,
    	imdb_votes,
    	seasons
	FROM 
		titles_clean;

SELECT COUNT(*) FROM title;

--NOT NULL bei title entfernen
ALTER TABLE title
ALTER COLUMN title DROP NOT NULL;

-- Tabelle "person" erstellen
CREATE TABLE person (
    person_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL);

INSERT INTO person (person_id, name)
SELECT DISTINCT
    person_id,
    name
FROM 
	credits_clean;

SELECT COUNT(*) FROM person;

SELECT DISTINCT 
	person_id, 
	name 
FROM 
	credits_clean;

-- Tabelle "title_person" anlegen
CREATE TABLE title_person (
    title_person_id SERIAL PRIMARY KEY,
    title_id TEXT NOT NULL,
    person_id INTEGER NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('ACTOR', 'DIRECTOR')),
    character TEXT,
    CONSTRAINT fk_title_person_title
        FOREIGN KEY (title_id) REFERENCES title(title_id),
    CONSTRAINT fk_title_person_person
        FOREIGN KEY (person_id) REFERENCES person(person_id));

-- Daten einfügen
INSERT INTO title_person (title_id, person_id, role, character)
SELECT DISTINCT
    title_id,
    person_id,
    role,
    NULLIF(character, '')
FROM credits_clean;

SELECT COUNT(*) FROM title_person;

-- Tabelle "genre" anlegen
CREATE TABLE genre (
    genre_id SERIAL PRIMARY KEY,
    genre_name TEXT NOT NULL UNIQUE);

-- Daten einfügen
INSERT INTO genre (genre_name)
SELECT DISTINCT TRIM(genre_name)
FROM (
    	SELECT unnest(string_to_array(replace(replace(replace(genres, '[', ''), ']', ''), '''', ''),',')) AS genre_name
    	FROM titles_clean
    	WHERE genres IS NOT NULL AND genres <> '[]')
WHERE TRIM(genre_name) <> '';

SELECT COUNT(*) FROM genre;

-- Tabelle "title_genre" anlegen
CREATE TABLE title_genre (
    title_id TEXT NOT NULL,
    genre_id INTEGER NOT NULL,
    PRIMARY KEY (title_id, genre_id),
    CONSTRAINT fk_title_genre_title
        FOREIGN KEY (title_id) REFERENCES title(title_id),
    CONSTRAINT fk_title_genre_genre
        FOREIGN KEY (genre_id) REFERENCES genre(genre_id));

-- Daten einfügen
INSERT INTO title_genre (title_id, genre_id)
SELECT DISTINCT
    genre_split.title_id,
    g.genre_id
FROM (
    SELECT
        title_id,
        unnest(
            string_to_array(
                replace(replace(replace(genres, '[', ''), ']', ''), '''', ''),',')) AS genre_name
    FROM titles_clean
    WHERE genres IS NOT NULL
      AND genres <> '[]') genre_split
JOIN genre g ON g.genre_name = TRIM(genre_split.genre_name)
WHERE TRIM(genre_split.genre_name) <> '';

SELECT COUNT(*) FROM title_genre;
SELECT * FROM title_genre LIMIT 10;

-- Tabelle "country" einfügen
CREATE TABLE country (
    country_code VARCHAR(2) PRIMARY KEY);

-- Daten einfügen
INSERT INTO country (country_code)
SELECT DISTINCT TRIM(country_code)
FROM (
    SELECT unnest(
        string_to_array(
            replace(replace(replace(production_countries, '[', ''), ']', ''), '''', ''),',')) AS country_code
    FROM titles_clean
    WHERE production_countries IS NOT NULL
      AND production_countries <> '[]') country_split
WHERE TRIM(country_code) <> '';

ALTER TABLE country
ALTER COLUMN country_code TYPE TEXT;

-- Check
SELECT DISTINCT TRIM(country_code) AS country_code
FROM (
    SELECT unnest(
        string_to_array(
            replace(replace(replace(production_countries, '[', ''), ']', ''), '''', ''),',')) AS country_code
    FROM titles_clean
    WHERE production_countries IS NOT NULL
      AND production_countries <> '[]') country_split
WHERE LENGTH(TRIM(country_code)) > 2;

-- Tabelle "title_country anlegen"
CREATE TABLE title_country (
    title_id TEXT NOT NULL,
    country_code TEXT NOT NULL,
    PRIMARY KEY (title_id, country_code),
    CONSTRAINT fk_title_country_title
        FOREIGN KEY (title_id) REFERENCES title(title_id),
    CONSTRAINT fk_title_country_country
        FOREIGN KEY (country_code) REFERENCES country(country_code));

-- Daten einfügen
INSERT INTO title_country (title_id, country_code)
SELECT DISTINCT
    country_split.title_id,
    TRIM(country_split.country_code)
FROM (
    SELECT
        title_id,
        UNNEST(
            string_to_array(
                replace(replace(replace(production_countries, '[', ''), ']', ''), '''', ''),',')) AS country_code
    FROM titles_clean
    WHERE production_countries IS NOT NULL
      AND production_countries <> '[]') country_split
WHERE TRIM(country_split.country_code) <> '';

-- Tabelle "title_type" anlegen
CREATE TABLE title_type (
    type_id SERIAL PRIMARY KEY,
    type_name TEXT NOT NULL UNIQUE);

-- Tabelle "age_certification" anlegen
CREATE TABLE age_certification (
    age_certification_id SERIAL PRIMARY KEY,
    certification_name TEXT NOT NULL UNIQUE);

-- Tabelle "actor" anlegen
CREATE TABLE actor (
    actor_id SERIAL PRIMARY KEY,
    old_person_id INT NOT NULL UNIQUE,
    actor_name TEXT NOT NULL);

-- Tabelle "director" anlegen
CREATE TABLE director (
    director_id SERIAL PRIMARY KEY,
    old_person_id INT NOT NULL UNIQUE,
    director_name TEXT NOT NULL);

-- Tabelle "title_actor" anlegen
CREATE TABLE title_actor (
    title_id TEXT NOT NULL,
    actor_id INT NOT NULL,
    character_name TEXT,
    PRIMARY KEY (title_id, actor_id),
    CONSTRAINT fk_title_actor_title
        FOREIGN KEY (title_id)
        REFERENCES title(title_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_title_actor_actor
        FOREIGN KEY (actor_id)
        REFERENCES actor(actor_id)
        ON DELETE CASCADE);

--Tabelle "title_director" anlegen
CREATE TABLE title_director (
    title_id TEXT NOT NULL,
    director_id INT NOT NULL,
    PRIMARY KEY (title_id, director_id),
    CONSTRAINT fk_title_director_title
        FOREIGN KEY (title_id)
        REFERENCES title(title_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_title_director_director
        FOREIGN KEY (director_id)
        REFERENCES director(director_id)
        ON DELETE CASCADE);
		
-- Spalte "title" um neue Spalten erweitern
ALTER TABLE title
ADD COLUMN type_id INT,
ADD COLUMN age_certification_id INT;

-- type und age_certification auslagern
INSERT INTO title_type (type_name)
SELECT DISTINCT TRIM(type)
FROM title
WHERE type IS NOT NULL AND TRIM(type) <> '';

INSERT INTO age_certification (certification_name)
SELECT DISTINCT TRIM(age_certification)
FROM title
WHERE age_certification IS NOT NULL AND TRIM(age_certification) <> '';

-- Neue FK-Werte in "title" setzen
UPDATE title t
SET type_id = tt.type_id
FROM title_type tt
WHERE TRIM(t.type) = tt.type_name;

UPDATE title t
SET age_certification_id = ac.age_certification_id
FROM age_certification ac
WHERE TRIM(t.age_certification) = ac.certification_name;

-- Foreign Keys auf title setzen
ALTER TABLE title
ADD CONSTRAINT fk_title_type
    FOREIGN KEY (type_id)
    REFERENCES title_type(type_id);

ALTER TABLE title
ADD CONSTRAINT fk_title_age_certification
    FOREIGN KEY (age_certification_id)
    REFERENCES age_certification(age_certification_id);

-- Actors und Directors aus person/title_person ableiten
INSERT INTO actor (old_person_id, actor_name)
SELECT DISTINCT
    p.person_id,
    p.name
FROM person p
JOIN title_person tp
    ON p.person_id = tp.person_id
WHERE UPPER(TRIM(tp.role)) = 'ACTOR';

INSERT INTO director (old_person_id, director_name)
SELECT DISTINCT
    p.person_id,
    p.name
FROM person p
JOIN title_person tp ON p.person_id = tp.person_id
WHERE UPPER(TRIM(tp.role)) = 'DIRECTOR';

-- Tabellen befüllen
INSERT INTO title_actor (title_id, actor_id, character_name)
SELECT DISTINCT
    tp.title_id,
    a.actor_id,
    tp.character
FROM title_person tp
JOIN actor a ON a.old_person_id = tp.person_id
WHERE UPPER(TRIM(tp.role)) = 'ACTOR';

SELECT COUNT(*) AS cnt FROM title_type;
SELECT COUNT(*) AS cnt FROM age_certification;
SELECT COUNT(*) AS cnt FROM actor;
SELECT COUNT(*) AS cnt FROM director;
SELECT COUNT(*) AS cnt FROM title_actor;
SELECT COUNT(*) AS cnt FROM title_director;

-- Actor!
TRUNCATE TABLE title_actor;

INSERT INTO title_actor (title_id, actor_id, character_name)
SELECT
    tp.title_id,
    a.actor_id,
    NULLIF(
        STRING_AGG(DISTINCT NULLIF(TRIM(tp.character), ''), ' | '),'') AS character_name
FROM title_person tp
JOIN actor a ON a.old_person_id = tp.person_id
WHERE UPPER(TRIM(tp.role)) = 'ACTOR'
GROUP BY tp.title_id, a.actor_id;

-- Director!
TRUNCATE TABLE title_director;

INSERT INTO title_director (title_id, director_id)
SELECT DISTINCT
    tp.title_id,
    d.director_id
FROM title_person tp
JOIN director d ON d.old_person_id = tp.person_id
WHERE UPPER(TRIM(tp.role)) = 'DIRECTOR';

-- Check!
SELECT COUNT(*) AS actor_links FROM title_actor;

SELECT COUNT(*) AS director_links FROM title_director;

-- Check, Check!
SELECT 
	title_id, 
	actor_id, 
	COUNT(*)
FROM 
	title_actor
GROUP BY 
	title_id, 
	actor_id
HAVING COUNT(*) > 1;

SELECT 
	COUNT(*) AS missing_type_id
FROM 
	title
WHERE type IS NOT NULL
  AND TRIM(type) <> ''
  AND type_id IS NULL;

SELECT COUNT(*) AS missing_age_certification_id
FROM title
WHERE age_certification IS NOT NULL
  AND TRIM(age_certification) <> ''
  AND age_certification_id IS NULL;

SELECT COUNT(*) AS old_actor_links
FROM title_person
WHERE UPPER(TRIM(role)) = 'ACTOR';

SELECT COUNT(*) AS old_director_links
FROM title_person
WHERE UPPER(TRIM(role)) = 'DIRECTOR';

SELECT
    tp.title_id,
    tp.person_id,
    COUNT(*) AS cnt,
    STRING_AGG(DISTINCT COALESCE(NULLIF(TRIM(tp.character), ''), '[leer]'), ' | ') AS characters
FROM title_person tp
WHERE UPPER(TRIM(tp.role)) = 'ACTOR'
GROUP BY tp.title_id, tp.person_id
HAVING COUNT(*) > 1
ORDER BY cnt DESC, tp.title_id;


ALTER TABLE title
DROP COLUMN type,
DROP COLUMN age_certification;

ALTER TABLE title
ALTER COLUMN type_id SET NOT NULL;

DROP TABLE title_person;
DROP TABLE person;

SELECT column_name
FROM information_schema.columns
WHERE table_name = 'title'
ORDER BY ordinal_position;

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- Check Spalte "type und age_certification"

SELECT COUNT(*) FROM country;

SELECT COUNT(*) FROM title_country;											

ALTER TABLE country RENAME COLUMN country_code TO country_value;

ALTER TABLE title_country RENAME COLUMN country_code TO country_value;

SELECT COUNT(*) FROM title;												   -- 5806

SELECT COUNT(*) FROM genre;												   -- 19

SELECT COUNT(*) FROM title_genre;										   -- 14558

SELECT COUNT(*) FROM country;											   -- 107

SELECT COUNT(*) FROM title_country;
