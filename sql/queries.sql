/* Wie viele Inhalte (Filme und Serien) sind insgesamt im Datensatz enthalten?
   Wie viele davon sind Filme und wie viele TV-Shows?*/

-- Anzahl der Titel gesamt
SELECT 
	COUNT(*) AS titel_gesamt						-- 5806
FROM 
	title;

SELECT												-- 3759 Movies & 2047 Serien
	COUNT(*) AS anzahl,
    tt.type_name
FROM 
	title t
JOIN 
	title_type tt ON t.type_id = tt.type_id
GROUP BY 
	tt.type_name
ORDER BY 
	anzahl DESC;
	
-- Welche Genres kommen im Datensatz am häufigsten vor?
SELECT 
	COUNT (DISTINCT tg.title_id) AS Anzahl_Titel,
	g.genre_name
FROM 
	genre g
JOIN 
	title_genre tg ON g.genre_id = tg.genre_id
GROUP BY 
	g.genre_name
ORDER BY 
	Anzahl_Titel DESC;

-- TOP 10
SELECT 
	COUNT (DISTINCT tg.title_id) AS Anzahl_Titel,
	g.genre_name
FROM 
	genre g
JOIN 
	title_genre tg ON g.genre_id = tg.genre_id
GROUP BY 
	g.genre_name
ORDER BY 
	Anzahl_Titel DESC
LIMIT 10;

-- Wie verteilen sich die Inhalte über die Jahre (z. B. Veröffentlichungen je Jahr)?
SELECT 
	COUNT (DISTINCT tg.title_id) AS Anzahl_Titel,
	t.release_year
FROM 
	title_genre tg
JOIN 
	title t ON tg.title_id = t.title_id
WHERE 
	t.release_year IS NOT NULL
GROUP BY 
	t.release_year
ORDER BY 
	Anzahl_Titel DESC;

SELECT
    t.release_year,
    COUNT(*) AS Anzahl_Titel
FROM 
    title t
WHERE 
    t.release_year IS NOT NULL
GROUP BY 
    t.release_year
ORDER BY 
    t.release_year;
	
-- Zusätzlich nach Typ
SELECT
    COUNT(*) AS Anzahl,
	t.release_year,
    tt.type_name
FROM 
	title t
JOIN 
	title_type tt ON t.type_id = tt.type_id
GROUP BY 
	t.release_year, tt.type_name
ORDER BY 
	t.release_year, tt.type_name;

-- Welche Regisseure haben die meisten Inhalte auf Netflix produziert?

SELECT
	COUNT(*) AS Anzahl_Titel,
    d.director_name    
FROM 
	title_director td
JOIN 
	director d ON td.director_id = d.director_id
GROUP BY 
	d.director_name
ORDER BY 
	Anzahl_Titel DESC
LIMIT 10;

-- nur eindeutige Titel nach Regisseur
SELECT
	d.director_name,
	COUNT(DISTINCT td.title_id) AS Anzahl_Titel
FROM 
	title_director td
JOIN 
	director d ON td.director_id = d.director_id
GROUP BY 
	d.director_name
ORDER BY 
	Anzahl_Titel DESC
LIMIT 10;

/* Analysiere die Länge/Dauer:
	• Welche Filme sind am längsten (Laufzeit)? */
	 
SELECT
    t.title,
    t.runtime,
    t.release_year
FROM 
	title t
JOIN title_type tt ON t.type_id = tt.type_id
WHERE 
	tt.type_name = 'MOVIE' AND t.runtime IS NOT NULL
ORDER BY 
	t.runtime DESC, 
	t.title
LIMIT 10;

/* Analysiere die Länge/Dauer:
  • Welche Serien haben die meisten Staffeln oder Episoden (sofern Daten vorhanden)? */
  
SELECT
    t.title,
    t.seasons AS Staffeln,										-- 420 Staffeln?
    t.release_year
FROM 
	title t
JOIN 
	title_type tt ON t.type_id = tt.type_id
WHERE 
	tt.type_name = 'SHOW' AND t.seasons IS NOT NULL
ORDER BY 
	t.seasons DESC, 
	t.title
LIMIT 10;

-- Kontrollabfrage -
SELECT
    COUNT(*) AS total_shows,
    COUNT(*) FILTER (WHERE seasons % 10 = 0) AS vielfache_von_10,
    COUNT(*) FILTER (WHERE seasons % 10 <> 0) AS nicht_vielfache_von_10
FROM title t
JOIN title_type tt
    ON t.type_id = tt.type_id
WHERE tt.type_name = 'SHOW'
  AND t.seasons IS NOT NULL;

-- verbesserte Query
SELECT
    t.title,
    t.seasons / 10 AS Staffeln,
    t.release_year
