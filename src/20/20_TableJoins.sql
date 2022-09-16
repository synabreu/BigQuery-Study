
-- 0. TABLE JOIN 사용하기 전에 샘플 테이블 생성하기

-- Roster 테이블: Roster 테이블에는 선수 이름 (LastName) 목록과 해당 학교에 할당된 고유 ID (SchoolID) 목록이 포함되어 있습니다. 

CREATE TABLE IF NOT EXISTS `my-pc-project-357506.myDataSet.Roster` 
(
  LastName STRING,
  SchoolID INT64
) AS 
WITH Roster AS
 (SELECT 'Adams' as LastName, 50 as SchoolID UNION ALL
  SELECT 'Buchanan', 52 UNION ALL
  SELECT 'Coolidge', 52 UNION ALL
  SELECT 'Davis', 51 UNION ALL
  SELECT 'Eisenhower', 77)
SELECT * FROM Roster;


-- PlayerState 테이블: PlayerStats 테이블에는 선수 이름(LastName) 목록과 주어진 경기의 -- 상대에게 할당된 고유 ID(OpponentID)와 해당 경기에서 선수가 기록한 점수(PointsScored)-- 가 포함되어 있습니다.

CREATE TABLE IF NOT EXISTS `my-pc-project-357506.myDataSet.PlayerStats` 
(
  LastName STRING,
  OpponentID INT64,
  PointsScored INT64
) AS 
WITH PlayerStats AS
 (SELECT 'Adams' as LastName, 51 as OpponentID, 3 as PointsScored UNION ALL
  SELECT 'Buchanan', 77, 0 UNION ALL
  SELECT 'Coolidge', 77, 1 UNION ALL
  SELECT 'Adams', 52, 4 UNION ALL
  SELECT 'Buchanan', 50, 13)
SELECT * FROM PlayerStats;

-- TeamMascot 테이블: TeamMascot 테이블에는 고유한 학교 ID (SchoolID) 목록과 해당 학교의 마스코트(Mascot)가 포함되어 있습니다.

CREATE TABLE IF NOT EXISTS `my-pc-project-357506.myDataSet.TeamMascot` 
(
  SchoolID INT64,
  Mascot STRING
) AS
WITH TeamMascot AS
 (SELECT 50 as SchoolID, 'Jaguars' as Mascot UNION ALL
  SELECT 51, 'Knights' UNION ALL
  SELECT 52, 'Lakers' UNION ALL
  SELECT 53, 'Mustangs')
SELECT * FROM TeamMascot;

-- 1. INNER JOIN
-- 이 쿼리는 Roster 및 TeamMascot 테이블에서 INNER JOIN을 수행합니다.

SELECT Roster.LastName, TeamMascot.Mascot
FROM `my-pc-project-357506.myDataSet.Roster` AS Roster 
JOIN `my-pc-project-357506.myDataSet.TeamMascot` AS TeamMascot
ON Roster.SchoolID = TeamMascot.SchoolID;

-- 2. CROSS JOIN

SELECT Roster.LastName, TeamMascot.Mascot
FROM `my-pc-project-357506.myDataSet.Roster` AS Roster 
CROSS JOIN `my-pc-project-357506.myDataSet.TeamMascot` AS TeamMascot;

-- 3. 쉼표 교차 조인 (,)

SELECT Roster.LastName, TeamMascot.Mascot
FROM `my-pc-project-357506.myDataSet.Roster` AS Roster, 
`my-pc-project-357506.myDataSet.TeamMascot` AS TeamMascot;

-- 4. FULL [OUTER] JOIN

SELECT Roster.LastName, TeamMascot.Mascot
FROM `my-pc-project-357506.myDataSet.Roster` AS Roster 
FULL JOIN `my-pc-project-357506.myDataSet.TeamMascot` AS TeamMascot 
ON Roster.SchoolID = TeamMascot.SchoolID;

-- 5. LEFT [OUTER] JOIN

SELECT Roster.LastName, TeamMascot.Mascot
FROM `my-pc-project-357506.myDataSet.Roster` AS Roster 
LEFT JOIN `my-pc-project-357506.myDataSet.TeamMascot` AS TeamMascot 
ON Roster.SchoolID = TeamMascot.SchoolID;

-- 6. RIGHT [OUTER] JOIN

SELECT Roster.LastName, TeamMascot.Mascot
FROM `my-pc-project-357506.myDataSet.Roster` AS Roster 
RIGHT JOIN `my-pc-project-357506.myDataSet.TeamMascot` AS TeamMascot 
ON Roster.SchoolID = TeamMascot.SchoolID;

-- 7. ON
-- 설명: 조인 조건이 TRUE를 반환하면 결합된 행(두 행을 조인한 결과)은 ON 조인 조건을 충족합니다.

SELECT Roster.LastName, TeamMascot.Mascot
FROM `my-pc-project-357506.myDataSet.Roster` AS Roster 
JOIN `my-pc-project-357506.myDataSet.TeamMascot` AS TeamMascot
ON Roster.SchoolID = TeamMascot.SchoolID;

-- 8. USING
-- 설명:  쿼리는 Roster 및 TeamMascot 테이블에서 INNER JOIN을 수행합니다.
-- 이 문은 Roster와 TeamMascot의 행을 반환합니다. 
-- 여기서 Roster.SchoolID은 TeamMascot.SchoolID과 동일합니다. 


SELECT Roster.LastName, TeamMascot.Mascot
FROM `my-pc-project-357506.myDataSet.Roster` AS Roster 
INNER JOIN `my-pc-project-357506.myDataSet.TeamMascot` AS TeamMascot
USING (SchoolID);

