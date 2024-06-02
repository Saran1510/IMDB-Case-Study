USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/



-- Segment 1:




-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:
select count(*) from movie;
-- 7997

select count(*) from genre;
-- 14662


select count(*) from names;
-- 25735

select count(*) from ratings;
-- 7997

select count(*) from director_mapping;
-- 3867

select count(*) from role_mapping;
-- 15615








-- Q2. Which columns in the movie table have null values?
-- Type your code below:
SELECT SUM(CASE
                WHEN id IS NULL THEN 1
                ELSE 0 END) AS id_null_counts,
       SUM(CASE
                WHEN title IS NULL THEN 1
                ELSE 0 END) AS title_null_counts,
       SUM(CASE
                WHEN date_published IS NULL THEN 1
                ELSE 0 END) AS date_null_counts,
       SUM(CASE
                WHEN duration IS NULL THEN 1
                ELSE 0 END) AS duration_null_counts,
       SUM(CASE
                WHEN country IS NULL THEN 1
                ELSE 0 END) AS country_null_counts,
       SUM(CASE
                WHEN worlwide_gross_income IS NULL THEN 1
                ELSE 0 END) AS worlwide_gross_income_null_counts,
       SUM(CASE
                WHEN languages IS NULL THEN 1
                ELSE 0 END) AS languages_null_counts,
       SUM(CASE
                WHEN production_company IS NULL THEN 1
                ELSE 0 END) AS production_company_null_counts
  FROM movie;
-- As we can see the columns having null values are --> country, worlwide_gross_income, production_company, languages





-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)
/* Output format for the first part:


+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

-- Find the total number of movies released each year
SELECT
  year AS Year,
  COUNT(title) AS number_of_movies
FROM movie
GROUP BY year;


-- How does the trend look month wise
SELECT
  MONTH(date_published) AS month_num,
  COUNT(1) AS number_of_movies
FROM movie
GROUP BY month_num
ORDER BY month_num;





/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
SELECT
  COUNT(1) AS num_of_movies
FROM
  movie
WHERE
  (
    UPPER(country) LIKE '%INDIA%'
    OR 
    UPPER(country) LIKE '%USA%'
  )
  AND year = 2019;
-- Note :  movies = 1059




/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
SELECT
DISTINCT
  (genre)
FROM genre;
-- Notes : We notice 13 type of genres in the list




/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
SELECT
  movies_count,
  genre
FROM (
	SELECT
	  COUNT(genre) AS movies_count,
	  genre,
	  ROW_NUMBER() OVER (ORDER BY COUNT(genre) DESC) AS genre_row_num
	FROM movie m
	INNER JOIN genre g
	  ON m.id = g.movie_id
	GROUP BY genre
) AS a
WHERE genre_row_num = 1;
-- Note : Drama with 4285 movies




/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
WITH single_genre_movies
AS (SELECT
  movie_id,
  COUNT(genre) AS genre_count
FROM genre
GROUP BY movie_id
HAVING genre_count = 1)
SELECT
  COUNT(*) AS single_genre_movies_count
FROM single_genre_movies;
-- Note : there are 3289 movies with single genre







/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
SELECT
  genre,
  ROUND(AVG(duration), 2) AS avg_duration
FROM movie AS m
INNER JOIN genre AS g
  ON m.id = g.movie_id
GROUP BY genre
ORDER BY avg_duration DESC;
-- Note : Action genre has highest avg duration followed by Romance. Horror is the least 






/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			 |	2312			  |			2		      |
+---------------+-------------------+---------------------+*/
SELECT
  genre,
  movie_count,
  genre_rank
FROM (SELECT
  COUNT(genre) AS movie_count,
  genre,
  RANK() OVER (ORDER BY COUNT(genre) DESC) AS genre_rank
FROM movie m
INNER JOIN genre g
  ON m.id = g.movie_id
GROUP BY genre) AS genre_ranking
WHERE UPPER(genre) = 'THRILLER';
-- Note : Thriller has a rank of 3 with movie count = 1484




/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/


-- Segment 2:

-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
SELECT
  MIN(avg_rating) AS min_avg_rating,
  MAX(avg_rating) AS max_avg_rating,
  MIN(total_votes) AS min_total_votes,
  MAX(total_votes) AS max_total_votes,
  MIN(median_rating) AS min_median_rating,
  MAX(median_rating) AS max_median_rating