FROM 
	title t
JOIN 
	title_type tt ON t.type_id = tt.type_id
WHERE 
	tt.type_name = 'SHOW' AND t.seasons IS NOT NULL
ORDER BY 
	t.seasons DESC, 
	t.title
LIMIT 10;
 
/* Untersuche die Genre-Beliebtheit in Bezug auf Veröffentlichungsjahr:
   • Gibt es Trends bei Genres über die Zeit?    */

SELECT
	COUNT(*) AS Anzahl_Titel,
    t.release_year,
    g.genre_name    
FROM 
	title t
JOIN 
	title_genre tg ON t.title_id = tg.title_id
JOIN 
	genre g ON tg.genre_id = g.genre_id
GROUP BY 
	t.release_year, 
	g.genre_name
ORDER BY 
	t.release_year, 
	Anzahl_Titel DESC;

-- TOP 3 Genre pro Jahr
WITH genre_year AS (
    SELECT
		COUNT(*) AS Anzahl_Titel,
        t.release_year,
        g.genre_name 
    FROM 
		title t
    JOIN 
		title_genre tg ON t.title_id = tg.title_id
    JOIN 
		genre g ON tg.genre_id = g.genre_id
    GROUP BY 
		t.release_year, g.genre_name),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY release_year ORDER BY Anzahl_Titel DESC) AS rnk    -- jedes Jahr neu gerankt
    FROM 
		genre_year)
SELECT
    release_year,
    genre_name,
    Anzahl_Titel
FROM 
	ranked
WHERE 
	rnk <= 3
ORDER BY 
	release_year,
	Anzahl_Titel DESC;

-- Entwicklung der Genre über die Jahre
WITH genre_counts AS (
    SELECT
		COUNT(*) AS Titel_gesamt,
        g.genre_name
    FROM 
		title_genre tg
    JOIN 
		genre g ON tg.genre_id = g.genre_id
    GROUP BY 
		g.genre_name),
top_genres AS (
    SELECT 
		genre_name
    FROM 
		genre_counts
    ORDER BY Titel_gesamt DESC
    LIMIT 5),
genre_year AS (
    SELECT
        t.release_year,
        g.genre_name,
        COUNT(*) AS Anzahl_Titel
    FROM 
		title t
    JOIN 
		title_genre tg ON t.title_id = tg.title_id
    JOIN 
		genre g ON tg.genre_id = g.genre_id
    WHERE 
		g.genre_name IN (SELECT genre_name FROM top_genres)
    GROUP BY 
		t.release_year, 
		g.genre_name)
SELECT *
FROM 
	genre_year
ORDER BY 
	release_year, genre_name;

-- Anpassung Query für Visualisierung
WITH genre_counts AS (
    SELECT
        g.genre_name,
        COUNT(*) AS total_titles
    FROM 
		title_genre tg
    JOIN 
		genre g ON tg.genre_id = g.genre_id
    GROUP BY 
		g.genre_name),
top_genres AS (
    SELECT 
		genre_name
    FROM 
		genre_counts
    ORDER BY 
		total_titles DESC, 
		genre_name
    LIMIT 5)
SELECT
    t.release_year,
    g.genre_name,
    COUNT(*) AS Anzahl_Titel
FROM 
	title t
JOIN 
	title_genre tg ON t.title_id = tg.title_id
JOIN 
	genre g ON tg.genre_id = g.genre_id
WHERE g.genre_name IN (SELECT genre_name FROM top_genres)
  AND t.release_year IS NOT NULL
  AND t.release_year >= 2011
GROUP BY 
	t.release_year, 
		g.genre_name
ORDER BY 
	t.release_year, 
	anzahl_titel DESC, 
	g.genre_name;

	
-- Top Genre pro Jahr
WITH genre_year AS (
    SELECT
		COUNT(*) AS Anzahl_Titel,
        t.release_year,
        g.genre_name      
    FROM 
		title t
    JOIN 
		title_genre tg ON t.title_id = tg.title_id
    JOIN 
		genre g ON tg.genre_id = g.genre_id
    GROUP BY 
		t.release_year, g.genre_name),
ranked AS (
    SELECT
		Anzahl_Titel,
        release_year,
        genre_name,       
        ROW_NUMBER() OVER (PARTITION BY release_year ORDER BY Anzahl_Titel DESC, genre_name) AS rnk
    FROM genre_year)
SELECT
	Anzahl_Titel,
    release_year,
    genre_name    
FROM 
	ranked
WHERE 
	rnk = 1
ORDER BY 
	release_year;

/* Welche Titel enthalten bestimmte Schlüsselwörter im Titel oder in der
   Beschreibung (z. B. „Love“, „War“, „Adventure“)?
   Fasse gruppiert nach Keyword.   */

