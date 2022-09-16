-- ### 배열과 구조체 사용 ###

-- 1. 배열

-- 배열 타입 없이 조회
SELECT [1,2] myArray;

-- 배열 타입 지정하여 조회
SELECT ARRAY<INT64>[1] myArray; 

-- 배열 생성
SELECT ARRAY<INT64>[1,2,3] myArray;

-- 배열 생성(초기화와 값 할당)
SELECT [10, 20, 30, 40, 50] AS myNumber;

-- 배열 요소 액세스(색인)

-- 첫번째 배열 요소 가져오기
WITH myNumber AS (
  SELECT [10, 20, 30, 40, 50] AS myInt
)
SELECT myInt[OFFSET(4)] AS offset_1
FROM myNumber;


-- 예시: 다음 테이블에는 ARRAY 데이터 유형의 some_numbers 열이 있습니다. 
-- 이 열의 배열 요소에 액세스하려면 0부터 시작하는 색인의 경우 OFFSET, 
-- 1부터 시작하는 색인의 경우 ORDINAL을 선택하여 사용할 색인 유형을 지정해야 합니다.

WITH sequences AS
  (SELECT [0, 1, 1, 2, 3, 5] AS some_numbers
   UNION ALL SELECT [2, 4, 8, 16, 32] AS some_numbers
   UNION ALL SELECT [5, 10] AS some_numbers)
SELECT some_numbers,
       some_numbers[OFFSET(1)] AS offset_1,
       some_numbers[ORDINAL(1)] AS ordinal_1
FROM sequences;

-- 배열 스키마 생성
CREATE TABLE `my-pc-project-357506.myDataSet.array_demo` AS
WITH myAddressBook AS (
    select ["name","occupation","birth"] AS address_history
)
SELECT address_history FROM myAddressBook;

SELECT address_history FROM `my-pc-project-357506.myDataSet.array_demo`;

-- 구조체 스키마 생성
CREATE TABLE `my-pc-project-357506.myDataSet.struct_demo` AS 
WITH myAddressBook AS (
    select struct("current" as status,
                "seoul" as address,
                "ABC123D" as postcode) as address_history
)
Select address_history FROM myAddressBook;

SELECT address_history FROM `my-pc-project-357506.myDataSet.struct_demo`;

-- 구조체의 배열 스키마 생성
CREATE TABLE `my-pc-project-357506.myDataSet.struct_of_arrays_demo` AS 
WITH myAddressBook AS (
    SELECT [
      struct("current" as status,"seoul" as address,"ABC123D" as postcode),
      struct("previous" AS status, "San Francisco" as address, "74077" as postcode),
      struct("birth" AS status, "Jinhae" AS address, "70000" as postcode) 
    ] AS address_history
)
Select address_history FROM myAddressBook;

-- 데이터 조회
SELECT address_history FROM `my-pc-project-357506.myDataSet.struct_of_arrays_demo`;

-- 스트럭처 내의 배열 한 부분 조회 할 때 에러 발생 (멀티 로우)
SELECT address_history.status, address_history.address 
FROM `my-pc-project-357506.myDataSet.struct_of_arrays_demo`;

-- 모든 struct key-value 쌍은 멀티 로우 값을 가질때 반드시 unnest 문을 사용해야 한다.
SELECT addr.status, addr.address
FROM `my-pc-project-357506.myDataSet.struct_of_arrays_demo`,
UNNEST(address_history) AS addr;


-- 데이터 타입으로써 배열과 스트럭처를 정의한 테이블 생성하기
create table myDataSet.array_struct_tbl 
(
  address_array  ARRAY<INT64>,
  address_struct STRUCT<col1 STRING, col2 INT64>,
  address_array_of_struct ARRAY<STRUCT<col1 STRING, col2 INT64>>,
  address_struct_in_struct STRUCT<col1 STRUCT<col1_1 STRING, col1_2 INT64>, col2 STRING>,
  address_array_of_nested_structs ARRAY<STRUCT<col1 STRUCT<col1_1 STRING, col1_2 INT64>, col2 STRING>>
);

