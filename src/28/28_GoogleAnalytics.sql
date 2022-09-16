SELECT * FROM `my-pc-project-357506.ga4_obfuscated_sample_ecommerce.events_20210131` LIMIT 1000;

-- 예시: 데이터 세트의 순 이벤트 수, 사용자 수, 일수를 표시합니다.
SELECT
  COUNT(*) AS event_count,
  COUNT(DISTINCT user_pseudo_id) AS user_count,
  COUNT(DISTINCT event_date) AS day_count
FROM `my-pc-project-357506.ga4_obfuscated_sample_ecommerce.events_20210131`;


-- 예시: 총 사용자 'Total User' 와 신규 사용자 'New User' 수를 집계하라. 

WITH
  UserInfo AS (
    SELECT
      user_pseudo_id,
      MAX(IF(event_name IN ('first_visit', 'first_open'), 1, 0)) AS is_new_user
    FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20201130'
    GROUP BY 1
  )
SELECT
  COUNT(*) AS user_count,
  SUM(is_new_user) AS new_user_count
FROM UserInfo;


-- 예시: 구매자 유형당 평균 거래수를 집계 조회하라. 

SELECT
  COUNT(*) / COUNT(DISTINCT user_pseudo_id) AS avg_transaction_per_purchaser
FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE
  event_name IN ('in_app_purchase', 'purchase')
  AND _TABLE_SUFFIX BETWEEN '20201201' AND '20201231';

-- 예시: Flood It 의 데이터 분석에서  데이터 세트의 순 이벤트 수, 사용자 수, 일수를 조회하라.

SELECT
  COUNT(*) AS event_count,
  COUNT(DISTINCT user_pseudo_id) AS user_count,
  COUNT(DISTINCT event_date) AS day_count
FROM `firebase-public-project.analytics_153293282.events_*`;

