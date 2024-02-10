** Data Loader in Mage **

```
if 'data_loader' not in globals():
    from mage_ai.data_preparation.decorators import data_loader
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test

import pandas as pd
from datetime import datetime

@data_loader
def load_data(*args, **kwargs):

    dfs = []

    for month in range(1, 13):

        print(month)

        if month < 10:
            file_name = f"https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2022-0{month}.parquet"
        else:
            file_name = f"https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2022-{month}.parquet"

        current_file = pd.read_parquet(file_name)
        
        dfs.append(current_file)

    final_data = pd.concat(dfs)

    final_data['lpep_pickup_datetime'] = final_data['lpep_pickup_datetime'].dt.date
    final_data['lpep_dropoff_datetime'] = final_data['lpep_dropoff_datetime'].dt.date
    
    return(final_data)

```

** Data Export to GCS **

```
from mage_ai.settings.repo import get_repo_path
from mage_ai.io.config import ConfigFileLoader
from mage_ai.io.google_cloud_storage import GoogleCloudStorage
from pandas import DataFrame
from os import path

if 'data_exporter' not in globals():
    from mage_ai.data_preparation.decorators import data_exporter

import pyarrow as pa
import pyarrow.parquet as pq
import os

bucket_name = "mage-zoomcamp-arben-1"
table_name = 'green_taxi_2022'
root_path = f'{bucket_name}/{table_name}'

os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = "/home/src/my_creds.json"

@data_exporter
def export_data_to_google_cloud_storage(data, **kwargs) -> None:

    # transform table into a py arrow table
    table = pa.Table.from_pandas(data)

    # connect to gcs
    gcs = pa.fs.GcsFileSystem()

    pq.write_to_dataset(
        table = table,
        root_path = root_path,
        filesystem = gcs
    )

```

** BigQuery queries to create external table and internal table **

```
-- Creating external table referring to GCS path with wildcard prefix
CREATE OR REPLACE EXTERNAL TABLE `big_query_zoomcamp.external_green_taxi`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://mage-zoomcamp-arben-1/green_taxi_2022/d581cb75e6da41ba833b57036af954b2-0.parquet']
);

create or replace table `big_query_zoomcamp.internal_green_taxi` as
  select
  *
from
  `big_query_zoomcamp.external_green_taxi`

```

** Question 2 - Estimate resource usage **

```
-- External table
select
  count(distinct PULocationID)
from
  `big_query_zoomcamp.external_green_taxi`

-- Table
select
  count(distinct PULocationID)
from
  `big_query_zoomcamp.internal_green_taxi`
```

** Question 3 - Fare amount **

```
-- Table
select
  count(*)
from
  `big_query_zoomcamp.internal_green_taxi`
where
  fare_amount = 0
```

** Question 4 - partition and cluster **

```
create or replace table `big_query_zoomcamp.green_taxi_partitioned_clustered` 
  partition by lpep_pickup_datetime
  cluster by PUlocationID
as
  select
    *
  from
    `big_query_zoomcamp.external_green_taxi`
```

** Question 5 - Estimate bytes **
```
-- Partitioned and clustered table
select
  distinct(PULocationID)
from 
  `terraform-412318.big_query_zoomcamp.green_taxi_partitioned_clustered` 
where 
  lpep_pickup_datetime between "2022-06-01" and "2022-06-30"

-- Normal table
select
  distinct(PULocationID)
from 
  `terraform-412318.big_query_zoomcamp.internal_green_taxi` 
where 
  lpep_pickup_datetime between "2022-06-01" and "2022-06-30"
```
