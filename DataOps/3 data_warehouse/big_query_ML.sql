-- FEATURE SELECTION
SELECT passenger_count, trip_distance, pickup_location_ID, dropoff_location_id, payment_type, fare_amount, tolls_amount, tip_amount
FROM `ny-taxi-490622.ny_taxi.yellow_tripdata_partitioned` WHERE fare_amount != 0;

-- CREATE ML TABLE
CREATE OR REPLACE TABLE `ny-taxi-490622.ny_taxi.yellow_tripdata_ml` (
`passenger_count` INTEGER,
`trip_distance` FLOAT64,
`pickup_location_ID` STRING,
`dropoff_location_ID` STRING,
`payment_type` STRING,
`fare_amount` FLOAT64,
`tolls_amount` FLOAT64,
`tip_amount` FLOAT64
) AS (
SELECT passenger_count, trip_distance, cast(pickup_location_ID AS STRING), CAST(dropoff_location_ID AS STRING),
CAST(payment_type AS STRING), fare_amount, tolls_amount, tip_amount
FROM `ny-taxi-490622.ny_taxi.yellow_tripdata_partitioned` WHERE fare_amount != 0
);

-- CREATE MODEL WITH DEFAULT SETTING
CREATE OR REPLACE MODEL `ny-taxi-490622.ny_taxi.tip_model`
OPTIONS
(model_type='linear_reg',
input_label_cols=['tip_amount'],
DATA_SPLIT_METHOD='AUTO_SPLIT') AS
SELECT
*
FROM
`ny-taxi-490622.ny_taxi.yellow_tripdata_ml`
WHERE
tip_amount IS NOT NULL;

-- CHECK FEATURES
SELECT * FROM ML.FEATURE_INFO(MODEL `ny-taxi-490622.ny_taxi.tip_model`);

-- EVALUATE MODEL
SELECT * FROM ML.EVALUATE(MODEL `ny-taxi-490622.ny_taxi.tip_model`,
(SELECT * FROM `ny-taxi-490622.ny_taxi.yellow_tripdata_ml`
WHERE tip_amount IS NOT NULL));


-- MAKE PREDICTIONS
SELECT * FROM ML.PREDICT(MODEL `ny-taxi-490622.ny_taxi.tip_model`,
(SELECT * FROM `ny-taxi-490622.ny_taxi.yellow_tripdata_ml`
WHERE tip_amount IS NOT NULL));

-- EXPLAIN TOP FEATURES
SELECT * FROM ML.EXPLAIN_PREDICT(MODEL `ny-taxi-490622.ny_taxi.tip_model`,
(SELECT * FROM `ny-taxi-490622.ny_taxi.yellow_tripdata_ml`
WHERE tip_amount IS NOT NULL), 
STRUCT(3 as top_k_features));

-- HYPER PARAM TUNNING
CREATE OR REPLACE MODEL `ny-taxi-490622.ny_taxi.tip_hyperparam_model`
OPTIONS(model_type='linear_reg',
input_label_cols=['tip_amount'],
DATA_SPLIT_METHOD='AUTO_SPLIT',
num_trials=5,
max_parallel_trials=2,
l1_reg=hparam_range(0, 20),
l2_reg=hparam_candidates([0, 0.1, 1, 10])) AS
SELECT * FROM `ny-taxi-490622.ny_taxi.yellow_tripdata_ml`
WHERE tip_amount IS NOT NULL;