FROM ratings;




    

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
WITH movie_ranking AS (
  SELECT
    title,
    avg_rating,
    ROW_NUMBER() OVER (
      ORDER BY
        avg_rating DESC
    ) AS movie_rank
  FROM
    ratings AS r
    INNER JOIN movie AS m 
		ON m.id = r.movie_id
)
SELECT
  *
FROM
  movie_ranking
WHERE
  movie_rank <= 10;
-- Note : there is more than one movie sharing the same avg_rating as is seen using RANK and would return 15 rows. We decide to use row_number to return top 10 movies as asked in the question.





/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
SELECT
  median_rating,
  COUNT(median_rating) AS movie_count
FROM ratings AS r
INNER JOIN movie AS m
  ON m.id = r.movie_id
GROUP BY median_rating
ORDER BY median_rating;




/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
WITH production_company_hit_movie_ranking AS (
  SELECT
    production_company,
    COUNT(id) AS movie_count,
    RANK() OVER (
      ORDER BY
        COUNT(id) DESC
    ) AS prod_company_rank
  FROM
    ratings AS r
    INNER JOIN movie AS m ON m.id = r.movie_id
  WHERE
    avg_rating > 8
    AND production_company IS NOT NULL
  GROUP BY
    production_company
)
SELECT
  *
FROM
  production_company_hit_movie_ranking
WHERE
  prod_company_rank = 1;




-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both



-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
SELECT
  genre,
  COUNT(genre) AS movie_count
FROM
  movie AS m
  INNER JOIN genre AS g ON g.movie_id = m.id
  INNER JOIN ratings AS r ON r.movie_id = m.id
WHERE
  MONTH(date_published) = 3
  AND YEAR(date_published) = 2017
  AND UPPER(country) LIKE '%USA%'
  AND total_votes > 1000
GROUP BY
  genre
ORDER BY
  movie_count DESC;








-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
SELECT
  title,
  avg_rating,
  genre
FROM movie AS m
INNER JOIN genre AS g
  ON g.movie_id = m.id
INNER JOIN ratings AS r
  ON r.movie_id = m.id
WHERE title LIKE 'The%'
AND avg_rating > 8
ORDER BY avg_rating DESC;




-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:


SELECT
  COUNT(1) AS movie_count_median_rating_8
FROM
  movie AS m
  INNER JOIN ratings AS r 
  ON r.movie_id = m.id
WHERE
  date_published BETWEEN '2018-04-01' AND '2019-04-01'
  AND median_rating = 8
GROUP BY
  median_rating;





-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:

-- This problem can be approached from Languages as well as country column.
--  A) Langauge 
--    		When done from language level, we notice there are some movies with the only language, but there are some multi-lingual movies also. 
-- 			So in the query below we consider multilingual movies having also that have German as a language in it using like% clause
-- 			This shows German movies get more votes
(
  WITH german_movies as (
    SELECT
      id,
      total_votes,
      'german' as language
    FROM
      MOVIE AS M
      INNER JOIN RATINGS AS R ON R.MOVIE_ID = M.ID
    WHERE
      UPPER(languages) like '%GERMAN%'
  )
  SELECT
    sum(total_votes) as total,
    language
  FROM
    german_movies
  group by
    language
)
Union
(
  WITH intialian_movies as (
    SELECT
      id,
      total_votes,
      'Italian' as language
    FROM
      MOVIE AS M
      INNER JOIN RATINGS AS R ON R.MOVIE_ID = M.ID
    WHERE
      UPPER(languages) like '%ITALIAN%'
  )
  SELECT
    sum(total_votes) as total,
    language
  FROM
    intialian_movies
  group by
    language
);

-- B)  Country 
-- 		B1) Here we select those rows which have Germany or Italy as the only country 
-- 		We notice Germany movies get more votes
SELECT country, sum(total_votes) as total_votes
FROM movie AS m
	INNER JOIN ratings as r ON m.id=r.movie_id
WHERE UPPER(country) = 'GERMANY' or UPPER(country) = 'ITALY'
GROUP BY country;


