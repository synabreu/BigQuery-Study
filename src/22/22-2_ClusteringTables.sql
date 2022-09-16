-- ### 테이블을 클러스터링 하기 ###

-- 1. 테이블을 클러스터팅하기 

# BigQuery DDL 문을 사용하여 새 DATE/TIMESTAMP로 파티션을 나누고 클러스터링된 테이블을 만듭니다. 
# 쿼리 액세스 패턴을 기반으로 파티셔닝 열을 creation_date로, 클러스터 키를 태그로 선택했습니다.

CREATE OR REPLACE TABLE `my-pc-project-357506.stackoverflow.questions_2018_clustered`
PARTITION BY DATE(creation_date)
CLUSTER BY tags AS
SELECT *
FROM `bigquery-public-data.stackoverflow.posts_questions`
WHERE creation_date BETWEEN '2018-01-01' AND '2018-07-01';

# 실행 세부 정보를 보면, 경과 시간은 7초, 사용한 슬롯 시간 4분 19초, 셔플 바이트가 3.39GB 입니다.

# 쿼리가 실행되기 전에 파티셔닝과 클러스터링된 테이블과 성능을 비교할 때 공정하기 위해 캐싱이 비활성화시킵니다.
# 캐시환경 설정 -> 캐시된 결과 해제 

# 캐시가 비활성화된 상태에서 파티셔닝 및 클러스터링된 테이블에서 쿼리를 실행하여 2018년 1월에 'android' 태그가 지정된 모든 StackOverflow 질문을 조회합니다. 

SELECT
 id,
 title,
 body,
 accepted_answer_id,
 creation_date,
 answer_count,
 comment_count,
 favorite_count,
 view_count
FROM
 `my-pc-project-357506.stackoverflow.questions_2018_clustered`
WHERE
 creation_date BETWEEN '2018-01-01' AND '2018-02-01'
 AND tags = 'android';

# 실행 세부정보를 살펴보면, 경과시간 1초, 사용한 슬롯 시간 9초, 셔플 바이트 2.47MB 입니다.

# 파티셔닝 및 클러스터링된 테이블을 사용하여 쿼리는 1초 미만에 ~275MB의 데이터를 스캔했는데, 이는 파티셔닝된 테이블보다 낫습니다. 
# 파티셔닝 및 클러스터링으로 데이터를 구성하는 방식은 슬롯 작업자가 스캔하는 데이터의 양을 최소화하여 쿼리 성능을 개선하고 비용을 최적화합니다.

# 클러스터링을 사용할 때 주의할 몇 가지 사항은 다음과 같습니다. 

# 첫째, 클러스터링은 쿼리를 실행하기 전에 엄격한 비용 보장을 제공하지 않습니다. 
# 클러스터링에 대한 위의 결과에서 쿼리 유효성 검사는 286.1MB의 처리를 보고했지만 실제로 쿼리는 274MB의 데이터만 처리했습니다.

# 둘째, 파티셔닝만 허용하는 것보다 더 세분성이 필요한 경우에만 클러스터링을 사용하기를 추천합니다.
