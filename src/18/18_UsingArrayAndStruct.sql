

-- 1. 문자열 함수 SPLIT 사용 

-- 설명: 단어를 특정 구분자를 기준으로 나누고 싶은 경우 사용하는 함수
-- 예를 들면, "a, b, c"라고 하나의 컬럼에 저장된 경우 SPLIT 함수를 사용하면 a, b, c로 나눔
-- 여러 내용을 한번에 저장하는 경우에 쉼표(,), 탭(\t)을 보편적으로 사용함

WITH letters AS (
  SELECT "" AS letter_group
  UNION ALL
  SELECT "a" AS letter_group
  UNION ALL
  SELECT "b c d" AS letter_group
)
SELECT 
  SPLIT(letter_group, " ") AS example
FROM letters;

-- 예시: 배열로 들어가 있는 문자열 데이터를 나누어서 조회하라. 
WITH US_Cities AS (
    SELECT * FROM UNNEST([
    'Seattle WA', 'NewYork NY', 'SanFrancisco CA'
  ]) AS city
)
SELECT city, SPLIT(city, ' ') AS Parts
FROM US_Cities;
-- 결과: UNNEST 연산자는 ARRAY를 입력으로 받고 ARRAY의 각 요소에 대한 행이 한 개씩 포함된 객체에 대해 return함


-- 예시: 대여 횟수가 2,000회 미만인 두 행의 데이터를 가진 작은 데이터셋을 만들어라. (하드코딩)
WITH trip_count AS (
    SELECT 'Fri' As day, 1550 AS numrides, 101 AS oneways
    UNION ALL SELECT 'Sat', 3300, 736
    UNION ALL SELECT 'Sun', 2275, 888
)
SELECT * FROM trip_count WHERE numrides < 2000;

-- 2. ARRAY_AGG 배열 만들기
-- 예시: 성별 및 연도별 대여 횟수를 찾아라.

SELECT gender, EXTRACT(YEAR FROM starttime) AS year, count(*) AS numtrips
FROM `bigquery-public-data.new_york_citibike.citibike_trips` 
WHERE gender != 'unknown' AND starttime IS NOT NULL
GROUP BY gender, year
HAVING year > 2016;

-- 예시: 여러 해에 걸쳐 성별과 관련된 대여 횟수를 시계열으로 조회하라.
--      이런 결과를 만들때 대여 횟수를 배열로 만들어야 하는 데, ARRAY 타입을 사용해 해당 배열을 쿼리하고 ARRAY_AGG 함수로 배열을 생성한다. 

WITH gender_year_numtrips AS (
  SELECT gender, EXTRACT(YEAR FROM starttime) AS year, count(1) AS numtrips
  FROM `bigquery-public-data.new_york_citibike.citibike_trips` 
  WHERE gender != 'unknown' AND starttime IS NOT NULL
  GROUP BY gender, year
  HAVING year > 2016
)
SELECT gender, ARRAY_AGG(numtrips order by year) AS numtrips, 
FROM gender_year_numtrips 
GROUP BY gender;

-- 결과 화면: 일반적으로 성별을 그룹화할 때에는 AVG(numtrips) 와 같은 함수로 그룹의 단일 스칼라 값을 계산해 모든 연도의 평균 대여 횟수를 찾는다. 
-- 그러나 ARRAY_AGG를 사용하면 개별 값을 수집해 순서가 있는 리스트 또는 배열(Array)에 넣을 수 있다.
-- ARRAY 타입은 쿼리 결과 뿐만 아니라 JSON과 같은 계층 형식의 데이터를 보여줄 때도 사용한다. 

-- 3. 구조체(Struct)
-- 설명: 구조체는 순서를 갖는 필드의 그룹이다. 
-- 필드에는 원하는 이름을 지정하는 이유는 가독성 때문이다. 생략하면 빅쿼리에서는 이름을 지정한다. 

SELECT [
  STRUCT('female' AS gender, [3236735,1260893] AS numtrips),
  STRUCT('male' AS gender, [9306602,3955871] AS numtrips)
] AS bikerides;

# JSON 문서 내용
# [{
#  "gender": "female",
#  "numtrips": ["3236735", "1260893"]
# }, {
#  "gender": "male",
#  "numtrips": ["9306602", "3955871"]
# }]

-- 4. 튜플(Tuple)
-- 설명: STRUCT 키워드와 필드명을 생략하면 튜플 또는 익명 구조체(anonymous struct)가 생성된다. 
-- 빅쿼리는 쿼리 결과에서 이름이 지정되지 않은 컬럼과 구조체 필드에 의해 임의의 이름을 할당한다. 
-- 컬럼명의 별칭이 생략하면 쿼리 필드명을 읽기도 어렵고 유지보수도 어렵다. 반드시 별칭을 붙여 가독성을 높펴라.

SELECT [
  STRUCT('female', [3236735,1260893]),
  STRUCT('male', [9306602,3955871])
] AS bikerides;


-- 5. 배열 활용하기
-- 설명: 배열을 생성했다면 배열의 길이를 찾을 수도 있고 배열 내의 개별 항목을 탐색한다. 


WITH gender_numtrips_array AS (
  SELECT [
    STRUCT('female' AS gender, [3236735,1260893] AS numtrips),
    STRUCT('male' AS gender, [9306602,3955871] AS numtrips)
  ] AS bikerides
)
SELECT 
  ARRAY_LENGTH(bikerides) AS num_items,
  bikerides[OFFSET(0)].gender AS first_gender
FROM gender_numtrips_array;

-- 6. 배열 풀기
-- 예시: 다음 쿼리에서 SELECT 절을 배열을 포함하는 행 1개만을 반환하기 때문에 두 성별 데이터가 같은 행을 반환한다.

SELECT 
[
  STRUCT('female' AS gender, [3236735,1260893] AS numtrips),
  STRUCT('male' AS gender, [9306602,3955871] AS numtrips)
];

-- 예시: 이 때 UNNEST를 사용하면 배열의 요소를 행으로 반환하기 때문에 결과 배열을 풀면 배열의 각 항목에 해당되는 행을 가져올 수 있다. 

SELECT * FROM UNNEST(
[
  STRUCT('female' AS gender, [3236735,1260893] AS numtrips),
  STRUCT('male' AS gender, [9306602,3955871] AS numtrips)
]);

-- 특정 컬럼인 배열의 일부만 선택할 수 있음.
SELECT numtrips FROM UNNEST(
[
  STRUCT('female' AS gender, [3236735,1260893] AS numtrips),
  STRUCT('male' AS gender, [9306602,3955871] AS numtrips)
]);