--  B2) Here we select those rows which have Germany or Italy as one of the  only country / countries  
-- 		 We notice Germany movies get more votes
(
  WITH german_movies as (
    SELECT
      id,
      total_votes,
      'Germany' as country
    FROM
      MOVIE AS M
      INNER JOIN RATINGS AS R ON R.MOVIE_ID = M.ID
    WHERE
      UPPER(country) like '%GERMANY%'
  )
  SELECT
    sum(total_votes) as total,
    country
  FROM
    german_movies
  group by
    country
)
Union
(
  WITH intialian_movies as (
    SELECT
      id,
      total_votes,
      'Italy' as country
    FROM
      MOVIE AS M
      INNER JOIN RATINGS AS R ON R.MOVIE_ID = M.ID
    WHERE
      UPPER(country) like '%ITALY%'
  )
  SELECT
    sum(total_votes) as total,
    country
  FROM
    intialian_movies
  group by
    country
);
-- Answer is Yes when appraoched from different ways as shown above.






/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/


-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
SELECT
  SUM(CASE
    WHEN name IS NULL THEN 1
    ELSE 0
  END) AS name_nulls,
  SUM(CASE
    WHEN height IS NULL THEN 1
    ELSE 0
  END) AS height_nulls,
  SUM(CASE
    WHEN date_of_birth IS NULL THEN 1
    ELSE 0
  END) AS date_of_birth_nulls,
  SUM(CASE
    WHEN known_for_movies IS NULL THEN 1
    ELSE 0
  END) AS known_for_movies_nulls
FROM names;





/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
WITH top_3_genres AS(
  WITH top_genre AS(
    SELECT
      genre,
      COUNT(1) AS movie_count,
      RANK() OVER(
        ORDER BY
          COUNT(1) DESC
      ) AS genre_rank
    FROM
      movie AS m
      INNER JOIN ratings AS r ON r.movie_id = m.id
      INNER JOIN genre AS g ON g.movie_id = m.id
    WHERE
      avg_rating > 8
    GROUP BY
      genre
  )
  SELECT
    genre
  FROM
    top_genre
  WHERE
    genre_rank <= 3
),
top_director_rankings as (
  SELECT
    n.name AS director_name,
    Count(1) AS movie_count,
    ROW_NUMBER() OVER(
      ORDER BY
        COUNT(1) DESC
    ) AS director_rank
  FROM
    director_mapping AS d
    INNER JOIN genre g on d.movie_id = g.movie_id
    INNER JOIN names AS n ON n.id = d.name_id
    INNER JOIN top_3_genres as t ON t.genre = g.genre
    INNER JOIN ratings as r on r.movie_id = g.movie_id
  WHERE
    avg_rating > 8
  GROUP BY
    name
)
select
  director_name,
  movie_count
from
  top_director_rankings
where
  director_rank <= 3;
-- Note : James Mangold, Anthony Russo and Joe Russo and the top three directors with this criteria




/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
WITH actor_rankings AS (
  SELECT
    name AS actor_name,
    COUNT(1) AS movie_count,
    RANK() OVER (
      ORDER BY
        COUNT(1) DESC
    ) AS actor_rank
  FROM
    role_mapping AS rm
    INNER JOIN movie AS m ON m.id = rm.movie_id
    INNER JOIN names AS n ON n.id = rm.name_id
    INNER JOIN ratings AS r ON r.movie_id = m.id
  WHERE
    r.median_rating >= 8
    AND category = 'actor'
  GROUP BY
    actor_name
)
SELECT
  actor_name,
  movie_count
FROM
  actor_rankings
WHERE
  actor_rank < 3;
-- Mammootty and Mohanlal



/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/



-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
WITH prod_company_ranking AS (
  SELECT
    production_company,
    SUM(total_votes) AS vote_count,
    RANK() OVER (
      ORDER BY
        SUM(total_votes) DESC
    ) AS prod_comp_rank
  FROM
    movie AS m
    INNER JOIN ratings AS r ON r.movie_id = m.id
  WHERE 
     production_company is NOT NULL
  GROUP BY
    production_company
)
SELECT
  *
FROM
  prod_company_ranking
WHERE
  prod_comp_rank < 4;
-- Note : -- Top three production houses based on criteria of number of votes received : Marvel Studios, Twentieth Century Fox and Warner Bros.


