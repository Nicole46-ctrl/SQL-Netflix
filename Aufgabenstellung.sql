/* Thema 10: Netflix Movies and TV Shows Database
Fokus: Datenmodellierung, relationale Datenbanken, Datenanalyse
Lade dir den Datensatz Netflix Movies and TV Shows von GitHub herunter:
	https://github.com/Arpita-deb/netflix-movies-and-tv-shows/tree/main
Importiere alle relevanten CSV-Dateien in eine PostgreSQL-Datenbank und verknüpfe die Tabellen mittels geeigneter Schlüssel.

Beantworte anhand der Datenbank folgende Fragestellungen:
-- 1. Liste alle Tabellen auf und beschreibe für jede:
	• Primärschlüssel
	• Fremdschlüssel
	• kurze inhaltliche Beschreibung
	
-- 2. Erstelle ein ER-Diagramm, das die Beziehungen zwischen den Tabellen darstellt.

-- 3. Wie viele Inhalte (Filme und Serien) sind insgesamt im Datensatz enthalten?
	  Wie viele davon sind Filme und wie viele TV-Shows?
	  
-- 4. Welche Genres kommen im Datensatz am häufigsten vor?

-- 5. Wie verteilen sich die Inhalte über die Jahre (z. B. Veröffentlichungen je Jahr)?

-- 6. Welche Regisseure oder Showrunner haben die meisten Inhalte auf Netflix produziert?

-- 7. Analysiere die Länge/Dauer:
	• Welche Filme sind am längsten (Laufzeit)?
	• Welche Serien haben die meisten Staffeln oder Episoden (sofern Daten vorhanden)?

-- 8. Untersuche die Genre-Beliebtheit in Bezug auf Veröffentlichungsjahr:
	• Gibt es Trends bei Genres über die Zeit?
	
-- 9. Welche Titel enthalten bestimmte Schlüsselwörter im Titel oder in der
	  Beschreibung (z. B. „Love“, „War“, „Adventure“)?
	  Fasse gruppiert nach Keyword.
	  
-- 10. Identifiziere mindestens 3 weitere interessante Fragestellungen und
       beantworte sie (z. B. Kombinationen von Genres, Entwicklung von Genre-Shares
       über Jahren, Verhältnis von Filmen zu Serien pro Jahr, Ähnlichkeit zwischen
       Genres/Produzenten).

-- Verhältnis Filme zu Serien pro Jahr
-- Welche Länder haben die meisten Inhalte?
-- Welche Genres haben im Durchschnitt die höchste IMDb-Bewertung

/* 
View 1: Inhalte je Jahr
CREATE OR REPLACE VIEW vw_titles_per_year AS
SELECT
    release_year,
    COUNT(*) AS anzahl_titel
FROM title
GROUP BY release_year;

View 2: Top-Genres
CREATE OR REPLACE VIEW vw_genre_counts AS
SELECT
    g.genre_name,
    COUNT(*) AS anzahl_titel
FROM title_genre tg
JOIN genre g
    ON tg.genre_id = g.genre_id
GROUP BY g.genre_name;

View 3: Inhalte nach Typ
CREATE OR REPLACE VIEW vw_titles_by_type AS
SELECT
    tt.type_name,
    COUNT(*) AS anzahl_titel
FROM title t
JOIN title_type tt
    ON t.type_id = tt.type_id
GROUP BY tt.type_name;
	   
(Optional: Erstelle Views, die für typische Analysen sinnvoll sind, z. B. „Top-10
Genres nach Anzahl“, „Inhalte je Jahr“, „Inhalte nach Dauer“.)

Bereite deine Ergebnisse in einer Präsentation (15–20 Minuten) auf.

Präsentiere dabei besonders die Struktur deines Datenmodells, zentrale SQL-Abfragen und deine wichtigsten Erkenntnisse.

Viel Erfolg!   */
