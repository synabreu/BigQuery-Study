SELECT * FROM `bigquery-public-data.noaa_gsod.gsod2022` LIMIT 1000;




SELECT
  table_name, ddl
FROM
  `bigquery-public-data`.noaa_gsod.INFORMATION_SCHEMA.TABLES
WHERE
  table_name = 'gsod2022';

-- 데이터베이스 사용 및 테이블 생성

USE gsod2022;
CREATE TABLE gsod2022
(
  stn VARCHAR(255),
  wban VARCHAR(255),
  year VARCHAR(255),
  mo VARCHAR(255),
  da VARCHAR(255),
  temp FLOAT(4,1),
  count_temp INT,
  dewp FLOAT(4,1),
  count_dewp INT,
  slp FLOAT(4,1),
  count_slp INT,
  stp FLOAT(4,1),
  count_stp INT,
  visib FLOAT(4,1),
  count_visib INT,
  wdsp VARCHAR(255),
  count_wdsp VARCHAR(255),
  mxpsd VARCHAR(255),
  gust FLOAT(3,1),
  max FLOAT(4,1),
  flag_max VARCHAR(255),
  min FLOAT(4,1),
  flag_min VARCHAR(255),
  prcp FLOAT(4,1),
  sndp FLOAT(3,1),
  fog VARCHAR(255),
  rain_drizzle VARCHAR(255),
  snow_ice_pellets VARCHAR(255),
  hail VARCHAR(255),
  thunder VARCHAR(255),
  tornado_funnel_cloud VARCHAR(255)
);