/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
WITH actor_movie_ratings AS (
  SELECT
    name AS actor_name,
    SUM(total_votes) AS total_votes,
    COUNT(1) AS movie_count,
    ROUND(SUM(avg_rating * total_votes) / SUM(total_votes), 2) AS actor_avg_rating
  FROM
    movie AS m
    INNER JOIN ratings AS r ON m.id = r.movie_id
    INNER JOIN role_mapping AS rm ON m.id = rm.movie_id
    INNER JOIN names AS n ON rm.name_id = n.id
  WHERE
    category = 'ACTOR'
    AND UPPER(country) = 'INDIA'
  GROUP BY
    NAME
  HAVING
    movie_count >= 5
)
SELECT
  actor_name,
  total_votes,
  movie_count,
  actor_avg_rating,
  RANK() OVER (
    ORDER BY
      actor_avg_rating DESC
  ) AS actor_rank
FROM
  actor_movie_ratings;
-- Top actor is Vijay Sethupathi






-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

-- (A) First attempt is made when the movie has single langaueg = Hindi, but here we notice, only 4 actresses make it to the list.

WITH actor_movie_ratings AS (
  SELECT
    name AS actor_name,
    SUM(total_votes) AS total_votes,
    COUNT(1) AS movie_count,
    ROUND(SUM(avg_rating * total_votes) / SUM(total_votes), 2) AS actor_avg_rating
  FROM
    movie AS m
    INNER JOIN ratings AS r ON m.id = r.movie_id
    INNER JOIN role_mapping AS rm ON m.id = rm.movie_id
    INNER JOIN names AS n ON rm.name_id = n.id
  WHERE
    category = 'actress'
    AND UPPER(country) = 'INDIA'
    AND UPPER(languages) = 'HINDI'
  GROUP BY
    NAME
  HAVING
    movie_count >= 3
)
SELECT
  actor_name,
  total_votes,
  movie_count,
  actor_avg_rating,
  RANK() OVER (
    ORDER BY
      actor_avg_rating DESC
  ) AS actor_rank
FROM
  actor_movie_ratings;

-- (B) We also attempt including Multi-lingual movies with Hindi
WITH actor_movie_ratings AS (
  SELECT
    name AS actor_name,
    SUM(total_votes) AS total_votes,
    COUNT(1) AS movie_count,
    ROUND(SUM(avg_rating * total_votes) / SUM(total_votes), 2) AS actor_avg_rating
  FROM
    movie AS m
    INNER JOIN ratings AS r ON m.id = r.movie_id
    INNER JOIN role_mapping AS rm ON m.id = rm.movie_id
    INNER JOIN names AS n ON rm.name_id = n.id
  WHERE
    category = 'actress'
    AND UPPER(country) = 'INDIA'
    AND UPPER(languages) like '%HINDI%'
  GROUP BY
    NAME
  HAVING
    movie_count >= 3
)
SELECT
  actor_name,
  total_votes,
  movie_count,
  actor_avg_rating,
  RANK() OVER (
    ORDER BY
      actor_avg_rating DESC
  ) AS actor_rank
FROM
  actor_movie_ratings;


/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
WITH thriller_movies AS (
  SELECT
    title,
    avg_rating
  FROM
    genre as g
    INNER JOIN movie AS m ON g.movie_id = m.id
    INNER JOIN ratings AS r ON m.id = r.movie_id
  WHERE
    genre = 'thriller'
)
SELECT
  title,
  avg_rating,
  CASE
    WHEN avg_rating > 8 THEN 'Superhit movies'
    WHEN avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
    WHEN avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
    ELSE 'Flop movies'
  END AS category
FROM
  thriller_movies;









/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
SELECT
  genre,
  ROUND(AVG(duration), 2) AS avg_duration,
  SUM(ROUND(AVG(duration), 2)) OVER (
    ORDER BY
      genre ROWS UNBOUNDED PRECEDING
  ) AS running_total_duration,
  AVG(ROUND(AVG(duration), 2)) OVER (
    ORDER BY
      genre ROWS 12 PRECEDING
  ) AS moving_avg_duration
FROM
  movie AS m
  INNER JOIN genre AS g ON m.id = g.movie_id
GROUP BY
  genre
ORDER BY
  genre;