WITH keywords AS (
    SELECT 'Love' AS keyword
    UNION ALL
    SELECT 'War'
    UNION ALL
    SELECT 'Adventure'
	UNION ALL
	SELECT 'Hate')
SELECT
	COUNT(*) AS Anzahl_Titel,
    k.keyword   
FROM 
	keywords k
JOIN 
	title t ON t.title ILIKE '%' || k.keyword || '%'
GROUP BY 
	k.keyword
ORDER BY 
	Anzahl_Titel DESC;

-- Verhältnis Filme zu Serien pro Jahr (Variante 1 - Filme & Serien getrennt)
SELECT
    t.release_year,
    COUNT(*) FILTER (WHERE tt.type_name = 'MOVIE') AS filme,
    COUNT(*) FILTER (WHERE tt.type_name = 'SHOW') AS serien
FROM 
    title t
JOIN 
    title_type tt ON t.type_id = tt.type_id
WHERE
    t.release_year IS NOT NULL
GROUP BY 
    t.release_year
ORDER BY 
    t.release_year;

-- Verhältnis Filme zu Serien pro Jahr (Variante 2) - besser für Visualisierung
SELECT
    t.release_year,
    tt.type_name,
    COUNT(*) AS anzahl_titel
FROM 
    title t
JOIN 
    title_type tt ON t.type_id = tt.type_id
WHERE
    t.release_year BETWEEN 2011 AND 2021
GROUP BY 
    t.release_year,
    tt.type_name
ORDER BY 
    t.release_year,
    tt.type_name;

-- Länder mit den meisten Inhalten bzw. Land mit den wenigsten Titel(n)

WITH country_counts AS (
    SELECT
        c.country_value,
        COUNT(*) AS Anzahl_Titel
    FROM 
		title_country tc
    JOIN 
		country c ON tc.country_value = c.country_value
    GROUP BY 
		c.country_value),
ranked_countries AS (
    SELECT
        country_value,
        anzahl_titel,
        DENSE_RANK() OVER (ORDER BY anzahl_titel DESC) AS Rang,							-- vergibt Ränge ohne Lücken
        ROW_NUMBER() OVER (ORDER BY anzahl_titel DESC, country_value) AS Sortierung
    FROM 
		country_counts),
min_country AS (
    SELECT
        country_value,
        anzahl_titel
    FROM 
		country_counts
    ORDER BY 
		Anzahl_Titel ASC, 
		country_value ASC
    LIMIT 1)
SELECT
    country_value,
    anzahl_titel,
    rang,
    'Top 10' AS Kategorie,
    Sortierung
FROM 
	ranked_countries
WHERE 
	Sortierung <= 10
UNION ALL								-- fügt beide Ergebnisse untereinander zusammen (verbindet Top 10 & Minimalwert)
SELECT
    country_value,
    anzahl_titel,
    NULL AS rang,
    'Minimalwert' AS Kategorie,
    11 AS Sortierung				   -- 11 = Top 10 mit Maximalmalwert + 1 Minimalwert
FROM 
	min_country
ORDER BY 
	Sortierung;

-- Top 10-Länder & Top 3 Titel pro Land
WITH country_counts AS (
    SELECT
        tc.country_value,
        COUNT(DISTINCT tc.title_id) AS title_count
    FROM 
		title_country tc
    GROUP BY 
		tc.country_value),
top_countries AS (
    SELECT
        country_value,
        title_count
    FROM country_counts
    ORDER BY title_count DESC
    LIMIT 10),
ranked_titles AS (
    SELECT
        tc.country_value,
        t.title,
        tt.type_name,
        t.release_year,
        t.imdb_score,
        t.imdb_votes,
        ROW_NUMBER() OVER (PARTITION BY tc.country_value ORDER BY t.imdb_score DESC NULLS LAST, t.imdb_votes DESC NULLS LAST, t.title) AS rank_in_country
    FROM 
		title_country tc
    JOIN 
		title t ON tc.title_id = t.title_id
    JOIN 
		title_type tt ON t.type_id = tt.type_id
    WHERE 
		t.imdb_score IS NOT NULL)
SELECT
    c.country_value,
    c.title_count,
    r.rank_in_country,
    r.title,
    r.type_name,
    r.release_year,
    ROUND(r.imdb_score /10.2, 2) AS imdb_score,
    r.imdb_votes
FROM 
	top_countries c
JOIN 
	ranked_titles r ON c.country_value = r.country_value
WHERE 
	r.rank_in_country <= 3
ORDER BY 
	c.title_count DESC, 
	c.country_value, 
	r.rank_in_country;
	
