# SQL Netflix Analysis
A structured SQL portfolio project transforming raw Netflix data into a relational model and actionable insights.

## 📊 Project Overview
This project explores Netflix titles and credits data using SQL.

The goal was to transform raw CSV data into a structured relational model, analyze the content catalog, and derive clear business-oriented insights from SQL queries.

The project focuses on:
- building a relational data model
- cleaning and standardizing raw data
- analyzing catalog structure and trends
- interpreting SQL-based results in a meaningful way

---

## 🧠 Analysis Questions
The purpose of this project was to answer questions such as:

- How is the Netflix catalog structured?
- What is the distribution of movies and series?
- Which genres occur most frequently?
- Which countries contribute the most titles?
- How has the catalog developed over time?
- Which directors, runtimes, season counts, and IMDb ratings stand out?

---

## 🛠️ Tools Used
- SQL
- PostgreSQL
- CSV data sources
- Relational data modeling
- Views for reusable analysis logic
- GitHub for documentation and project structure

---
## 💡 Key Skills Demonstrated
- SQL querying and aggregation
- relational data modeling (1:n, m:n)
- data cleaning and normalization
- analytical thinking and interpretation

## 📈 Example Analysis: Top Genres

### 🎯 Objective

Identify the most frequent genres in the Netflix catalog to understand content distribution and platform focus.

---

### 🧾 SQL Query

```sql
SELECT g.genre, COUNT(*) AS total_titles
FROM title_genre tg
JOIN genre g ON tg.genre_id = g.genre_id
GROUP BY g.genre
ORDER BY total_titles DESC;
```
This query calculates the number of titles per genre and highlights the most common genres in the dataset.

![Top Genres](docs/screenshots/top-genres.png)

---

### 📊 Result

The query returns the number of titles per genre, sorted by frequency.

![Top Genres](docs/screenshots/top-genres.png)

---

### 💡 Insight

- **Drama and Comedy dominate the catalog**, indicating a strong focus on mainstream audience preferences
- Genres like **Thriller and Action** maintain a solid presence, supporting diverse viewing options
- Lower-frequency genres (e.g. Fantasy, Family) highlight niche segments within the catalog
- The distribution suggests Netflix prioritizes widely appealing content while still offering variety
- The dominance of these genres reflects global viewing trends and high audience engagement formats

## 📊 Example Analysis: Movies vs. Series

### 🎯 Objective

Compare the distribution of movies and TV series in the dataset to understand the overall content structure.

---

### 🧾 SQL Query

```sql
SELECT type, COUNT(*) AS total_titles
FROM titles
GROUP BY type;
```

![Movies vs Series](docs/screenshots/movies-vs-series.png)

---

### 📊 Result

The query shows the total number of movies and TV series in the dataset.

![Movies vs Series](docs/screenshots/movies-vs-series.png)

---

### 💡 Insight

- Movies represent the majority of the catalog (~65%), while series account for ~35%
- This indicates a stronger focus on standalone content rather than episodic formats
- The imbalance suggests Netflix prioritizes scalable content production

## 🌍 Example Analysis: Top Countries

### 🎯 Objective

Identify which countries contribute the most titles to the Netflix catalog.

---

### 🧾 SQL Query

```sql
SELECT country, COUNT(*) AS total_titles
FROM titles
WHERE country IS NOT NULL
GROUP BY country
ORDER BY total_titles DESC
LIMIT 10;
```
This query identifies the countries with the highest number of titles in the dataset, highlighting where most Netflix content originates.

![Top Countries](docs/screenshots/top-countries.png)

---

### 📊 Result

The query returns the top 10 countries by number of titles.

![Top Countries](docs/screenshots/top-10-countries.png)

---

### 💡 Insight

- The United States dominates the catalog by a large margin
- India and the UK are strong secondary contributors
- This reflects both market size and Netflix’s regional expansion strategy

## 🗂️ Dataset
The project is based on cleaned Netflix titles and credits data stored in CSV files.

Main source files:
- `data/titles_clean.csv`
- `data/credits_clean.csv`

The raw data included several structural challenges, such as:
- multi-value attributes in genre, country, actor, and director
- missing or inconsistent values
- attributes that were not directly analysis-ready
- the need for plausibility checks and quality control

---

## 📚 Source / Reference
This project is based on the Netflix dataset project by Arpita Deb.

Original reference:
https://github.com/Arpita-deb/netflix-movies-and-tv-shows

This repository reflects my own adaptation and further development of the topic, including the relational schema, SQL analysis, presentation, and documentation for my SQL final project.

---

## ⚙️ Methodology
The workflow followed a structured process from raw data to analysis-ready SQL outputs:

1. Analyze the raw dataset
2. Import cleaned CSV data into PostgreSQL
3. Standardize data types and attribute values
4. Normalize the data into a relational structure
5. Define keys and relationships
6. Create reusable views for standard analysis
7. Run SQL queries and interpret the results

---

## 🏗️ Data Model

A relational schema was designed around the central `title` table to transform the raw Netflix dataset into an analysis-ready structure.

The original data contained several multi-value fields (e.g. genres, countries, actors), which were normalized into separate tables to ensure scalability and flexibility.

### 🔑 Key Design Decisions

- Separation of core entities such as `title`, `genre`, `country`, `actor`, and `director`
- Implementation of **1:n** relationships for attributes like `title_type` and `age_certification`
- Use of **m:n relationship tables** (e.g. `title_genre`, `title_actor`) to handle multi-value attributes
- Creation of a modular structure that supports efficient aggregation and filtering

---

### 🧱 Core Entities

- `title`
- `title_type`
- `age_certification`
- `genre`
- `country`
- `actor`
- `director`

---

### 🔗 Relationship Tables

- `title_genre`
- `title_country`
- `title_actor`
- `title_director`

---

### 🔄 Relationship Logic

- `title_type` and `age_certification` → **1:n relationships**
- `genre`, `country`, `actor`, `director` → **m:n relationships via bridge tables**

---

### 🖼️ Entity Relationship Diagram (ERD)

![Final ERD](docs/screenshots/final-erd.png)

This ERD visualizes the normalized database structure and highlights how entities are connected within the relational model.

---

## 🧩 Views Used
To simplify recurring SQL analyses, reusable views were created:

- `vw_titles_per_year` → number of titles per release year
- `vw_genre_counts` → genre frequencies in the dataset
- `vw_titles_by_type` → distribution of movies and series

Views helped encapsulate frequently used logic and made standard evaluations easier to reproduce.

---

## 📊 Key Insights
Some of the main findings from the project were:

- The dataset contains **5,806 titles** in total
- **65%** of the catalog consists of movies and **35%** of series
- The most frequent genres are **Drama**, **Comedy**, and **Thriller**
- The catalog is much more strongly represented in recent years
- The **USA** clearly dominates the dataset, followed by **India** and **Great Britain**
- Further analysis highlighted notable directors, unusually long movies, series with many seasons, genre trends, IMDb score patterns, and audience structure by age certification

---

## 📂 Project Structure
```text
SQL-Netflix/
├── README.md
├── data/
│   ├── credits_clean.csv
│   └── titles_clean.csv
├── sql/
│   ├── tasks.sql
│   ├── erd_setup.sql
│   └── queries.sql
└── docs/
    ├── netflix-presentation.pdf
    ├── project-task.pdf
    └── screenshots/
        ├── final-erd.png
        ├── movies-vs-series.png
        ├── top-countries.png
        └── top-genres.png
```








