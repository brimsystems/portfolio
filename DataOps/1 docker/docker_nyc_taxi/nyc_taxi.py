#!/usr/bin/env python
# coding: utf-8

# # Data Uploading & Preprocessing

import pandas as pd
from sqlalchemy import create_engine

taxi_df = pd.read_parquet("https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2025-11.parquet")
zone_df = pd.read_csv("https://github.com/DataTalksClub/nyc-tlc-data/releases/download/misc/taxi_zone_lookup.csv")


taxi_df.head()
zone_df.head()
merged_df = (
    taxi_df
    .merge(zone_df, left_on="PULocationID", right_on="LocationID")
    .rename(columns={"Borough": "PU_Borough", "Zone": "PU_Zone", "service_zone": "PU_service_zone"})
    .drop(columns="LocationID")
    .merge(zone_df, left_on="DOLocationID", right_on="LocationID")
    .rename(columns={"Borough": "DO_Borough", "Zone": "DO_Zone", "service_zone": "DO_service_zone"})
    .drop(columns="LocationID")
)
merged_df.head()
taxi_df.dtypes

# # Data Exploration
# count of November trips less than 1 mile distance
count = ((taxi_df['lpep_pickup_datetime'] >= "2025-11-01") & (taxi_df['lpep_pickup_datetime'] < "2025-12-01") & (taxi_df['trip_distance'] <= 1))
taxi_df[count].shape[0]

# most active pickup zone on 11-18-25
merged_df[merged_df['lpep_pickup_datetime'].dt.date == pd.Timestamp("2025-11-18").date()].groupby('PU_Zone').size().idxmax()

# drop off zone from East Harlem North with the largest tip amount
result = (
    merged_df[(merged_df['PU_Zone'] == 'East Harlem North') & 
        (merged_df['lpep_pickup_datetime'] >= '2025-11-01') & 
        (merged_df['lpep_dropoff_datetime'] < '2025-12-01')]
    .loc[:,['DO_Zone', 'tip_amount']]
    .sort_values('tip_amount', ascending=False)
    .iloc[0])
result        


# # Upload to Postgres


engine = create_engine('postgresql://root:root@localhost:5432/ny_taxi')

merged_df.head(0).to_sql(name='green_taxi_data', con=engine, if_exists='replace') 


chunk_size = 10000

for i, chunk in enumerate(range(0, len(merged_df), chunk_size)):
    chunk_df = merged_df.iloc[chunk:chunk + chunk_size]
    chunk_df.to_sql('green_taxi_data', engine, if_exists='append' if i > 0 else 'replace', index=False)
    print(f"Uploaded chunk {i+1}, rows {chunk} to {chunk + len(chunk_df)}")