-- Welche Genres haben im Durchschnitt die höchste IMDb-Bewertung?
SELECT
    COUNT(*) AS anzahl_titel,
    g.genre_name,
    ROUND(AVG(t.imdb_score) / 10.0, 2) AS avg_imdb_score
FROM 
	title t
JOIN 
	title_genre tg ON t.title_id = tg.title_id
JOIN 
	genre g ON tg.genre_id = g.genre_id
WHERE 
	t.imdb_score IS NOT NULL
GROUP BY 
	g.genre_name
HAVING 
	COUNT(*) >= 50
ORDER BY 
	avg_imdb_score DESC, 
	Anzahl_Titel DESC
LIMIT 10;

-- Top 10 bewertet Filme auf Netflix?
SELECT
    t.title,
    t.release_year,
    ROUND(t.imdb_score, 1) AS imdb_score,
    t.imdb_votes
FROM 
	title t
JOIN 
	title_type tt ON t.type_id = tt.type_id
WHERE 
	t.imdb_score IS NOT NULL AND tt.type_name = 'MOVIE'
ORDER BY 
	t.imdb_score DESC, 
	t.imdb_votes DESC
LIMIT 10;

-- Top 10 bewertet Serien auf Netflix?
SELECT
    t.title,
    t.release_year,
    ROUND(t.imdb_score, 1) AS imdb_score,
    t.imdb_votes
FROM 
	title t
JOIN 
	title_type tt ON t.type_id = tt.type_id
WHERE 
	t.imdb_score IS NOT NULL AND tt.type_name = 'SHOW'
ORDER BY  
	t.imdb_score DESC, 
	t.imdb_votes DESC
LIMIT 10;

-- Titel mit den meisten Votings
SELECT
    t.title,
    tt.type_name,
    t.release_year,
    ROUND(t.imdb_score, 1) AS imdb_score,
    t.imdb_votes
FROM 
	title t
JOIN 
	title_type tt ON t.type_id = tt.type_id
WHERE 
	t.imdb_score IS NOT NULL AND t.imdb_votes >= 10000
ORDER BY 
	t.imdb_score DESC, 
	t.imdb_votes DESC
LIMIT 10;

-- View Inhalte je Jahr
CREATE OR REPLACE VIEW vw_titles_per_year AS
SELECT
	COUNT(*) AS Anzahl_Titel,
    release_year    
FROM 
	title
GROUP BY 
	release_year;

-- Check
SELECT * FROM vw_titles_per_year;

-- View der Top-Genres
CREATE OR REPLACE VIEW vw_genre_counts AS
SELECT
	COUNT(*) AS Anzahl_Titel,
    g.genre_name    
FROM 
	title_genre tg
JOIN 
	genre g ON tg.genre_id = g.genre_id
GROUP BY 
	g.genre_name;


-- Check
SELECT * FROM vw_genre_counts;

-- View Inhalte nach Typ
CREATE OR REPLACE VIEW vw_titles_by_type AS
SELECT
	COUNT(*) AS Anzahl_Titel,
    tt.type_name    
FROM 
	title t
JOIN 
	title_type tt ON t.type_id = tt.type_id
GROUP BY 
	tt.type_name;

-- Check
SELECT * FROM vw_titles_by_type;

-- Zielgruppen nach Altersfreigabe
WITH Altersgruppen AS (
    SELECT
        tt.type_name,
        CASE
            WHEN ac.certification_name IN ('TV-Y', 'TV-G', 'TV-Y7', 'G') THEN 'Kinder / Familie'
            WHEN ac.certification_name IN ('PG', 'TV-PG', 'PG-13', 'TV-14') THEN 'Jugend / Familie'
            WHEN ac.certification_name IN ('R', 'TV-MA', 'NC-17') THEN 'Erwachsene'
            ELSE 'Unbekannt / Sonstige'
        END AS Zielgruppe
    FROM 
		title t
    JOIN 
		title_type tt ON t.type_id = tt.type_id
    LEFT JOIN 						-- auch Titel ohne Altersfreigabe bleiben erhalten
		age_certification ac ON t.age_certification_id = ac.age_certification_id),		
Zaehlung AS (
    SELECT
        type_name,
        zielgruppe,
        COUNT(*) AS Anzahl_Titel
    FROM Altersgruppen
    GROUP BY
        type_name,
        Zielgruppe)
SELECT
    type_name,
    zielgruppe,
    Anzahl_Titel,
    ROUND(Anzahl_Titel * 100/SUM(Anzahl_Titel) OVER (PARTITION BY type_name),2) AS Anteil_Prozent
FROM 
	Zaehlung
ORDER BY
    type_name,
    Anzahl_Titel DESC;