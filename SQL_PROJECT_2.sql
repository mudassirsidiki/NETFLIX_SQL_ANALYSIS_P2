-- PROJECT NAME = Netflix Data Analysis

--------------------
-- CREATING DATABASE
--------------------
--ALREADY CREATED


------------------
-- CREATEING TABLE
------------------

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(20),
    movie_type   VARCHAR(20),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);


---------------
--DATA CLEANING
---------------

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


-----------------------------------------
-- Count the number of Movies vs TV Shows
-----------------------------------------

SELECT movie_type, COUNT(*) AS count
FROM netflix
GROUP BY movie_type;

------------------------------------------------------
-- Find the most common rating for movies and TV shows
------------------------------------------------------

SELECT movie_type, rating, COUNT(*) AS count
FROM netflix
GROUP BY movie_type, rating
ORDER BY movie_type, count DESC
LIMIT 2; -- Adjust for Movies and TV shows separately if needed

------------------------------------------------------
-- List all movies released in a specific year (e.g., 2020)
------------------------------------------------------

SELECT *
FROM netflix
WHERE release_year = 2020 AND movie_type = 'Movie';

-----------------------------------------------------------
-- Find the top 5 countries with the most content on Netflix
----------------------------------------------------------

SELECT * 
FROM
(
    SELECT 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
        COUNT(*) AS total_content
    FROM netflix
    WHERE country IS NOT NULL AND country <> ''  -- Filter before UNNEST
    GROUP BY 1
) AS t1
ORDER BY total_content DESC
LIMIT 5;

------------------------------------------------------
-- Identify the longest movie
------------------------------------------------------

SELECT title, duration
FROM netflix
WHERE movie_type = 'Movie' AND duration LIKE '%min%'
ORDER BY CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) DESC
LIMIT 1;

------------------------------------------------------
-- Find content added in the last 5 years
------------------------------------------------------

SELECT title, date_added
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= (CURRENT_DATE - INTERVAL '5 years');

------------------------------------------------------
-- Find all the movies/TV shows by director 'Rajiv Chilaka'!
------------------------------------------------------

SELECT title, movie_type
FROM netflix
WHERE director = 'Rajiv Chilaka';

------------------------------------------------------
-- List all TV shows with more than 5 seasons
------------------------------------------------------

SELECT title, duration
FROM netflix
WHERE movie_type = 'TV Show' AND CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) > 5;

------------------------------------------------------
-- Count the number of content items in each genre
------------------------------------------------------

SELECT genre, COUNT(*) AS total_content
FROM 
(
    SELECT UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre
    FROM netflix
    WHERE listed_in IS NOT NULL AND listed_in <> ''
) AS t1
GROUP BY genre
ORDER BY total_content DESC;

------------------------------------------------------------------------------------------------------------------------------
-- Find each year and the average numbers of content release in India on netflix return top 5 year with highest avg content release!
------------------------------------------------------------------------------------------------------------------------------

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

------------------------------------------------------
-- List all movies that are documentaries
------------------------------------------------------

SELECT title
FROM netflix
WHERE movie_type = 'Movie' AND listed_in LIKE '%Documentaries%';


------------------------------------------------------
-- Find all content without a director
------------------------------------------------------

SELECT *
FROM netflix
WHERE director IS NULL;

-----------------------------------------------------------------
-- Find how many movies actor 'Salman Khan' appeared in last 10 years!
-----------------------------------------------------------------

SELECT *
FROM netflix
WHERE movie_type = 'Movie' AND casts LIKE '%Salman Khan%' AND release_year >= (EXTRACT(YEAR FROM CURRENT_DATE) - 10);

-------------------------------------------------------------------------------------------
-- Find the top 10 actors who have appeared in the highest number of movies produced in India.
-------------------------------------------------------------------------------------------

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


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category. 
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT 
    CASE 
        WHEN LOWER(description) LIKE '%kill%' OR LOWER(description) LIKE '%violence%' THEN 'Bad'
        ELSE 'Good'
    END AS category,
    COUNT(*) AS total_content
FROM netflix
GROUP BY category;











