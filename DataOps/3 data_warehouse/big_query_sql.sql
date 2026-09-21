-- download datasets to bigquery
CREATE OR REPLACE TABLE `ny-taxi-490622.ny_taxi.yellow_tripdata`
AS SELECT * 
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2019`

CREATE OR REPLACE TABLE `ny-taxi-490622.ny_taxi.yellow_tripdata`
AS SELECT * 
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2020`

CREATE OR REPLACE TABLE `ny-taxi-490622.ny_taxi.green_tripdata`
AS SELECT * 
FROM `bigquery-public-data.new_york_taxi_trips.tlc_green_trips_2019`

CREATE OR REPLACE TABLE `ny-taxi-490622.ny_taxi.green_tripdata`
AS SELECT * 
FROM `bigquery-public-data.new_york_taxi_trips.tlc_green_trips_2020`

-- merge files 

CREATE OR REPLACE TABLE `ny-taxi-490622.ny_taxi.yellow_tripdata`
AS 
SELECT * FROM `ny-taxi-490622.ny_taxi.yellow_tripdata_2019`
UNION ALL
SELECT * FROM `ny-taxi-490622.ny_taxi.yellow_tripdata_2020`;

CREATE OR REPLACE TABLE `ny-taxi-490622.ny_taxi.green_tripdata`
AS 
SELECT * FROM `ny-taxi-490622.ny_taxi.green_tripdata_2019`
UNION ALL
SELECT * FROM `ny-taxi-490622.ny_taxi.green_tripdata_2020`;

-- create datasets partitioned by day 

CREATE OR REPLACE TABLE ny-taxi-490622.ny_taxi.yellow_tripdata_partitioned
PARTITION BY
  DATE(pickup_datetime) AS
SELECT * FROM ny-taxi-490622.ny_taxi.yellow_tripdata;

CREATE OR REPLACE TABLE ny-taxi-490622.ny_taxi.green_tripdata_partitioned
PARTITION BY
  DATE(pickup_datetime) AS
SELECT * FROM ny-taxi-490622.ny_taxi.green_tripdata;

-- Impact of partition

-- Scanning 1.12GB of data
SELECT DISTINCT(Vendor_ID)
FROM ny-taxi-490622.ny_taxi.yellow_tripdata
WHERE DATE(pickup_datetime) BETWEEN '2019-06-01' AND '2019-06-30';

-- Scanning 73MB of data
SELECT DISTINCT(Vendor_ID)
FROM ny-taxi-490622.ny_taxi.yellow_tripdata_partitioned
WHERE DATE(pickup_datetime) BETWEEN '2019-06-01' AND '2019-06-30';

-- create clustered tables

CREATE OR REPLACE TABLE ny-taxi-490622.ny_taxi.yellow_tripdata_partitioned_clustered
PARTITION BY DATE(pickup_datetime)
CLUSTER BY Vendor_ID AS
SELECT * FROM ny-taxi-490622.ny_taxi.yellow_tripdata;

CREATE OR REPLACE TABLE ny-taxi-490622.ny_taxi.green_tripdata_partitioned_clustered
PARTITION BY DATE(pickup_datetime)
CLUSTER BY Vendor_ID AS
SELECT * FROM ny-taxi-490622.ny_taxi.green_tripdata;

-- Impact of clustering

-- Scanning 751 MB of data
SELECT count(*) as trips 
FROM ny-taxi-490622.ny_taxi.yellow_tripdata_partitioned
WHERE DATE(pickup_datetime) BETWEEN '2019-06-01' AND '2020-12-31'
  AND Vendor_ID='1';

-- Scanning 550 MB of data
SELECT count(*) as trips 
FROM ny-taxi-490622.ny_taxi.yellow_tripdata_partitioned_clustered
WHERE DATE(pickup_datetime) BETWEEN '2019-06-01' AND '2020-12-31'
  AND Vendor_ID='1';
