-- What are the most popular pickup and drop-off locations?

SELECT pickup_location, COUNT(*) AS pick_up FROM ride
GROUP BY pickup_location; 

SELECT dropoff_location, COUNT(*) as Drop_off FROM ride
GROUP BY dropoff_location;


UPDATE ride
SET ride_datetime = str_to_date(ride_datetime, '%c/%e/%Y %H:%i');

ALTER TABLE ride
MODIFY COLUMN ride_datetime DATETIME;

-- How do weekends vs. weekdays impact ride demand?
SELECT 
	DAYNAME(ride_datetime) AS day_name,
    COUNT(*) AS ride_count
FROM ride
GROUP BY day_name
ORDER BY ride_count;

SELECT 
		CONCAT(Week_day, '  -  ', ROUND(Week_day * 100.0 / Total_ride, 2), '%') AS WEEK_DAY,
        CONCAT(Week_end, '  -  ', ROUND(Week_end * 100.0 / Total_ride, 2), '%') AS WEEK_END
FROM 
( SELECT 
    SUM(CASE WHEN DAYOFWEEK(ride_datetime) IN (2,3,4,5,6) THEN 1 ELSE 0 END ) AS Week_day,
	SUM(CASE WHEN DAYOFWEEK(ride_datetime) IN (1,6) THEN 1 ELSE 0 END ) AS Week_end,
    ( SELECT COUNT(ride_id) FROM ride ) AS Total_ride
FROM ride)  L1 ;

-- Which vehicle types (SUV, Sedan, Motorcycle, Electric) are most preferred?
SELECT vehicle_type, COUNT(ride_id) FROM ride
GROUP BY vehicle_type
ORDER BY 2 desc;

-- Which drivers have the highest and lowest ratings?
SELECT driver_id, driver_rating
FROM ride
WHERE driver_rating IN (
    (SELECT MAX(driver_rating) FROM ride),
    (SELECT MIN(driver_rating) FROM ride)
)
ORDER BY 2 desc;

-- What is the average ride duration per driver?
SELECT driver_id, ROUND(AVG(ride_duration_min),2) as Duration
FROM ride
GROUP BY driver_id
ORDER BY 2 desc;

SELECT user_type, AVG(fare_amount)
FROM ride
GROUP BY user_type
ORDER BY 2 desc;

-- Which payment methods are most commonly used?
SELECT payment_method, COUNT(*)
FROM ride
GROUP BY payment_method
ORDER BY 2 desc;

-- How does driver experience impact ride completion rates and customer ratings?
SELECT 
    CASE
        WHEN driver_experience_years >= 2 THEN 'Experienced'
        ELSE 'Inexperienced'
    END AS experience_level_years,
    COUNT(CASE WHEN ride_status = 'Completed' THEN 1 END) AS completed_rides,
    COUNT(CASE WHEN ride_status IN ('Canceled', 'No-show') THEN 1 END) AS cancelled_rides,
    COUNT(*) AS total_rides,
    (COUNT(CASE WHEN ride_status = 'Completed' THEN 1 END) / COUNT(*)) * 100 AS completion_rate_percentage,
    AVG(driver_rating) AS average_rating
FROM ride
GROUP BY experience_level_years
ORDER BY experience_level_years;

SELECT 
	CASE
	WHEN driver_experience_years > 1 THEN 'Experienced' ELSE 'Inexperienced'
    END AS experience_level_years,
    COUNT(CASE WHEN ride_status = 'Completed' THEN 1 END) as completed_rides,
    COUNT(CASE WHEN ride_status IN ('No-Show', 'Canceled') THEN 1 END) as cancelled_rides,
    COUNT(*) AS Total_rides,
    (COUNT(CASE WHEN ride_status = 'Completed' THEN 1 END) / COUNT(*)) * 100 AS completion_rate_percentage,
    AVG(driver_rating) AS average_rating
FROM ride
GROUP BY experience_level_years
ORDER BY 2 desc;
    
-- What is the average ride duration per driver, and how does it vary by location and traffic?
SELECT 
	CASE 
    WHEN driver_experience_years > 2 THEN 'Experienced' ELSE 'Inxperienced' END AS'experience_status' ,
	pickup_location, dropoff_location,	
	AVG(distance_km) AS Distance, 
    AVG(ride_duration_min) AS Duration
FROM ride
GROUP BY experience_status, pickup_location, dropoff_location
    
;
SELECT * FROM projects.ride;