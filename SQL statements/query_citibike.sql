USE ROLE ACCOUNTADMIN;

grant imported privileges on database weather to role SAGEMAKER_ROLE;

USE ROLE SAGEMAKER_ROLE; 
USE CITIBIKE_ML.PUBLIC;
USE WAREHOUSE SAGEMAKER_WH;

/* *********************************************************************************** */
/* *** Test some queries ************************************************************* */
/* *********************************************************************************** */

select count(*) num_trips from trips;


select start_station_name, count(*) trips 
from trips 
group by start_station_name 
order by trips desc limit 5;

select date_trunc('day', starttime), count(*) trips
    from trips
    group by 1
    order by 1 asc;

select start_station_name, date_trunc('day', STARTTIME) d, count(*) trips
    from trips
    where start_station_name like 'E 42 St & Vanderbilt Ave'
    group by 1, 2
    order by 2 asc;
    
    
    
select * from WEATHER.PUBLIC.HISTORY_DAY    
    where POSTAL_CODE = '06101'
    order by DATE_VALID_STD desc
    limit 10;
    
    
select start_station_name, date_trunc('day', STARTTIME) d, avg(w.TOT_PRECIPITATION_IN*100), count(*)
from trips t, WEATHER.PUBLIC.HISTORY_DAY w 
where start_station_name like 'Pershing Square North' 
and d = w.DATE_VALID_STD and w.POSTAL_CODE = '06101' 
group by 1, 2 
order by 2;


select date_trunc('day', STARTTIME) day, avg(w.TOT_PRECIPITATION_IN*100), count(*) 
from trips t, WEATHER.PUBLIC.HISTORY_DAY w 
where d = w.DATE_VALID_STD and w.POSTAL_CODE = '06101' 
group by 1 
order by 1;


select date_trunc('day', STARTTIME) day, avg(w.AVG_TEMPERATURE_FEELSLIKE_2M_F) temp, count(*) trips
from trips t, WEATHER.PUBLIC.HISTORY_DAY w 
where day = w.DATE_VALID_STD and w.POSTAL_CODE = '06101' 
group by 1 
order by 1;



