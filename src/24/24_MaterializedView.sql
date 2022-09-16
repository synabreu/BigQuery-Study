-- ### 구체화된 뷰(Materialized View) ### --

-- 1. 구체화된 뷰를 사용하기 전에

# my_base_table 생성
CREATE TABLE IF NOT EXISTS `my-pc-project-357506.myDataSet.my_base_table` (
  product_id INT64 OPTIONS (description = '상품번호'),
  clicks INT64 OPTIONS (description = '클릭수')
) 
OPTIONS (
  description = '구체화된 뷰 예제 - 상품 베이스 테이블'
);

# 임의의 데이터 입력
BEGIN
  BEGIN TRANSACTION;

    INSERT INTO myDataSet.my_base_table 
    VALUES (1, 35),
           (2, 45),
           (3, 100),
           (4, 50),
           (5, 20),
           (6, 65),
           (7, 10),
           (8, 55),
           (9, 15),
           (10, 25),
           (1, 20),
           (2, 55),
           (3, 10),
           (4, 10),
           (5, 90),
           (6, 85),
           (7, 60),
           (8, 35),
           (9, 25),
           (10, 45);

  COMMIT TRANSACTION;

EXCEPTION WHEN ERROR THEN
  -- 내부적으로 예외 처리가 발생하면 롤백하고 에러메시지 나타냄
  SELECT @@error.message;
  ROLLBACK TRANSACTION;

END;

-- 2. 각 제품 ID를 클릭한 수에 대한 구체화된 뷰 생성

CREATE MATERIALIZED VIEW `my-pc-project-357506.myDataSet.my_mv_table` AS (
  SELECT
    product_id,
    SUM(clicks) AS sum_clicks
  FROM
    `my-pc-project-357506.myDataSet.my_base_table`
  GROUP BY
    product_id
);

SELECT * FROM `my-pc-project-357506.myDataSet.my_mv_table`;

-- 3. 구체화된 뷰 삭제 및 테이블 삭제
DROP MATERIALIZED VIEW `my-pc-project-357506.myDataSet.my_mv_table`;
DROP TABLE `my-pc-project-357506.myDataSet.my_base_table`;

