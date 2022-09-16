
-- 1. SELECT문 사용하기
-- 설명: SELECT 문을 사용하면 테이블에서 지정된 열의 값을 검색할 수 있음.
SELECT *
FROM `bigquery-public-data.new_york_citibike.citibike_trips` LIMIT 5;


-- 예시: 뉴욕 자전거 데이터에서 대여기간(tripduration), 성별(gender) 포함을 포함한 자전거 대여를 조회하라.
-- 내부: 빅쿼리는 행을 읽는 작업을 여러 워커에 분배하고, 각 워커는 데이터셋의 서로 다른 샤드에서 데이터를 읽어서 분산 처리한다. 
--      LIMIT 제약 조건은 쿼리 엔진이 처리할 데이터 양이 아니라 표시되는 데이터 양만 제한함. 
--      일반적으로 쿼리에서 처리되는 데이터의 양에 따라 요금이 청구되므로 읽는 컬럼이 많을수록 청구되는 요금이 많다.
--      처리되는 행의 수는 일반적으로 쿼리가 읽는 테이블의 전체 크기임을 유의하라. 
SELECT gender, tripduration 
FROM `bigquery-public-data.new_york_citibike.citibike_trips` LIMIT 5;

-- 2. AS로 컬럼명에 별칭 지정하기

SELECT gender, tripduration As rental_duration
FROM `bigquery-public-data.new_york_citibike.citibike_trips` LIMIT 5;

-- 대여 기간을 분 단위로 표시하기  
SELECT gender, tripduration/60 
FROM `bigquery-public-data.new_york_citibike.citibike_trips` LIMIT 5;

SELECT gender, tripduration/60 AS duration_minutes
FROM `bigquery-public-data.new_york_citibike.citibike_trips` LIMIT 5;

-- 3. WHERE로 조건 필터링하기
-- 예시 : 대여시간이 10분 미만인 대여 건을 찾아라.

SELECT gender, tripduration
FROM `bigquery-public-data.new_york_citibike.citibike_trips` 
WHERE tripduration < 600
LIMIT 10;

-- 예시(AND): 자전거를 대여한 사람이 여성이고, 대여 시간이 5분에서 10분 사이에 대여 건만 찾아라. 
SELECT gender, tripduration
FROM `bigquery-public-data.new_york_citibike.citibike_trips` 
WHERE tripduration >= 300 AND tripduration < 600 AND gender='female'
LIMIT 10;

-- 예시(NOT): 대여 시간이 10분 미만인 사람 중 여성이 아닌 사용자를 찾아라. 
SELECT gender, tripduration
FROM `bigquery-public-data.new_york_citibike.citibike_trips` 
WHERE tripduration < 600 AND NOT gender = 'female'
LIMIT 100;

-- 예시(OR): 모든 남성 사용자와 대여 시간이 10분 미만인 여성 사용자를 찾아라.
SELECT gender, tripduration
FROM `bigquery-public-data.new_york_citibike.citibike_trips` 
WHERE (tripduration < 600 AND gender = 'female') OR gender = 'male'
LIMIT 10;

-- 예시: 10분 미만에 대여를 찾아라. WHERE 절에 별칭을 참조할 수 없다. 에러 발생함.
SELECT gender, tripduration/60 AS minutes
FROM `bigquery-public-data.new_york_citibike.citibike_trips` 
-- WHERE minutes < 10
WHERE (tripduration / 60) < 10
LIMIT 10;

-- 4. SELECT *, EXCEPT, REPLACE 사용법

-- 예시(*): 이 테이블의 전체 컬럼을 모두 나타내라.  
SELECT name, *
FROM `bigquery-public-data.new_york_citibike.citibike_stations` 
WHERE name LIKE '%Central Park%'
LIMIT 10;


-- 예시(EXCEPT): EXCEPT로 지정한 컬럼 외에 모두 나타내라.  
SELECT * EXCEPT(short_name, last_reported)
FROM `bigquery-public-data.new_york_citibike.citibike_stations` 
WHERE name LIKE '%Central Park%'
LIMIT 10;

-- 예시(REPLACE): 모든 컬럼을 조회하면서 그중 한 컬럼의 값을 변환하고 싶을때 SELECT REPLACE를 사용한다.
--               즉, 대여 가능한 자전거 수에 5를 더하고 싶다. 
SELECT * REPLACE(num_bikes_available + 5 AS num_bikes_available)
FROM `bigquery-public-data.new_york_citibike.citibike_stations`
LIMIT 10;

-- 4. WITH를 사용한 서브 쿼리 
-- 장점: 서브 퀴리를 사용하면 반복을 줄이고 별칭을 계속 사용할 수 있다. 

-- 중복 쿼리를 사용해서 괄호 안에 쿼리를 식별하기 어렵다. 
SELECT * FROM ( 
  SELECT gender, tripduration / 60 AS minutes
    FROM `bigquery-public-data.new_york_citibike.citibike_trips` 
)
WHERE minutes < 10
LIMIT 5;

-- 식별하기 어려운 쿼리를 WITH 절로 사용한다.
-- all_trips 는 임시(Temp) 테이블이 아니라 'from_item'로 테이블처럼 값을 선택할 수 있는 모든 데이터베이스 객체를 부름. 
WITH all_trips AS (
  SELECT gender, tripduration / 60 AS minutes
  FROM `bigquery-public-data.new_york_citibike.citibike_trips`
)
SELECT * FROM all_trips
WHERE minutes < 10
LIMIT 5;

# object func(minutes) {
#   ......
#   return all_trips
# }
# value: all_trips.gender, all_trips.minutes

-- 5. ORDER BY로 정렬하기
-- DESC (Descending) : 역순/숫자가 큰 것 부터, ASC (Ascending): 정순/숫자가 작은 것 부터, ASC 생략 가능 

SELECT gender, tripduration/60 AS minutes
FROM `bigquery-public-data.new_york_citibike.citibike_trips` 
WHERE gender = 'female'
-- ORDER BY minutes DESC
 -- ORDER BY minutes ASC
 ORDER BY minutes
LIMIT 5;





