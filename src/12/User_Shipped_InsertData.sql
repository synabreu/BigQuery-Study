SELECT * FROM `SalesDataSet.INFORMATION_SCHEMA.TABLES`

SELECT * FROM `my-pc-project-357506.SalesDataSet.User_Shipped` LIMIT 1000;

# User_Shipped 테이블에 다중 데이터 추가
BEGIN
  BEGIN TRANSACTION;

    INSERT INTO SalesDataSet.User_Shipped 
    VALUES ('SEAN', 35, True),
           ('JINHO', 45, True),
           ('JAEKYUNG', 100, True),
           ('ROCKY', 50, False),
           ('AMANDA', 20, True),
           ('EMMA', 65, True),
           ('ANDRES', 10, True),
           ('CASEY', 55, True),
           ('HANNAH', 15, False),
           ('ETHAN', 25, False);

  COMMIT TRANSACTION;

EXCEPTION WHEN ERROR THEN
  -- 내부적으로 예외 처리가 발생하면 롤백하고 에러메시지 나타냄
  SELECT @@error.message;
  ROLLBACK TRANSACTION;

END;


