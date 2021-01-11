--- 4.1.2	Create a warehouse for Sagemaker

USE ROLE ACCOUNTADMIN;

CREATE WAREHOUSE SAGEMAKER_WH 
    WITH WAREHOUSE_SIZE = 'XSMALL' 
    AUTO_SUSPEND = 60 
    AUTO_RESUME = TRUE;

--- 4.1.3	Create a Role and User

CREATE OR REPLACE ROLE SAGEMAKER_ROLE COMMENT='SageMaker Role';

GRANT ALL ON WAREHOUSE SAGEMAKER_WH TO ROLE SAGEMAKER_ROLE;

GRANT ROLE SAGEMAKER_ROLE TO ROLE SYSADMIN;


CREATE OR REPLACE USER SAGEMAKER PASSWORD='AWSSF123' 
    DEFAULT_ROLE=SAGEMAKER_ROLE 
    DEFAULT_WAREHOUSE=SAGEMAKER_WH
    DEFAULT_NAMESPACE=ML_WORKSHOP.PUBLIC
    COMMENT='SageMaker User';

GRANT ROLE SAGEMAKER_ROLE TO USER SAGEMAKER;

--- 4.1.4	Create Citibike_ML Database

USE ROLE SYSADMIN;

CREATE DATABASE IF NOT EXISTS CITIBIKE_ML;
GRANT USAGE ON DATABASE CITIBIKE_ML TO ROLE SAGEMAKER_ROLE;
GRANT ALL ON SCHEMA CITIBIKE_ML.PUBLIC TO ROLE SAGEMAKER_ROLE;

-- Switch Context

USE CITIBIKE_ML.PUBLIC;
USE WAREHOUSE SAGEMAKER_WH;


--- 4.1.5	Create the Trips table

CREATE OR REPLACE TABLE TRIPS
(tripduration integer,
  starttime timestamp,
  stoptime timestamp,
  start_station_id integer,
  start_station_name string,
  start_station_latitude float,
  start_station_longitude float,
  end_station_id integer,
  end_station_name string,
  end_station_latitude float,
  end_station_longitude float,
  bikeid integer,
  membership_type string,
  usertype string,
  birth_year integer,
  gender integer);

GRANT ALL ON TABLE TRIPS TO ROLE SAGEMAKER_ROLE;


--- 4.1.6	Create an External Stage

CREATE or replace STAGE CITIBIKE_ML.PUBLIC.citibike_trips URL = 's3://snowflake-workshop-lab/citibike-trips';
GRANT USAGE ON STAGE CITIBIKE_ML.PUBLIC.citibike_trips TO ROLE SAGEMAKER_ROLE;

list @citibike_trips;


--- 4.1.7	Create a File Format

create or replace FILE FORMAT CITIBIKE_ML.PUBLIC.CSV 
    COMPRESSION = 'AUTO' 
    FIELD_DELIMITER = ',' 
    RECORD_DELIMITER = '\n' 
    SKIP_HEADER = 0 
    FIELD_OPTIONALLY_ENCLOSED_BY = '\042' 
    TRIM_SPACE = FALSE 
    ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE 
    ESCAPE = 'NONE' 
    ESCAPE_UNENCLOSED_FIELD = '\134' 
    DATE_FORMAT = 'AUTO' 
    TIMESTAMP_FORMAT = 'AUTO' 
    NULL_IF = ('');

GRANT USAGE ON FILE FORMAT CITIBIKE_ML.PUBLIC.CSV TO ROLE SAGEMAKER_ROLE;


--- 4.1.8	Load the data into the Trips table

USE ROLE SAGEMAKER_ROLE; 

alter warehouse SAGEMAKER_WH set WAREHOUSE_SIZE = 'LARGE';
copy into trips from @citibike_trips file_format=CSV;
alter warehouse SAGEMAKER_WH set WAREHOUSE_SIZE = 'XSMALL';

-- Check we got the trips information

--- 4.1.9	Verify data loading

select * from trips limit 10;

--- 4.1.10	Create a table for predictions

CREATE OR REPLACE TABLE TRIPS_FORECAST
(ds date,
 yhat float,
 start_station_name string
 );

GRANT ALL ON TABLE TRIPS_FORECAST TO ROLE SAGEMAKER_ROLE;

create or replace view trips_vw as
    select date_trunc('day', starttime) ds, start_station_name, count(*) trips
    from trips
    group by 1, 2
    order by 1 asc;


