-- CREATE DATABASE:
CREATE DATABASE public_db;

-- CREATE TABLE:
DROP TABLE spotify IF EXISTS;

CREATE TABLE spotify
	(artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    streams BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50));


-- EDA (Exploratory Data Analysis):
SELECT * FROM spotify LIMIT 1000;

SELECT COUNT(*) FROM spotify;  -- 20,592

SELECT COUNT(album) FROM spotify;  -- 20,592
SELECT COUNT(DISTINCT album) FROM spotify;  -- 11,852

SELECT DISTINCT artist FROM spotify;

SELECT COUNT(DISTINCT artist) FROM spotify;  -- 2,074

SELECT DISTINCT album_type FROM spotify;

SELECT DISTINCT most_played_on FROM spotify;

SELECT MAX(duration_min) FROM spotify;  -- 77.9343

SELECT MIN(duration_min) FROM spotify;  -- 0.5164

SELECT * FROM spotify
WHERE duration_min = 0;

DELETE FROM spotify
WHERE duration_min = 0;

SELECT * FROM spotify
WHERE duration_min = 0;

SELECT DISTINCT channel FROM spotify;

SELECT COUNT(DISTINCT channel) FROM spotify;  -- 6,673


-------------------------------
-- DATA ANALYSIS \\ EASY TYPE |
-------------------------------
-- QUESTIONS:
/*
1. Retrieve the names of all tracks that have more than 1 billion streams.
2. List all albums along with their respective artists.
3. Get the total number of comments for tracks where licensed = TRUE.
4. Find all tracks that belong to the album type single.
5. Count the total number of tracks by each artist.
6. Write a query to find all tracks where the artist is 'Coldplay' and the album_type is 'album'.
7. Write a query to list the top 10 most energetic tracks (energy) that are also highly danceable
   (danceability > 0.8), ordered by energy from highest to lowest.
8. Find the total number of views and likes for all tracks uploaded by the channel 'Official YouTube'.
9. Write a query to find all tracks that are shorter than 2 minutes (duration_min < 2.0).
   Return the track, artist, and duration_min, ordered by duration from shortest to longest.
*/

-- Q1. Retrieve the names of all tracks that have more than 1 billion streams.
SELECT
	track,
	streams
FROM spotify
WHERE streams > 1000000000;


-- Q2. List all albums along with their respective artists.
SELECT DISTINCT
		album,
		artist
FROM spotify;


-- Q3. Get the total number of comments for tracks where licensed = TRUE.
SELECT
	track,
	SUM(comments) AS total_comments
FROM spotify
WHERE licensed = True
GROUP BY track
ORDER BY total_comments DESC;
-- OR --
SELECT SUM(comments) ROM spotify WHERE licensed = True;


-- Q4. Find all tracks that belong to the album type single.
SELECT
	track,
	album_type
FROM spotify
WHERE album_type = 'single';


-- Q5. Count the total number of tracks by each artist.
SELECT
	artist,
	COUNT(track) AS total_tracks
FROM spotify
GROUP BY artist
ORDER BY total_tracks;


-- Q6. Write a query to find all tracks where the artist is 'Coldplay' and the album_type is 'album'.
SELECT
	artist,
	track,
	album_type
FROM spotify
WHERE artist = 'Coldplay'
	AND
	album_type = 'album';


-- Q7. Write a query to list the top 10 most energetic tracks (energy) that are also highly danceable
--     (danceability > 0.8), ordered by energy from highest to lowest.
SELECT
	artist,
	track,
	energy
FROM spotify
WHERE danceability > 0.8
ORDER BY energy DESC
LIMIT 10;


-- Q8. Find the total number of views and likes for all tracks uploaded by the channel 'Official YouTube'.
SELECT
	artist,
	track,
	SUM(views) as total_views,
	SUM(likes) as total_likes
FROM spotify
WHERE channel = 'T-Series'
GROUP BY artist, track;


-- Q9. Write a query to find all tracks that are shorter than 2 minutes (duration_min < 2.0).
--	   Return the track, artist, and duration_min, ordered by duration from shortest to longest.
SELECT
	artist,
	track,
	duration_min
