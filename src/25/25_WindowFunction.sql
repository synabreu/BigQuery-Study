--- ### 23. 윈도우 함수(WINDOW FUNCTION) ### ---

-- 1. 윈도우 함수를 사용하기 전에 예시에 사용된 공통 테이블

# 상품(Produce) 테이블 생성
CREATE TABLE IF NOT EXISTS `my-pc-project-357506.myDataSet.Produce` 
AS 
 (SELECT 'kale' as item, 23 as purchases, 'vegetable' as category
  UNION ALL SELECT 'banana', 2, 'fruit'
  UNION ALL SELECT 'cabbage', 9, 'vegetable'
  UNION ALL SELECT 'apple', 8, 'fruit'
  UNION ALL SELECT 'leek', 2, 'vegetable'
  UNION ALL SELECT 'lettuce', 10, 'vegetable');

SELECT * FROM myDataSet.Produce;

# 직원(Employees) 테이블 생성

CREATE TABLE IF NOT EXISTS `my-pc-project-357506.myDataSet.Employees`
AS
 (SELECT 'Isabella' as name, 2 as department, DATE(1997, 09, 28) as start_date
  UNION ALL SELECT 'Anthony', 1, DATE(1995, 11, 29)
  UNION ALL SELECT 'Daniel', 2, DATE(2004, 06, 24)
  UNION ALL SELECT 'Andrew', 1, DATE(1999, 01, 23)
  UNION ALL SELECT 'Jacob', 1, DATE(1990, 07, 11)
  UNION ALL SELECT 'Jose', 2, DATE(2013, 03, 17));

SELECT * FROM myDataSet.Employees;

# 팜(Farm) 테이블 생성
CREATE TABLE IF NOT EXISTS `my-pc-project-357506.myDataSet.Farm`
AS
 (SELECT 'cat' as animal, 23 as population, 'mammal' as category
  UNION ALL SELECT 'duck', 3, 'bird'
  UNION ALL SELECT 'dog', 2, 'mammal'
  UNION ALL SELECT 'goose', 1, 'bird'
  UNION ALL SELECT 'ox', 2, 'mammal'
  UNION ALL SELECT 'goat', 2, 'mammal');

SELECT * FROM myDataSet.Farm;

-- 2. 총 합계 계산 

# 설명: Produce 테이블의 모든 항목에 대한 총 합계를 계산합니다.

SELECT item, purchases, category, SUM(purchases)
  OVER () AS total_purchases
FROM myDataSet.Produce;

/*
+-------------------------------------------------------+
| item      | purchases  | category   | total_purchases |
+-------------------------------------------------------+
| banana    | 2          | fruit      | 54              |
| leek      | 2          | vegetable  | 54              |
| apple     | 8          | fruit      | 54              |
| cabbage   | 9          | vegetable  | 54              |
| lettuce   | 10         | vegetable  | 54              |
| kale      | 23         | vegetable  | 54              |
+-------------------------------------------------------+
*/


-- 3. 소계 계산 

# 설명: Produce 테이블의 각 카테고리에 대한 소계를 계산합니다.
SELECT item, purchases, category, SUM(purchases)
  OVER (
    PARTITION BY category
    ORDER BY purchases
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
  ) AS total_purchases
FROM myDataSet.Produce;

/*
+-------------------------------------------------------+
| item      | purchases  | category   | total_purchases |
+-------------------------------------------------------+
| banana    | 2          | fruit      | 10              |
| apple     | 8          | fruit      | 10              |
| leek      | 2          | vegetable  | 44              |
| cabbage   | 9          | vegetable  | 44              |
| lettuce   | 10         | vegetable  | 44              |
| kale      | 23         | vegetable  | 44              |
+-------------------------------------------------------+
*/


-- 4. 누적 합계 계산 

# 설명: Produce 테이블의 각 카테고리에 대한 누적 합계를 계산합니다. 합계는 ORDER BY 절을 사용하여 정의된 순서를 기준으로 계산됩니다.

