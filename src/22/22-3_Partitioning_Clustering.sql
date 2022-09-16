-- 1. 파티션을 나눈 테이블 만들기

# 예제 설명: DATE 열을 사용하여 mydataset에 newtable이라는 파티션을 나눈 테이블을 만듭니다.
# partition_expiration_days는 파티션 만료 시간 3일이라는 것을 뜻합니다.
CREATE TABLE myDataSet.newtable (transaction_id INT64, transaction_date DATE)
PARTITION BY transaction_date
OPTIONS(
  partition_expiration_days=3,
  description="a table partitioned by transaction_date"
);

# 예제 설명: 쿼리 결과에서 파티션을 나눈 테이블 만들기 - DATE 열을 사용하여 mydataset에 days_with_rain이라는 파티션을 나눈 테이블을 만듭니다.

CREATE TABLE myDataSet.days_with_rain
PARTITION BY date
OPTIONS (
  partition_expiration_days=365,
  description="weather stations with precipitation, partitioned by day"
) AS
SELECT
  DATE(CAST(year AS INT64), CAST(mo AS INT64), CAST(da AS INT64)) AS date,
  (SELECT ANY_VALUE(name) FROM `bigquery-public-data.noaa_gsod.stations` AS stations
   WHERE stations.usaf = stn) AS station_name,  # Stations 은 다중 이름을 가질 수 있음 
  prcp
FROM `bigquery-public-data.noaa_gsod.gsod2017` AS weather
WHERE prcp != 99.9  # unknown 변수를 필터하라
  AND prcp > 0;      # 비가 오지 않는 날(강우량 0)인 지역/날 필터

-- Drop Table 삭제
DROP TABLE myDataSet.days_with_rain;

-- 2. 클러스터링된 테이블 만들기


# 예제 설명: mydataset에 myclusteredtable이라는 클러스터링된 테이블 생성
CREATE TABLE myDataSet.myclusteredtable
(
  customer_id STRING,
  transaction_amount NUMERIC
)
CLUSTER BY
  customer_id
OPTIONS (
  description="a table clustered by customer_id"
);

-- Drop Table 삭제
DROP TABLE myDataSet.myclusteredtable;

# 예제 설명: mydataset에 myclusteredtable이라는 클러스터링된 테이블을 만듭니다. 
# 테이블은 TIMESTAMP 열로 파티션을 나누고 customer_id라는 STRING 열로 클러스터링된 파티션을 나눈 테이블입니다.
# 파티션 만료 시간: 3일

CREATE TABLE myDataSet.myclusteredtable
(
  timestamp TIMESTAMP,
  customer_id STRING,
  transaction_amount NUMERIC
)
PARTITION BY DATE(timestamp)
CLUSTER BY customer_id
OPTIONS (
  partition_expiration_days=3,
  description="a table clustered by customer_id"
);


-- Drop Table 삭제
DROP TABLE myDataSet.myclusteredtable;

# 수집 시간으로 파티션을 나눈 테이블
# mydataset에 myclusteredtable이라는 클러스터링된 테이블을 만듭니다. 

CREATE TABLE mydataset.myclusteredtable
(
  customer_id STRING,
  transaction_amount NUMERIC
)
PARTITION BY DATE(_PARTITIONTIME)
CLUSTER BY
  customer_id
OPTIONS (
  partition_expiration_days=3,
  description="a table clustered by customer_id"
);

-- Drop Table 삭제
DROP TABLE myDataSet.myclusteredtable;


-- 참고사항: https://cloud.google.com/bigquery/docs/partitioned-tables

