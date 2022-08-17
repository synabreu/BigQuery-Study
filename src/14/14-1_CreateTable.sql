  # 참고 URL: https://cloud.google.com/bigquery/docs/reference/standard-sql/data-definition-language#console

  
  -- ### TABLE 생성 ###
  -- 1. 테이블이 없는 경우에만 TABLE 만들기
  # 설명: mydataset에 이름이 newtable인 테이블이 없는 경우에만 mydataset에 newtable이라는 테이블을 # 만듭니다. 데이터 세트에 테이블 이름이 있는 경우 오류가 반환되지 않고 아무런 작업도 수행되지 않습니다.
  # 주의점: 콘솔에서 테이블 스키마를 검사할 때 STRUCT는 RECORD 열로 표시되고 ARRAY는 REPEATED 열로 # 표시됩니다. STRUCT 및 ARRAY 데이터 유형은 BigQuery에서 중첩 및 반복되는 데이터를 만들 때 사용됩니다.

CREATE TABLE IF NOT EXISTS `my-pc-project-357506.myDataSet.newtable`  
  (x INT64,
   y STRUCT<a ARRAY<STRING>, b BOOL>) 
    OPTIONS( 
      expiration_timestamp=TIMESTAMP "2022-08-15 00:00:00 UTC",
      description="a table that expires in 2022",
      labels=[("org_unit","development")] 
  );

  -- 2. 테이블 만들기 또는 대체
  # myDataSet에 newtable이라는 테이블을 만들고 newtable이 myDataSet에 있으면 빈 테이블로 덮어씁니다.
  CREATE OR REPLACE TABLE myDataSet.newtable2 
  ( x INT64,
    y STRUCT<a ARRAY<STRING>,b BOOL>) 
    OPTIONS( 
      expiration_timestamp=TIMESTAMP "2022-08-15 00:00:00 UTC",
      description="a table that expires in 2022",
      labels=[("org_unit","development")]
  );

  # Table 삭제
DROP TABLE myDataSet.newtable2;
DROP TABLE myDataSet.newtable;

  -- 3. 기존 테이블(쿼리)에서 새 테이블 만들기
  # 설명: bigquery-public-data.samples.shakespeare 에서 corpus 를 가져와 myDataSet에 top_words라는 테이블 생성

CREATE TABLE IF NOT EXISTS `my-pc-project-357506.myDataSet.top_words` 
OPTIONS( description="Top ten words per Shakespeare corpus" ) 
AS
SELECT
  corpus,
  ARRAY_AGG(STRUCT(word,word_count)
  ORDER BY word_count DESC
  LIMIT 10) 
  AS top_words
FROM `bigquery-public-data.samples.shakespeare` 
GROUP BY corpus;

  # DROP TABLE
DROP TABLE myDataSet.top_words;

  -- 4. REQUIRED 열이 있는 테이블 생성
  # mydataset에 newtable라는 테이블을 만듭니다.
  # CREATE TABLE 문의 열 정의 목록에 있는 NOT NULL 한정자는 열 또는 필드가 REQUIRED 모드로 생성되도록 지정합니다.

CREATE TABLE
  myDataSet.newtable 
  ( x INT64 NOT NULL,
    # NOT NULL Required 한정자, 표시하지 않으면 Nuallable (널허용)
    y STRUCT< a ARRAY<STRING>,
    b BOOL NOT NULL,
    c FLOAT64 > NOT NULL,
    # 주의: 콘솔에서 테이블 스키마를 검사할 때 STRUCT는 RECORD 열로 표시되고 ARRAY는 REPEATED 열로 표시됩니다.
    z STRING );

DROP TABLE myDataSet.newtable;

  -- 5. 매개변수화된 데이터 유형이 있는 테이블 만들기
  # 예제 설명: mydataset에 newtable라는 테이블을 만듭니다. 괄호 안의 매개변수는 열에 매개변수화된 데이터 유형이 포함되도록 지정합니다.
  # 매개변수화된 데이터 유형: STRING, BYTES, NUMERIC, BIGNUMERIC 와 같은 매개변수로 선언된 데이터 유형.
 DECLARE myParam STRING(10); # 매개 변수 유형으로 하나의 변수로 선언
 -- SET myParam = "hello"; # x 변수에 "hello" 문자열 할당

 SET myParam = "this string is too long"; # x 변수에 할당은 "this string is too long" 문자열 할당 시 문자열 길이 위반으로 OUT_OF_RANGE 오류 발생


  # 매개변수(Parameter)된 데이터 유형의 테이블 생성
CREATE TABLE
  myDataSet.newtable ( 
    x STRING(10),
    y STRUCT< a ARRAY<BYTES(5)>,
    b NUMERIC(15,
      2),
    c FLOAT64 >,
    z BIGNUMERIC(35) );

### DROP TABLE myDataSet.newtable;

  
-- 6. CREATE SNAPSHOT TABLE 문

 # 예제 설명: myproject.myDataSet.mytable 테이블의 테이블 스냅샷을 만듭니다. 
  # 테이블 스냅샷이 myDataSet 데이터 세트에 생성되고 이름이 mytablesnapshot으로 지정됩니다.
  # 세부 설명: CREATE 문 하나만 허용됩니다.
  # 소스 테이블은 테이블, 테이블 클론, 테이블 스냅샷 들 중 하나어야 함.
  # FOR SYSTEM_TIME AS OF 절은 테이블이나 테이블 클론의 스냅샷을 만들 때만 사용될 수 있으며 테이블 스냅샷을 복사할 때에는 사용될 수 없습니다.

CREATE SNAPSHOT TABLE IF NOT EXISTS `my-pc-project-357506.myDataSet.mytablesnapshot` 
  CLONE `my-pc-project-357506.myDataSet.newtable` 
  OPTIONS( 
    expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 48 HOUR),
    friendly_name="my_table_snapshot",
    description="A table snapshot that expires in 2 days",
    labels=[("org_unit","development")] 
);

DROP SNAPSHOT TABLE myDataSet.mytablesnapshot;

  -- 7. CREATE TABLE CLONE 문

  # 상세정보: 소스 테이블을 기준으로 테이블 클론을 만들고 소스 테이블은 테이블, 테이블 클론 또는 테이블 스냅샷일 수 있다. 
  # 주의사항: 열 목록 대신 CLONE 절을 사용하는 것을 제외하면 이 구문은 CREATE TABLE 구문과 동일합니다.
  # 예제설명: 테이블 스냅샷 myproject.mydataset.mytablesnapshot에서 myproject.mydataset.mytable 테이블을 만듬. 따라서 대상 테이블이 이미 있으면 실패함. 


CREATE TABLE `my-pc-project-357506.myDataSet.mytable` 
  CLONE `my-pc-project-357506.myDataSet.newtable` 
  OPTIONS( 
    expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 365 DAY),
    friendly_name="my_table",
    description="A table that expires in 1 year",
    labels=[("org_unit",
      "development")] 
);

DROP TABLE myDataSet.newtable;
DROP TABLE myDataSet.mytable;