SELECT item, purchases, category, SUM(purchases)
  OVER (
    PARTITION BY category
    ORDER BY purchases
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS total_purchases
FROM myDataSet.Produce;

/*
+-------------------------------------------------------+
| item      | purchases  | category   | total_purchases |
+-------------------------------------------------------+
| banana    | 2          | fruit      | 2               |
| apple     | 8          | fruit      | 10              |
| leek      | 2          | vegetable  | 2               |
| cabbage   | 9          | vegetable  | 11              |
| lettuce   | 10         | vegetable  | 21              |
| kale      | 23         | vegetable  | 44              |
+-------------------------------------------------------+
*/

# 이 예시는 앞의 예시와 동일한 데, 가독성을 높이려는 경우가 아니라면 CURRENT ROW를 경계로 추가할 필요가 없습니다.

SELECT item, purchases, category, SUM(purchases)
  OVER (
    PARTITION BY category
    ORDER BY purchases
    ROWS UNBOUNDED PRECEDING
  ) AS total_purchases
FROM myDataSet.Produce;

# 이 예시에서는 Produce 테이블의 모든 항목이 파티션에 포함되어 있습니다. 
# 이전 행만 분석되기 때문에 파티션의 현재 행 앞에 있는 두 행에서 분석이 시작됩니다.

SELECT item, purchases, category, SUM(purchases)
  OVER (
    ORDER BY purchases
    ROWS BETWEEN UNBOUNDED PRECEDING AND 2 PRECEDING
  ) AS total_purchases
FROM myDataSet.Produce;

/*
+-------------------------------------------------------+
| item      | purchases  | category   | total_purchases |
+-------------------------------------------------------+
| banana    | 2          | fruit      | NULL            |
| leek      | 2          | vegetable  | NULL            |
| apple     | 8          | fruit      | 2               |
| cabbage   | 9          | vegetable  | 4               |
| lettuce   | 10         | vegetable  | 12              |
| kale      | 23         | vegetable  | 21              |
+-------------------------------------------------------+
*/


-- 5. 이동 평균 계산 

# 설명:  Produce 테이블의 이동 평균을 계산합니다. 하한 경계는 현재 행 앞 1개 행입니다. 상한 경계는 현재 행 뒤 1개 행입니다.

SELECT item, purchases, category, AVG(purchases)
  OVER (
    ORDER BY purchases
    ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
  ) AS avg_purchases
FROM myDataSet.Produce;

/*
+-------------------------------------------------------+
| item      | purchases  | category   | avg_purchases   |
+-------------------------------------------------------+
| banana    | 2          | fruit      | 2               |
| leek      | 2          | vegetable  | 4               |
| apple     | 8          | fruit      | 6.33333         |
| cabbage   | 9          | vegetable  | 9               |
| lettuce   | 10         | vegetable  | 14              |
| kale      | 23         | vegetable  | 16.5            |
+-------------------------------------------------------+
*/


-- 6. 범위 내의 항목 수 계산

# 설명: 이 예시에서는 Farm 테이블에 비슷한 인구 수를 가진 동물 수를 가져옵니다.

SELECT animal, population, category, COUNT(*)
  OVER (
    ORDER BY population
    RANGE BETWEEN 1 PRECEDING AND 1 FOLLOWING
  ) AS similar_population
FROM myDataSet.Farm;

/*
+----------------------------------------------------------+
| animal    | population | category   | similar_population |
+----------------------------------------------------------+
| goose     | 1          | bird       | 4                  |
| dog       | 2          | mammal     | 5                  |
| ox        | 2          | mammal     | 5                  |
| goat      | 2          | mammal     | 5                  |
| duck      | 3          | bird       | 4                  |
| cat       | 23         | mammal     | 1                  |
+----------------------------------------------------------+
*/


-- 7. 각 카테고리에서 가장 인기 있는 항목 가져오기

# 설명: 이 예시에서는 각 카테고리에서 가장 인기 있는 항목을 가져옵니다. 
# 윈도우에서 행의 파티션을 어떻게 나누고 각 파티션에서 정렬되는지 정의하는 데, Produce 테이블이 참조됩니다.

SELECT item, purchases, category, LAST_VALUE(item)
  OVER (
    PARTITION BY category
    ORDER BY purchases
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
  ) AS most_popular
FROM myDataSet.Produce;

/*
+----------------------------------------------------+
| item      | purchases  | category   | most_popular |
+----------------------------------------------------+
| banana    | 2          | fruit      | apple        |
| apple     | 8          | fruit      | apple        |
| leek      | 2          | vegetable  | kale         |
| cabbage   | 9          | vegetable  | kale         |
| lettuce   | 10         | vegetable  | kale         |
| kale      | 23         | vegetable  | kale         |
+----------------------------------------------------+
*/


-- 8. 범위의 마지막 값 가져오기

# 설명: 이 예시는 Produce 테이블을 사용하여 특정 윈도우 프레임에서 가장 인기 있는 항목을 가져옵니다. 
# 윈도우 프레임은 한 번에 최대 3개의 행을 분석합니다.  
# 채소에 대한 most_popular 열을 자세히 살펴보면, 특정 카테고리에서 가장 인기 있는 항목을 가져오는 대신 해당 카테고리의 특정 범위에서 가장 인기 있는 항목을 가져옵니다.

SELECT item, purchases, category, LAST_VALUE(item)
  OVER (
    PARTITION BY category
    ORDER BY purchases
    ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
  ) AS most_popular
FROM myDataSet.Produce;

/*
+----------------------------------------------------+
| item      | purchases  | category   | most_popular |
+----------------------------------------------------+
| banana    | 2          | fruit      | apple        |
| apple     | 8          | fruit      | apple        |
| leek      | 2          | vegetable  | cabbage      |
| cabbage   | 9          | vegetable  | lettuce      |
| lettuce   | 10         | vegetable  | kale         |
| kale      | 23         | vegetable  | kale         |
+----------------------------------------------------+
*/

# 이 예시는 이전 예시와 동일한 결과를 반환하지만 item_window라는 윈도우가 포함되어 있습니다. 
# 일부 윈도우 사양은 OVER 절에 직접 정의되고 일부는 명명된 윈도우에 정의됩니다.

SELECT item, purchases, category, LAST_VALUE(item)
  OVER (
    item_window
    ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
  ) AS most_popular
FROM myDataSet.Produce
WINDOW item_window AS (
  PARTITION BY category
  ORDER BY purchases);


-- 9. 순위 계산

# 예시: 시작일을 기준으로 부서 내 각 직원의 순위를 계산합니다. 
# 윈도우 사양은 OVER 절에 직접 정의됩니다. Employees 테이블이 참조됩니다.

SELECT name, department, start_date,
  RANK() OVER (PARTITION BY department ORDER BY start_date) AS rank
FROM myDataSet.Employees;

/*
+--------------------------------------------+
| name      | department | start_date | rank |
+--------------------------------------------+
| Jacob     | 1          | 1990-07-11 | 1    |
| Anthony   | 1          | 1995-11-29 | 2    |
| Andrew    | 1          | 1999-01-23 | 3    |
| Isabella  | 2          | 1997-09-28 | 1    |
| Daniel    | 2          | 2004-06-24 | 2    |
| Jose      | 2          | 2013-03-17 | 3    |
+--------------------------------------------+
*/


-- 10. 윈도우 프레임 절에 명명된 윈도우 사용

# 설명: 명명된 윈도우에 일부 로직을 정의할 수 있으며 일부는 윈도우 프레임 절에 정의할 수 있습니다. 
# 이 로직은 결합되어 있습니다. 
# 예시: Produce 테이블을 사용하는 예시입니다.

SELECT item, purchases, category, LAST_VALUE(item)
  OVER (item_window) AS most_popular
FROM myDataSet.Produce
WINDOW item_window AS (
  PARTITION BY category
  ORDER BY purchases
  ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING);

/*
+-------------------------------------------------------+
| item      | purchases  | category   | most_popular    |
+-------------------------------------------------------+
| banana    | 2          | fruit      | apple           |
| apple     | 8          | fruit      | apple           |
| leek      | 2          | vegetable  | lettuce         |
| cabbage   | 9          | vegetable  | kale            |
| lettuce   | 10         | vegetable  | kale            |
| kale      | 23         | vegetable  | kale            |
+-------------------------------------------------------+
*/