-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies
WITH top_3_genres AS (
	  WITH top_genres AS (
			SELECT
			  genre,
			  COUNT(title) AS movie_count,
			  RANK() OVER (
				ORDER BY
				  COUNT(title) DESC
			  ) AS genre_rank
			FROM
			  movie AS m
			  INNER JOIN ratings AS r ON r.movie_id = m.id
			  INNER JOIN genre AS g ON g.movie_id = m.id
			GROUP BY
			  genre
	  )
	  SELECT
			genre
	  FROM
			top_genres
	  WHERE
			genre_rank < 4
),
top_movies AS (
  SELECT
		genre,
		year,
		title AS movie_name,
		CAST(
		  REPLACE(IFNULL(worlwide_gross_income, 0), '$', '') AS DECIMAL(10)  -- Replace missing with 0 and Remove $ sign
		) AS worlwide_gross_income,
		
		DENSE_RANK() OVER (
		  PARTITION BY year
		  ORDER BY
			CAST(
			  REPLACE(IFNULL(worlwide_gross_income, 0), '$', '') AS DECIMAL(10)
			) DESC
		) AS movie_rank
  FROM
		movie AS m
		INNER JOIN genre AS g ON m.id = g.movie_id
  WHERE
		genre IN (
		  SELECT
			genre
		  FROM
			top_3_genres
		)
)
SELECT
	*
FROM
	top_movies
WHERE
	movie_rank <= 5
ORDER BY YEAR;






-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:
WITH top_production_houses AS (
  SELECT
    production_company,
    COUNT(1) AS movie_count,
    RANK() OVER (
      ORDER BY
        COUNT(1) DESC
    ) AS prod_comp_rank
  FROM
    movie AS m
    INNER JOIN ratings AS r ON m.id = r.movie_id
  WHERE
    median_rating >= 8
    AND production_company IS NOT NULL
    AND LOCATE(',', languages) > 0 -- check presence of ',' in the languages which make it multilingual
  GROUP BY
    production_company
)
SELECT
  production_company,
  movie_count,
  prod_comp_rank
FROM
  top_production_houses
WHERE
  prod_comp_rank < 3;







-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
WITH top_actresses AS(
  SELECT
    name AS actress_name,
    SUM(total_votes) AS total_votes,
    COUNT(1) AS movie_count,
    ROUND(SUM(avg_rating * total_votes) / SUM(total_votes), 2) AS actress_avg_rating,
    RANK() OVER(
      ORDER BY
        COUNT(1) DESC
    ) AS actress_rank
  FROM
    genre AS g
    INNER JOIN movie AS m ON g.movie_id = m.id
    INNER JOIN ratings AS r ON m.id = r.movie_id
    INNER JOIN role_mapping AS rm ON m.id = rm.movie_id
    INNER JOIN names AS n ON rm.name_id = n.id
  WHERE
    genre = 'drama'
    AND avg_rating > 8
    AND category = 'actress'
  GROUP BY
    name
)
SELECT
  *
FROM
  top_actresses
WHERE
  actress_rank <= 3;








/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
WITH next_date_published_rows AS (
  SELECT
    d.name_id,
    name,
    d.movie_id,
    duration,
    r.avg_rating,
    total_votes,
    m.date_published,
    avg_rating * total_votes AS rating_count,
    LEAD(date_published, 1) OVER (
      PARTITION BY d.name_id
      ORDER BY
        date_published,
        movie_id
    ) AS next_date_published
  FROM
    director_mapping AS d
    INNER JOIN names AS n ON n.id = d.name_id
    INNER JOIN movie AS m ON m.id = d.movie_id
    INNER JOIN ratings AS r ON r.movie_id = m.id
),
next_date_published_difference AS (
  SELECT
    *,
    DATEDIFF(next_date_published, date_published) AS date_difference
  FROM
    next_date_published_rows
),
top_directors as (
  SELECT
    name_id AS director_id,
    NAME AS director_name,
    COUNT(movie_id) AS number_of_movies,
    ROUND(AVG(date_difference)) AS avg_inter_movie_days,
    CAST(SUM(rating_count) / SUM(total_votes) AS decimal(4, 2)) AS avg_rating,
    SUM(total_votes) AS total_votes,
    MIN(avg_rating) AS min_rating,
    MAX(avg_rating) AS max_rating,
    SUM(duration) AS total_duration,
    ROW_NUMBER() OVER (
      ORDER BY
        COUNT(movie_id) DESC
    ) AS row_num
  FROM
    next_date_published_difference
  GROUP BY
    director_id
)
select
  director_id,
  director_name,
  number_of_movies,
  avg_inter_movie_days,
  avg_rating,
  total_votes,
  min_rating,
  max_rating,
  total_duration
from
  top_directors
where
  row_num < 10;