FROM spotify
WHERE duration_min < 2.0
ORDER BY duration_min ASC;


---------------------------------
-- DATA ANALYSIS \\ MEDIUM TYPE |
---------------------------------
-- QUESTIONS:
/*
10. Calculate the average danceability of tracks in each album.
11. Find the top 5 tracks with the highest energy values.
12. List all tracks along with their views and likes where official_video = TRUE.
13. For each album, calculate the total views of all associated tracks.
14. Retrieve the track names that have been streamed on Spotify more than YouTube.
15. Write a query to count how many tracks are primarily played on Spotify versus YouTube
	using the most_played_on column. Group the results by the platform.
16. For each artist, calculate their average danceability and total streams,
	but only include artists who have more than 3 tracks in the database.
*/

-- Q10. Calculate the average danceability of tracks in each album.
SELECT
	album,
	ROUND(
		AVG(danceability):: NUMERIC, 4  -- Either use sql in-built CAST() function  
		 ) AS avg_danceability
FROM spotify
GROUP BY album;


-- Q11. Find the top 5 tracks with the highest energy values.
SELECT
	track,
	energy
FROM spotify
ORDER BY energy DESC
LIMIT 5;


-- Q12. List all tracks along with their views and likes where official_video = TRUE.
SELECT
	track,
	SUM(views) AS total_views,
	SUM(likes) AS total_likes
FROM spotify
WHERE official_video = True
GROUP BY track
ORDER BY 2 DESC;


-- Q13. For each album, calculate the total views of all associated tracks.
SELECT
	album,
	track,
	SUM(views) AS total_views
FROM spotify
GROUP BY album, track
ORDER BY 3;


-- Q14. Retrieve the track names that have been streamed on Spotify more than YouTube.
SELECT * FROM
	(
	  SELECT
      	track,
	  	COALESCE(SUM(CASE WHEN most_played_on = 'Youtube'
					      THEN streams END), 0) AS streamed_on_youtube,
	  	COALESCE(SUM(CASE WHEN most_played_on = 'Spotify'
						  THEN streams END), 0) AS streamed_on_spotify
		FROM spotify
		GROUP BY track
	) AS tb_1
WHERE streamed_on_spotify > streamed_on_youtube
	AND
	streamed_on_youtube != 0;
-- OR --
SELECT track, streams FROM spotify
WHERE most_played_on = 'Spotify';


-- Q15. Write a query to count how many tracks are primarily played on Spotify versus YouTube
--		using the most_played_on column. Group the results by the platform.
SELECT
	most_played_on AS platform,
	COUNT(*) AS total_tracks
FROM spotify
WHERE most_played_on IN ('Spotify', 'Youtube')
GROUP BY platform;


-- Q16. For each artist, calculate their average danceability and total streams,
--		but only include artists who have more than 3 tracks in the database.
SELECT
	artist,
	ROUND(AVG(danceability) :: NUMERIC, 4) AS avg_danceability,
	SUM(streams) AS total_streams,
	COUNT(track) AS total_tracks
FROM spotify
GROUP BY artist
	HAVING COUNT(track) > 3
ORDER BY total_streams DESC;


------------------------------------
-- DATA ANALYTICS \\ ADVANCED TYPE |
------------------------------------
-- QUESTIONS:
/*
17. Find the top 3 most-viewed tracks for each artist using window functions.
18. Write a query to find tracks where the liveness score is above the average.
19. Use a WITH clause to calculate the difference between the highest and
	lowest energy values for tracks in each album.
20. Find tracks where the energy-to-liveness ratio is greater than 1.2.
21. Calculate the cumulative sum of likes for tracks ordered by the number of views,
	using window functions.
22. Write a query using a window function (ROW_NUMBER() or DENSE_RANK())
	to find the single most-streamed track for each artist.
23. Identify "acoustic outliers." Write a query to find tracks that have an
	acousticness score higher than the overall average acousticness of the entire
	dataset, but still manage to have a loudness greater than -5.
24. Write a query to calculate the percentage of total streams that come from 
	licensed tracks versus unlicensed tracks. Hint: Use a CASE WHEN statement
	inside a SUM() aggregation.
*/

