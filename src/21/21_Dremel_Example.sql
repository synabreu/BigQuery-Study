
-- 20-1.드레멜 - 빅쿼리 실행 엔진
-- 예시: 대여소 이름별 행의 개수를 가져오는 쿼리

SELECT COUNT(*), start_station_name 
FROM `bigquery-public-data.london_bicycles.cycle_hire`
GROUP BY 2
ORDER BY 1 DESC
LIMIT 10;

# 간단한 스캔을 실행해 값을 집계 하는 데, 스캔 작업은 리프에서 완료됩니다. 
# 집계는 리프보다 높은 수준의 노드에서 완료되어 루트에서 최종 결과를 조합합니다. 
# 트리는 '스캔-필터-집계' 형식의 쿼리 같은 특정 종류의 쿼리에는 적합하지만 그보다 복잡한 쿼리에는 적합하지 않는 단점이 발생합니다.

-- 예시: 정적 트리로 처리가 불가능한 쿼리

SELECT 
  COUNT(*), 
  starts.start_station_id AS point_a,
  ends.start_station_id AS point_b
FROM 
  `bigquery-public-data.london_bicycles.cycle_hire` starts,
  `bigquery-public-data.london_bicycles.cycle_hire` ends
WHERE 
  starts.start_station_id = ends.end_station_id
  AND ends.start_station_id = starts.end_station_id
  AND starts.start_station_id <> ends.start_station_id
  AND starts.start_date = ends.start_date
GROUP BY 2, 3
ORDER BY 1 DESC
LIMIT 10;

# 이 쿼리는 런던의 자전거 대여소 중 하루 동안 가장 완래가 빈번한 곳을 찾는 데 조인을 사용하므로 실행 트리안에 추가 계층이 필요합니다. 
# 현재 드레멜 버전10 에서는 어떤 수의 계층 구조도 가질 수 있는 동적 쿼리 계획을 생성합니다. 
# 심지어 쿼리가 실행되는 동안에도 쿼리 계획을 변경할 수 있습니다. 
# 각 쿼리 단계에서 셔플 단계를 지원하기 때문에 트리와 비슷하게 보이겠지만 필요한 만큼 계층을 추가시킬 수 있는 장점을 가집니다. 

-- 3. 빅쿼리 엔진 실행

-- 3.1 스캔-필터-카운트 쿼리 : 가장 간단한 쿼리로 스캔-필터-카운트(집계) 쿼리로 테이블에서 데이터를 읽어 필터(where)를 적용 한 후 결과의 수를 반환하는 쿼리이다.

SELECT COUNT(*) AS cnt 
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2017`
WHERE passenger_count > 5;

# 이 쿼리는 2017년 뉴욕시의 옐로캡 택시 서비스 사용 기록에서 탑승객이 5명을 초과하는 사용 기록의 수를 계산합니다.
# 이 쿼리를 완료한 후에 쿼리 계획을 보여주는 실행 세부 정보(Execution Details) 탭을 클릭합니다.

-- 3.2 스캔-필터-집계 쿼리 : 데이터를 한 번에 훓어서 실행하는 쿼리입니다. 
-- 대용량 환경에서 어떻게 동작하는지 살펴보기 위해 위키피디아 페이지뷰 로그 중 최신 2022년도 1월 1일 부터 12월 31일까지 가진 데이터를 조회합니다. 
-- 반드시 전체 쿼리를 하면 비용이 많이 들므로 아래의 쿼리로만 사용하기를 권장합니다. 

SELECT title, COUNT(title) AS cnt 
FROM `bigquery-public-data.wikipedia.pageviews_2022`
WHERE datehour BETWEEN '2022-01-01' AND '2022-12-31'
AND title LIKE "G%o%o%g%l%e"
GROUP BY title
ORDER BY cnt DESC;

# 이 쿼리는 G,o,o,g,l,e 문자가 순서대로 들어간 페이지들을 찾아서 각 페이지의 조회 수를 센 후 그 결과를 조회 수가 높은 순으로 반환합니다.


-- 3.3 높은 카디널리티를 갖는 스캔-필터-집계 쿼리

# 3.2과 같은 쿼리지만 필터를 적용하지 않을 때, 제목이 수백만 개가 넘습니다.
# 이러한 경우를 title 컬럼의 카디널리티가 높다고 말합니다. 
# 해시 값을 저장할 버킷의 수가 너무 적으면, 너무 적은 수의 워커 샤드가 너무 많은 작업을 수행해서 쿼리의 실행에 시간이 오래 걸립니다.
# 아래의 예제는 조회 수를 기준으로 내림차순 정렬한 위키피디아 페이지들을 모두 반환합니다. 

SELECT title, COUNT(title) AS cnt 
FROM `bigquery-public-data.wikipedia.pageviews_2022`
WHERE datehour BETWEEN '2022-01-01' AND '2022-12-31'
GROUP BY title
ORDER BY cnt DESC;

# 쿼리 실행 후, 실행 계획 결과를 보면 엄청난 수에 대한 연산이 수행된 것을 볼 것 입니다.
# 왜냐하면, 데이터를 미리 필터링할 수 없기 때문에 처리 시간이 훨씬 오래 걸립니다.  

