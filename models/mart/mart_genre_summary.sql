
{{ config(materialized = 'table') }}

WITH movies AS (
SELECT * FROM {{ ref('dim_movies') }}
),
ratings AS (
SELECT * FROM {{ ref('fct_ratings') }}
)


SELECT
genre.value::STRING AS genre,
COUNT(DISTINCT m.movie_id) AS movie_count,
ROUND(AVG(r.rating), 2) AS avg_rating,
COUNT(r.user_id) AS total_ratings
FROM movies m
LEFT JOIN ratings r 
    ON m.movie_id = r.movie_id
, LATERAL FLATTEN(input => m.genre_array) genre
WHERE genre.value::STRING != '(no genres listed)'
GROUP BY genre.value::STRING
ORDER BY total_ratings DESC