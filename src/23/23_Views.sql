-- ### 뷰(View) ### --

-- 1. 뷰테이블 생성
CREATE VIEW IF NOT EXISTS `my-pc-project-357506`.myDataSet.usa_male_names(name, number) AS (
  SELECT
    name,
    number
  FROM
    bigquery-public-data.usa_names.usa_1910_current
  WHERE
    gender = 'M'
  ORDER BY
    number DESC
);

## 뷰 인포메이션 스키마 쿼리
SELECT * EXCEPT (check_option)
FROM myDataSet.INFORMATION_SCHEMA.VIEWS; 

## 뷰 속성 업데이트 

ALTER VIEW `my-pc-project-357506.myDataSet.usa_male_names`
  SET OPTIONS (
    description = 'NEW_DESCRIPTION'
);

    


## 뷰 삭제
DROP VIEW `my-pc-project-357506.myDataSet.usa_male_names`;


## 뷰 조회 
SELECT * FROM `my-pc-project-357506.myDataSet.usa_male_names_view`;
