select  
    -- identifiers
    cast(vendor_id as int) as vendor_id, 
    cast(cast(rate_code as numeric) as int) as rate_code_id, 
    cast(pickup_location_id as int) as pickup_location_id,
    cast(dropoff_location_id as int) as dropoff_location_id,
    
    -- timestamps
    cast(pickup_datetime as timestamp) as pickup_datetime,
    cast(dropoff_datetime as timestamp) as dropoff_datetime,
    
    -- trip details
    store_and_fwd_flag,
    cast(cast(passenger_count as numeric) as int) as passenger_count,
    cast(trip_distance as numeric) as trip_distance,
    cast(cast(trip_type as numeric) as int) as trip_type,

    -- payment info
    cast(fare_amount as numeric) as fare_amount,
    cast(extra as numeric) as extra,
    cast(mta_tax as numeric) as mta_tax,
    cast(tip_amount as numeric) as tip_amount,
    cast(tolls_amount as numeric) as tolls_amount,
    cast(imp_surcharge as numeric) as improvement_surcharge,
    cast(total_amount as numeric) as total_amount,
    cast(cast(payment_type as numeric) as int) as payment_type

from {{ source('raw_data', 'green_tripdata') }}

where vendor_id is not null
