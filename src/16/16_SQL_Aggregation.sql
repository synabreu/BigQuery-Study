-- ### 집계(Aggregation) ###

-- 앞선 예시들은 테이블의 모든 행으로부터 tripduration 컬럼의 값을 60으로 나눠 초를 분으로 변환.
-- 그러나 집계 함수를 사용하면 모든 행의 값을 집계해 결과 집합의 하나의 행만 나타나도록 함.


-- 1. GROUP BY로 집계하기
-- 예시: 남성 사용자의 평균 대여 시간을 계산하여 조회하라.

SELECT AVG(tripduration / 60) AS avg_trip_duration
FROM `bigquery-public-data.new_york_citibike.citibike_trips` 
WHERE gender = 'male'
LIMIT 5;

-- 결과: 뉴욕에서 남성 사용자가 평균적으로 자전거를 대여하는 시간이 약 13.4분임을 알수 있음.

-- 예시: 다른 사용자의 평균 대여 시간을 계산하여 조회하라. 
SELECT gender, AVG(tripduration / 60) AS avg_trip_duration
FROM `bigquery-public-data.new_york_citibike.citibike_trips` 
WHERE tripduration is not null 
GROUP BY gender
ORDER BY avg_trip_duration;


-- ORDER BY로 순서대로 된 avg_trip_duration의 평균값(AVG)에 대하여 gender별 각각 그룹핑해서 보여줌. 이 데이터셋의 성별을 나타내는 값은 male, female, unknown 등 3가지임.

-- 2. COUNT로 레코드 수 세기
-- 예시: 위의 예제에서 계산한 평균값에 몇 건의 대여 기록이 포함되어 있는지 조회하라.
SELECT gender, COUNT(*) AS rides, AVG(tripduration / 60) AS avg_trip_duration
FROM `bigquery-public-data.new_york_citibike.citibike_trips` 
WHERE tripduration is not null 
GROUP BY gender
ORDER BY avg_trip_duration;


-- 3. HAVING으로 그룹화된 항목 필터링하기
-- HAVING 절을 사용하면 그룹핑한 것을 연산 하여 필터링할 수 있음.
-- 예시: 평균 14분 이상 대여한 성별을 조회하라.
SELECT gender, AVG(tripduration / 60) AS avg_trip_duration
FROM `bigquery-public-data.new_york_citibike.citibike_trips` 
WHERE tripduration is not null 
GROUP BY gender
HAVING avg_trip_duration > 14
ORDER BY avg_trip_duration;

-- 4. DISTINCT로 고윳값 찾기
-- 설명: 데이터셋의 성별 컬럼에 어떤 값이 들어 있는 조회하라. 
-- 중복되지 않고 고유한 값을 찾을땐 DISTINCT 사용함.

SELECT DISTINCT gender
FROM `bigquery-public-data.new_york_citibike.citibike_trips`;

-- 4번째 빈값은 성별 값이 누락되거나 저품질 데이터가 존재해서 보여짐. 
-- 보통 이러한 값들을 결측치(missing value)값이라고 표현하고 주로 NULL 값으로 나옴.
-- WHERE 절에서 NULL 값을 필터링할 때 NULL에 대한 비교 연산은 NULL 값으로 리턴하므로 WHERE 조건으로 적절하지 않음
SELECT bikeid, tripduration, gender
FROM `bigquery-public-data.new_york_citibike.citibike_trips`
WHERE gender = ""
LIMIT 100;


-- 따라서 IS NULL 또는 IN NOT NULL 절을 사용해서 NULL값이 있느냐 아니면 NULL값이 아니냐를 분별할 수 있음
SELECT DISTINCT gender, usertype
FROM `bigquery-public-data.new_york_citibike.citibike_trips`
WHERE gender != '';


-- 실행 결과: 6개의 행이 리턴되는 데, 데이터세트에 존재하는 고유한 성별과 고유한 사용자 유형(구독자 또는 고객)을 바탕으로 가능한 모든 조합에 해당하는 결과는 리턴한다. 


