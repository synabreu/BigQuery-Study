--- ### 통합쿼리 (Federated Query) ### --

# 통합 쿼리는 쿼리 문을 외부 데이터베이스에 보내고 결과를 임시 테이블로 가져오는 방법입니다. 
# 통합 쿼리는 BigQuery Connection API를 사용하여 외부 데이터베이스와 연결을 설정합니다. 
# 스탠더드 SQL 쿼리에서 EXTERNAL_QUERY 함수를 사용하여 쿼리 문을 외부 데이터베이스로 전송하며 이때 해당 데이터베이스의 SQL 언어를 사용합니다. 
# 결과는 BigQuery 스탠더드 SQL 데이터 유형으로 변환됩니다.

SELECT * FROM EXTERNAL_QUERY("my-pc-project-357506.us.noaa_gsod", "SELECT * FROM INFORMATION_SCHEMA.TABLES;");

SELECT * FROM EXTERNAL_QUERY("my-pc-project-357506.us.noaa_gsod", "SELECT * FROM gsod2022.gsod2022 LIMIT 10;");

# Cloud SQL 이나 Cloud Spanner 와 같은 외부 데이터베이스에서 통합 쿼리를 사용할 수 있습니다.
# 처음 1회 설정 이후 SQL 함수 EXTERNAL_QUERY를 사용하여 쿼리를 작성할 수 있습니다.
# BigQuery 멀티 리전은 동일한 대규모 지역(미국, EU)의 모든 데이터 소스 리전을 쿼리할 수 있습니다. 