-- 17. Find the top 3 most-viewed tracks for each artist using window functions.
WITH ranking_artist
	AS (SELECT
			artist,
			track,
			SUM(views) AS total_views,
			DENSE_RANK() OVER (PARTITION BY artist ORDER BY SUM(views) DESC)
				AS ranked_artist
		FROM spotify
		GROUP BY artist, track
		ORDER BY artist, 3 DESC
		)
SELECT * FROM ranking_artist
WHERE ranked_artist <= 3;


-- Q18. Write a query to find tracks where the liveness score is above the average.
SELECT
	artist,
	track,
	liveness
FROM spotify
WHERE liveness > (
				SELECT AVG(liveness)
				FROM spotify
  				  );


-- Q19. Use a WITH clause to calculate the difference between the highest and
--		lowest energy values for tracks in each album.
WITH difference
		AS (SELECT
				album,
				MAX(energy) AS highest_energy,
				MIN(energy) AS lowest_energy
			FROM spotify
			GROUP BY album
			)
SELECT album,
	   (highest_energy - lowest_energy) AS diiference_in_energy
FROM difference;


-- 20. Find tracks where the energy-to-liveness ratio is greater than 1.2.
SELECT
	artist,
	track,
	energy,
	liveness,
	ROUND((energy / liveness) :: NUMERIC, 4) AS energy_2_liveness_ratio
FROM spotify
WHERE (energy / liveness) > 1.2
	AND
	liveness > 0    -- prevents division by zero
ORDER BY energy_2_liveness_ratio;


-- 21. Calculate the cumulative sum of likes for tracks ordered by the number of views,
--	   using window functions.
-- My answer: Which gives 19,926/20,592 rows
SELECT
	track,
	likes,
	SUM(views) AS total_views,
	SUM(likes) OVER (ORDER BY SUM(views) DESC) AS cumulative_likes
FROM spotify
GROUP BY track, likes;
-- OR --
-- Gemini-AI answer: Which gives 17,715 rows where it aggregates SUM-on-SUM SUM(SUM())
SELECT
	track,
	SUM(views) AS total_views,
	SUM(likes) AS total_likes,
	SUM(SUM(likes)) OVER (ORDER BY SUM(views) DESC) AS cumulative_likes
FROM spotify
GROUP BY track;


-- 22. Write a query using a window function (ROW_NUMBER() or DENSE_RANK())
--	   to find the single most-streamed track for each artist.
WITH ranking_track
	AS (SELECT
			artist,
			track,
			SUM(streams) AS total_streams,
			DENSE_RANK() OVER (PARTITION BY artist ORDER BY SUM(streams) DESC)
				AS ranking
		FROM spotify
		GROUP BY artist, track
		ORDER BY artist, 3 DESC
		)
SELECT * FROM ranking_track
WHERE ranking = 1;


-- 23. Identify "acoustic outliers." Write a query to find tracks that have an
--	   acousticness score higher than the overall average acousticness of the entire
--	   dataset, but still manage to have a loudness greater than -5.
SELECT
	track,
	acousticness,
	loudness
FROM spotify
WHERE acousticness > (SELECT ROUND(AVG(acousticness) :: NUMERIC, 4) FROM spotify)
	AND
	loudness > - 5
ORDER BY loudness DESC;


-- 24. Write a query to calculate the percentage of total streams that come from
--	   licensed tracks versus unlicensed tracks. Hint: Use a CASE WHEN statement
--	   inside a SUM() aggregation.
WITH percentage_cal
	AS (SELECT
			ROUND(
				SUM(CASE WHEN licensed = True
						 THEN streams ELSE 0 END) /
								(SUM(streams)) * 100 :: NUMERIC, 2) AS licensed_track,
			ROUND(
				SUM(CASE WHEN licensed = False
						 THEN streams ELSE 0 END) / 
				 				(SUM(streams)) * 100 :: NUMERIC, 2) AS unlicensed_track
		FROM spotify
		)
select * from percentage_cal;