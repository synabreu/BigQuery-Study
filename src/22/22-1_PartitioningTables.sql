-- ### 파티셔닝하지 않은 테이블과 파티셔닝한 테이블 생성후 성능 비교하기 ###

-- 1. 파티셔닝 하기 전

# 예제: SQL 쿼리를 실행하여 기존 테이블에서 새 테이블을 생성하여 StackOverflow 게시물을 기반으로 하는 공개 데이터셋에서 로드된 데이터로 파티셔닝하지 않은 테이블을 생성합니다. 
# 이 테이블에는 2018년에 생성된 StackOverflow 게시물이 포함됩니다.
# 주의: stackoverflow 데이터셋이 없다면, stackoverflow 데이터셋을 생성한 후 쿼리문을 실행해야 에러가 발생하지 않습니다.

CREATE OR REPLACE TABLE `my-pc-project-357506.stackoverflow.questions_2018` AS
SELECT * FROM `bigquery-public-data.stackoverflow.posts_questions`
WHERE creation_date BETWEEN '2018-01-01' AND '2018-07-01';

# 실행 세부 정보를 살펴 보십시오. 
# 테이블로 이동해서 스키마와 미리보기를 해서 데이터를 살펴 보십시오. 

# 2018년 1월에 'android' 태그가 지정된 모든 StackOverflow 질문을 가져오기 위해 파티셔닝 테이블을 쿼리해 보겠습니다.

# 쿼리가 실행되기 전에 파티셔닝과 클러스터링된 테이블과 성능을 비교할 때 공정하기 위해 캐싱이 비활성화시킵니다.
# 캐시환경 설정 -> 캐시된 결과 해제 

SELECT id, title, body, accepted_answer_id, creation_date, answer_count, comment_count, favorite_count, view_count 
FROM `my-pc-project-357506.stackoverflow.questions_2018` 
WHERE creation_date BETWEEN '2018-01-01' AND '2018-07-01';

# 실행 세부정보 결과를 보면, 쿼리 결과로 파티션되지 않은 테이블에 대한 쿼리가 2018년에 생성된 StackOverflow 게시물로 전체 5.94GB 데이터를 스캔하는 데 2분 38초가 걸렸음을 알 수 있습니다.

-- 2. 파티셔닝 테이블

# BigQuery DDL 문을 사용하여 DATE/TIMESTAMP로 파티션을 나눈 테이블을 만듭니다. 
# 쿼리 액세스 패턴을 기반으로 파티셔닝 열을 creation_date로 선택했습니다.

CREATE OR REPLACE TABLE `my-pc-project-357506.stackoverflow.questions_2018_partitioned` 
PARTITION BY
 DATE(creation_date) AS
SELECT * FROM `bigquery-public-data.stackoverflow.posts_questions`
WHERE creation_date BETWEEN '2018-01-01' AND '2018-07-01';

# 이제 캐시가 비활성화된 파티션된 테이블에서 이전 쿼리를 실행하여 2018년 1월에 'android' 태그가 지정된 모든 StackOverflow 질문을 가져옵니다.

SELECT id, title, body, accepted_answer_id, creation_date, answer_count, comment_count, favorite_count, view_count 
FROM `my-pc-project-357506.stackoverflow.questions_2018_partitioned` 
WHERE creation_date BETWEEN '2018-01-01' AND '2018-07-01';

# 파티셔닝한 테이블 쿼리는 5.97GB를 처리하는 파티셔닝하지 않은 테이블과 비교하여 1.62MB 데이터를 처리하는 데 필요한 파티션만 스캔했습니다.

# 파티션 관리는 특정 범위에 대해 쿼리할 때 BigQuery 성능과 비용을 최대화하는 데 핵심입니다. 
# 결과적으로 쿼리당 더 적은 데이터를 스캔하고 쿼리 시작 시간 전에 정리가 결정됩니다. 
# 파티셔닝은 비용을 절감하고 성능을 향상시키는 동시에 사용자가 실수로 정말 큰 테이블 전체를 쿼리함으로써 발생하는 비용 폭발을 방지합니다.
