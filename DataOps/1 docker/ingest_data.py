#!/usr/bin/env python
# coding: utf-8

import pandas as pd
from sqlalchemy import create_engine
from tqdm.auto import tqdm
import click






# change data types 
dtype = {
    "VendorID": "Int64",
    "passenger_count": "Int64",
    "trip_distance": "float64",
    "RatecodeID": "Int64",
    "store_and_fwd_flag": "string",
    "PULocationID": "Int64",
    "DOLocationID": "Int64",
    "payment_type": "Int64",
    "fare_amount": "float64",
    "extra": "float64",
    "mta_tax": "float64",
    "tip_amount": "float64",
    "tolls_amount": "float64",
    "improvement_surcharge": "float64",
    "total_amount": "float64",
    "congestion_surcharge": "float64"
}

parse_dates = [
    "tpep_pickup_datetime",
    "tpep_dropoff_datetime"
]

prefix = 'https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/'


def run(year: int, month: int, pg_user: str, pg_pass: str, pg_host: str, pg_port: int, pg_db: str, table_name: str = 'yellow_taxi_data', chunksize: int = 100000):
    engine = create_engine(f'postgresql://{pg_user}:{pg_pass}@{pg_host}:{pg_port}/{pg_db}')

    df_iter = pd.read_csv(
        prefix + f'yellow_tripdata_{year}-{month:02d}.csv.gz',
        dtype=dtype,
        parse_dates=parse_dates,
        iterator=True,
        chunksize=chunksize
    )

    first = True
    for df_chunk in tqdm(df_iter):
        if first:
            df_chunk.head(0).to_sql(
                name=table_name,
                con=engine,
                if_exists='replace')
            first = False
            print("Table created")
        df_chunk.to_sql(
            name=table_name,
            con=engine,
            if_exists='append')
        print("Inserted:", len(df_chunk))

@click.command()
@click.option('--year', default=2021, type=int, help='Year of dataset')
@click.option('--month', default=1, type=int, help='Month of dataset (1-12)')
@click.option('--pg-user', 'pg_user', default='root', help='Postgres user')
@click.option('--pg-pass', 'pg_pass', default='root', help='Postgres password')
@click.option('--pg-host', 'pg_host', default='localhost', help='Postgres host')
@click.option('--pg-port', 'pg_port', default=5432, type=int, help='Postgres port')
@click.option('--pg-db', 'pg_db', default='ny_taxi', help='Postgres database')
@click.option('--table-name', '--table_name', 'table_name', default='yellow_taxi_data', help='Target table name')
@click.option('--chunksize', default=100000, type=int, help='Number of rows per chunk')
def main(year, month, pg_user, pg_pass, pg_host, pg_port, pg_db, table_name, chunksize):
    run(year, month, pg_user, pg_pass, pg_host, pg_port, pg_db, table_name, chunksize)


if __name__ == '__main__':
    main()




