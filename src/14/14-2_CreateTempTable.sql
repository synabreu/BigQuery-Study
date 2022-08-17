-- 1. 임시 테이블 만들기
  
  # 예제 설명: Example이라는 임시 테이블을 만들고 값을 입력함.
  # CREATE TEMP TABLE `my-pc-project-357506.myDataSet.TempTable` 
  # 더보기 -> 쿼리 설정 -> 세션 모드 사용

  CREATE TEMP TABLE Example
  ( 
    a INT64,
    b STRING 
  );


  INSERT INTO Example VALUES (5, 'foo');
  INSERT INTO Example VALUES (6, 'bar');

  SELECT * FROM Example;

  # Temp 파일
  DROP TABLE Example;
