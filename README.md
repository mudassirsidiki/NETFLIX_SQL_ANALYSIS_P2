# Netflix Movies and TV Shows Data Analysis using SQL

![Netflix Logo](https://github.com/mudassirsidiki/NETFLIX_SQL_ANALYSIS_P2/blob/main/logo.png)

# Netflix Data Analysis

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. 

The dataset includes attributes such as the title, director, cast, country, date added, release year, rating, duration, genres, and a brief description of the content. By performing a series of SQL queries, the project aims to uncover trends, patterns, and key metrics that can aid in understanding Netflix's content strategy.

---

## Objectives
- Analyze the distribution of content types (Movies vs. TV Shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Categorize content based on specific keywords in descriptions.
- Explore trends in genres and actor appearances.

---

## Dataset Schema
The `netflix` table is structured as follows:

| Column Name    | Data Type   | Description |
|----------------|-------------|-------------|
| `show_id`      | VARCHAR(20) | Unique identifier for each show. |
| `movie_type`   | VARCHAR(20) | Type of content (Movie/TV Show). |
| `title`        | VARCHAR(250)| Title of the content. |
| `director`     | VARCHAR(550)| Director(s) of the content. |
| `casts`        | VARCHAR(1050)| Cast members of the content. |
| `country`      | VARCHAR(550)| Country where the content was produced. |
| `date_added`   | VARCHAR(55) | Date the content was added to Netflix. |
| `release_year` | INT         | Year the content was released. |
| `rating`       | VARCHAR(15) | Content rating (e.g., PG, R). |
| `duration`     | VARCHAR(15) | Duration of the content (e.g., 90 min, 3 Seasons). |
| `listed_in`    | VARCHAR(250)| Genres/categories the content belongs to. |
| `description`  | VARCHAR(550)| A brief description of the content. |

---

## Key Queries and Insights

###  Data Cleaning
To ensure data consistency and remove incomplete entries, we identified records with missing or null values:
```sql
SELECT *
FROM netflix
WHERE show_id IS NULL OR show_id = ''
   OR movie_type IS NULL OR movie_type = ''
   OR title IS NULL OR title = ''
   OR director IS NULL OR director = ''
   OR casts IS NULL OR casts = ''
   OR country IS NULL OR country = ''
   OR date_added IS NULL OR date_added = ''
   OR rating IS NULL OR rating = ''
   OR duration IS NULL OR duration = ''
   OR listed_in IS NULL OR listed_in = ''
   OR description IS NULL OR description = '';
```

## Business Questions and SQL Queries

### 1. Count the number of Movies vs TV Shows
```sql
SELECT movie_type, COUNT(*) AS count
FROM netflix
GROUP BY movie_type;
```
**Insight**: This query helps in understanding the distribution of content types on Netflix.

---

### 2. Find the most common rating for movies and TV shows
```sql
SELECT movie_type, rating, COUNT(*) AS count
FROM netflix
GROUP BY movie_type, rating
ORDER BY movie_type, count DESC
LIMIT 2;
```
**Insight**: Identifies the most prevalent ratings for movies and TV shows separately.

---

### 3. List all movies released in a specific year (e.g., 2020)
```sql
SELECT *
FROM netflix
WHERE release_year = 2020 AND movie_type = 'Movie';
```
**Insight**: Retrieves all movies released in a specific year.

---

### 4. Find the top 5 countries with the most content on Netflix
```sql
SELECT *
FROM
(
    SELECT 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
        COUNT(*) AS total_content
    FROM netflix
    WHERE country IS NOT NULL AND country <> ''
    GROUP BY 1
) AS t1
ORDER BY total_content DESC
LIMIT 5;
```
**Insight**: Highlights the top 5 countries contributing the most content.

---

### 5. Identify the longest movie
```sql
SELECT title, duration
FROM netflix
WHERE movie_type = 'Movie' AND duration LIKE '%min%'
ORDER BY CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) DESC
LIMIT 1;
```
**Insight**: Finds the longest movie based on duration.

---

### 6. Find content added in the last 5 years
```sql
SELECT title, date_added
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= (CURRENT_DATE - INTERVAL '5 years');
```
**Insight**: Lists content added in the recent 5 years.

---

### 7. Find all the movies/TV shows by director 'Rajiv Chilaka'
```sql
SELECT title, movie_type
FROM netflix
WHERE director = 'Rajiv Chilaka';
```
**Insight**: Fetches all content directed by Rajiv Chilaka.

---

### 8. List all TV shows with more than 5 seasons
```sql
SELECT title, duration
FROM netflix
WHERE movie_type = 'TV Show' AND CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) > 5;
```
**Insight**: Identifies TV shows with more than 5 seasons.

---

### 9. Count the number of content items in each genre
```sql
SELECT genre, COUNT(*) AS total_content
FROM 
(
    SELECT UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre
    FROM netflix
    WHERE listed_in IS NOT NULL AND listed_in <> ''
) AS t1
GROUP BY genre
ORDER BY total_content DESC;
```
**Insight**: Categorizes content based on genres and counts them.

---

### 10. Find each year and the average number of content releases in India (Top 5 years)
```sql
SELECT release_year, AVG(total_content) AS avg_content
FROM 
(
    SELECT release_year, COUNT(*) AS total_content
    FROM netflix
    WHERE country LIKE '%India%'
    GROUP BY release_year
) AS yearly_data
GROUP BY release_year
ORDER BY avg_content DESC
LIMIT 5;
```
**Insight**: Determines years with the highest average content releases in India.

---

### 11. List all movies that are documentaries
```sql
SELECT title
FROM netflix
WHERE movie_type = 'Movie' AND listed_in LIKE '%Documentaries%';
```
**Insight**: Fetches all movies classified as documentaries.

---

### 12. Find all content without a director
```sql
SELECT *
FROM netflix
WHERE director IS NULL;
```
**Insight**: Identifies content missing director information.

---

### 13. Find how many movies actor 'Salman Khan' appeared in the last 10 years
```sql
SELECT *
FROM netflix
WHERE movie_type = 'Movie' AND casts LIKE '%Salman Khan%' AND release_year >= (EXTRACT(YEAR FROM CURRENT_DATE) - 10);
```
**Insight**: Shows Salman Khan's movie appearances in the last decade.

---

### 14. Find the top 10 actors with the highest number of movies produced in India
```sql
SELECT actor, COUNT(*) AS total_movies
FROM 
(
    SELECT UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor
    FROM netflix
    WHERE movie_type = 'Movie' AND country LIKE '%India%' AND casts IS NOT NULL
) AS actor_data
GROUP BY actor
ORDER BY total_movies DESC
LIMIT 10;
```
**Insight**: Ranks actors based on movie appearances in Indian productions.

---

### 15. Categorize content based on keywords 'kill' and 'violence'
```sql
SELECT 
    CASE 
        WHEN LOWER(description) LIKE '%kill%' OR LOWER(description) LIKE '%violence%' THEN 'Bad'
        ELSE 'Good'
    END AS category,
    COUNT(*) AS total_content
FROM netflix
GROUP BY category;
```
**Insight**: Classifies content as 'Bad' or 'Good' based on keywords in the description.

---

## Tools and Technologies
- **SQL**: PostgreSQL for querying and analysis.

---

## Conclusions
This project provided valuable insights into Netflix's content library, such as:
- Movies dominate Netflix's library compared to TV Shows.
- The most common genres include Drama, Comedy, and Action.
- India contributes significantly to Netflix's content.
