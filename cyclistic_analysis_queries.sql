-- =========================================================
-- Cyclistic Bike-Share Case Study | BigQuery SQL Queries
-- Author: Avanee Upadhyaya
-- Description:
-- This file contains the SQL workflow used for data consolidation,
-- cleaning, feature engineering, and final aggregations for Tableau.
-- =========================================================


-- =========================================================
-- 1. DATA CONSOLIDATION
-- Merging 12 months of raw trip data into one consolidated table
-- =========================================================

CREATE TABLE `cyclistic-casestudy-2026.raw_bike_data.combined_trips_2025_2026` AS
SELECT * FROM `cyclistic-casestudy-2026.raw_bike_data.trips_2025_03` UNION ALL
SELECT * FROM `cyclistic-casestudy-2026.raw_bike_data.trips_2025_04` UNION ALL
SELECT * FROM `cyclistic-casestudy-2026.raw_bike_data.trips_2025_05` UNION ALL
SELECT * FROM `cyclistic-casestudy-2026.raw_bike_data.trips_2025_06` UNION ALL
SELECT * FROM `cyclistic-casestudy-2026.raw_bike_data.trips_2025_07` UNION ALL
SELECT * FROM `cyclistic-casestudy-2026.raw_bike_data.trips_2025_08` UNION ALL
SELECT * FROM `cyclistic-casestudy-2026.raw_bike_data.trips_2025_09` UNION ALL
SELECT * FROM `cyclistic-casestudy-2026.raw_bike_data.trips_2025_10` UNION ALL
SELECT * FROM `cyclistic-casestudy-2026.raw_bike_data.trips_2025_11` UNION ALL
SELECT * FROM `cyclistic-casestudy-2026.raw_bike_data.trips_2025_12` UNION ALL
SELECT * FROM `cyclistic-casestudy-2026.raw_bike_data.trips_2026_01` UNION ALL
SELECT * FROM `cyclistic-casestudy-2026.raw_bike_data.trips_2026_02`;



-- =========================================================
-- 2. DATA GAP MITIGATION (THE PROXY LOGIC)
-- =========================================================
-- PROOF OF WORK: Since 2026 weather data was unavailable, I mapped 
-- 2026 trip dates to 2025 weather benchmarks to maintain seasonal integrity.

CREATE VIEW `cyclistic-casestudy-2026.raw_bike_data.view_raw_joined_weather` AS
SELECT 
    trips.*,
    weather.temp AS avg_temp,
    weather.prcp AS precipitation,
    weather.wdsp AS wind_speed
FROM `cyclistic-casestudy-2026.raw_bike_data.combined_trips_2025_2026` AS trips
LEFT JOIN `cyclistic-casestudy-2026.raw_bike_data.chicago_weather_raw` AS weather
  ON DATE(trips.started_at) = 
     -- Logic: If trip is in 2026, subtract 1 year to use 2025 weather as proxy
     IF(DATE(trips.started_at) > '2025-12-31', 
        DATE_SUB(DATE(trips.started_at), INTERVAL 1 YEAR), 
        DATE(trips.started_at));


-- =========================================================
-- 3. DATA CLEANING & FEATURE ENGINEERING
-- Creating the final cleaned dataset with derived fields such as:
-- - ride_length (in minutes)
-- - day_of_week
-- - ride_hour
-- - filters for invalid durations
-- =========================================================

CREATE OR REPLACE VIEW `cyclistic-casestudy-2026.raw_bike_data.final_cleaned_trips` AS
SELECT 
    *,
    -- Adding these now so your charts in Tableau/Sheets are 10x easier
    TIMESTAMP_DIFF(ended_at, started_at, MINUTE) AS ride_length_m,
    FORMAT_DATE('%A', started_at) AS day_of_week,
    EXTRACT(HOUR FROM started_at) AS ride_hour
FROM `cyclistic-casestudy-2026.raw_bike_data.combined_trips_2025_2026`
WHERE 
    TIMESTAMP_DIFF(ended_at, started_at, MINUTE) >= 1   -- Filters "False Starts"
    AND TIMESTAMP_DIFF(ended_at, started_at, MINUTE) <= 1440 -- Filters "Lost/Stolen"
    AND started_at < ended_at;                         -- Filters "Time Travelers"


-- =========================================================
-- 4. FINAL AGGREGATIONS FOR TABLEAU
-- These queries were used to generate CSV exports for dashboard visuals
-- =========================================================


-- ---------------------------------------------------------
-- 4.1 Weekly Usage by Rider Type
-- ---------------------------------------------------------

SELECT 
    member_casual, 
    day_of_week, 
    COUNT(*) AS trip_count,
    ROUND(AVG(ride_length_m), 2) AS avg_duration
FROM `cyclistic-casestudy-2026.raw_bike_data.final_cleaned_trips`
GROUP BY member_casual, day_of_week
ORDER BY 
    member_casual, 
    -- This little trick sorts Monday to Sunday correctly
    CASE 
        WHEN day_of_week = 'Monday' THEN 1
        WHEN day_of_week = 'Tuesday' THEN 2
        WHEN day_of_week = 'Wednesday' THEN 3
        WHEN day_of_week = 'Thursday' THEN 4
        WHEN day_of_week = 'Friday' THEN 5
        WHEN day_of_week = 'Saturday' THEN 6
        WHEN day_of_week = 'Sunday' THEN 7
    END;


-- ---------------------------------------------------------
-- 4.2 Hourly Ride Trends
-- ---------------------------------------------------------

SELECT 
    member_casual, 
    ride_hour, 
    COUNT(*) AS total_trips
FROM `cyclistic-casestudy-2026.raw_bike_data.final_cleaned_trips`
GROUP BY member_casual, ride_hour
ORDER BY ride_hour ASC, member_casual;


-- ---------------------------------------------------------
-- 4.3 Average Trip Duration by Rider Type
-- ---------------------------------------------------------

SELECT 
    member_casual, 
    ROUND(AVG(ride_length_m), 2) AS avg_duration_mins, 
    MAX(ride_length_m) AS max_duration_mins, 
    COUNT(*) AS total_rides 
FROM `cyclistic-casestudy-2026.raw_bike_data.final_cleaned_trips` 
GROUP BY member_casual;


-- ---------------------------------------------------------
-- 4.4 Top Casual Rider Start Stations
-- ---------------------------------------------------------

SELECT 
    start_station_name, 
    COUNT(*) AS casual_trips 
FROM `cyclistic-casestudy-2026.raw_bike_data.final_cleaned_trips` 
WHERE member_casual = 'casual' AND start_station_name IS NOT NULL 
GROUP BY start_station_name 
ORDER BY casual_trips DESC 
LIMIT 10;
