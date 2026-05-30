# Spotify-Data-Analytics-sql-project
Sql project - Analysing Spotify data to know the key insights!

<img width="1400" height="1050" alt="image" src="https://github.com/user-attachments/assets/f131c596-ed03-4588-9f6e-15b422fd6e49" />

## Overview
This project involves analyzing a Spotify dataset with various attributes about artists, tracks, and albums using SQL. It covers an end-to-end process of normalizing a denormalized dataset, performing SQL queries of varying complexity (easy, medium, and advanced). The primary goals of the project are to practice advanced SQL skills and generate valuable insights from the dataset.

``` sql
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
          most_played_on VARCHAR(50)
         );
```

## Porject steps
### 1. Data Exploration - EDA
Before diving into SQL, it’s important to understand the dataset thoroughly. The dataset contains attributes such as:

- Artist: The performer of the track.
- Track: The name of the song.
- Album: The album to which the track belongs.
- Album_type: The type of album (e.g., single or album).
- Various metrics such as danceability, energy, loudness, tempo, and more.

``` sql
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

```

### 2. Querying the data
After the data is inserted, various SQL queries can be written to explore and analyze the data. Queries are categorized into easy, medium, and advanced levels to help progressively develop SQL proficiency.

#### Easy Queries:
- Simple data retrieval, filtering, and basic aggregations.

#### Medium Queries:
- More complex queries involving grouping, aggregate functions, and joins.

#### Advanced Queries:
- Nested subqueries, window functions, CTEs...


## Practice Questions: 24Q
### Easy level:
1. Retrieve the names of all tracks that have more than 1 billion streams.
``` sql
SELECT
	track,
	streams
FROM spotify
WHERE streams > 1000000000;
```
2. List all albums along with their respective artists.
``` sql
SELECT DISTINCT
		album,
		artist
FROM spotify;
```
3. Get the total number of comments for tracks where licensed = TRUE.
``` sql
SELECT
	track,
	SUM(comments) AS total_comments
FROM spotify
WHERE licensed = True
GROUP BY track
ORDER BY total_comments DESC;
-- OR--
SELECT SUM(comments) FROM spotify WHERE licensed = True;
```
4. Find all tracks that belong to the album type single.
``` sql
SELECT
	track,
	album_type
FROM spotify
WHERE album_type = 'single';
```
5. Count the total number of tracks by each artist.
``` sql
SELECT
	artist,
	COUNT(track) AS total_tracks
FROM spotify
GROUP BY artist
ORDER BY total_tracks;
```
6. Write a query to find all tracks where the artist is 'Coldplay' and the album_type is 'album'.
``` sql
SELECT
	artist,
	track,
	album_type
FROM spotify
WHERE artist = 'Coldplay'
	AND
	album_type = 'album';
```
7. Write a query to list the top 10 most energetic tracks (energy) that are also highly danceable (danceability > 0.8), ordered by energy from highest to lowest.
``` sql
SELECT
	artist,
	track,
	energy
FROM spotify
WHERE danceability > 0.8
ORDER BY energy DESC
LIMIT 10;
```
8. Find the total number of views and likes for all tracks uploaded by the channel 'Official YouTube'.
``` sql
SELECT
	artist,
	track,
	SUM(views) as total_views,
	SUM(likes) as total_likes
FROM spotify
WHERE channel = 'T-Series'
GROUP BY artist, track;
```
9. Write a query to find all tracks that are shorter than 2 minutes (duration_min < 2.0). Return the track, artist, and duration_min, ordered by duration from shortest to longest.
``` sql
SELECT
	artist,
	track,
	duration_min
FROM spotify
WHERE duration_min < 2.0
ORDER BY duration_min ASC;
```

   ### Medium level:
10. Calculate the average danceability of tracks in each album.
``` sql
SELECT
	album,
	ROUND(
		AVG(danceability):: NUMERIC, 4  -- Either use sql in-built CAST() function  
		 ) AS avg_danceability
FROM spotify
GROUP BY album;
```
11. Find the top 5 tracks with the highest energy values.
``` sql
SELECT
	track,
	energy
FROM spotify
ORDER BY energy DESC
LIMIT 5;
```
12. List all tracks along with their views and likes where official_video = TRUE.
``` sql
SELECT
	track,
	SUM(views) AS total_views,
	SUM(likes) AS total_likes
FROM spotify
WHERE official_video = True
GROUP BY track
ORDER BY 2 DESC;
```
13. For each album, calculate the total views of all associated tracks.
``` sql
SELECT
	album,
	track,
	SUM(views) AS total_views
FROM spotify
GROUP BY album, track
ORDER BY 3;
```
14. Retrieve the track names that have been streamed on Spotify more than YouTube.
``` sql
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
```
15. Write a query to count how many tracks are primarily played on Spotify versus YouTube using the most_played_on column. Group the results by the platform.
``` sql
SELECT
	most_played_on AS platform,
	COUNT(*) AS total_tracks
FROM spotify
WHERE most_played_on IN ('Spotify', 'Youtube')
GROUP BY platform;
```
16. For each artist, calculate their average danceability and total streams, but only include artists who have more than 3 tracks in the database.
``` sql
SELECT
	artist,
	ROUND(AVG(danceability) :: NUMERIC, 4) AS avg_danceability,
	SUM(streams) AS total_streams,
	COUNT(track) AS total_tracks
FROM spotify
GROUP BY artist
	HAVING COUNT(track) > 3
ORDER BY total_streams DESC;
```

### Advanced level:
17. Find the top 3 most-viewed tracks for each artist using window functions.
``` sql
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
```
18. Write a query to find tracks where the liveness score is above the average.
``` sql
SELECT
	artist,
	track,
	liveness
FROM spotify
WHERE liveness > (
				SELECT AVG(liveness)
				FROM spotify
  				  );
```
19. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
``` sql
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
```
20. Find tracks where the energy-to-liveness ratio is greater than 1.2.
``` sql
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
```
21. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
``` sql
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
```
22. Write a query using a window function (ROW_NUMBER() or DENSE_RANK()) to find the single most-streamed track for each artist.
``` sql
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
```
23. Identify "acoustic outliers." Write a query to find tracks that have an acousticness score higher than the overall average acousticness of the entire dataset, but still manage to have a loudness greater than -5.
``` sql
SELECT
	track,
	acousticness,
	loudness
FROM spotify
WHERE acousticness > (SELECT ROUND(AVG(acousticness) :: NUMERIC, 4) FROM spotify)
	AND
	loudness > - 5
ORDER BY loudness DESC;
```
24. Write a query to calculate the percentage of total streams that come from licensed tracks versus unlicensed tracks. Hint: Use a CASE WHEN statement inside a SUM() aggregation.
``` sql
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
```

## Technology used
**DBMS used:** PostgreSQL
**Tools:** pg Admin 4

## Topics covered
- CREATE cmd
- SELECT
- DISTINCT
- FROM
- WHERE
- GROUP BY
- HAVING
- ORDER BY
- LIMIT / OFFSET
- NULL / NULLIF
- COALESCE
- OPERATORS:
- AND, OR, BETWEEN, IN ETC..
- RELATIONSHIPS: JOINS
- INNER JOIN
- LEFT JOIN
- AGGREGATE FUNCTIONS
- SUM(), COUNT(), AVG(), MAX(), MIN() ETC..
- WINDOW FUNCTIONS:
- DENSE_RANK(), ROW_NUMBER(), RANK(), OVER(), PARTITION BY
- NUMERIC FUNCTIONS:
- ROUND()
- SUBQUERY
- CTE's:
- WITH()
