-- ### BigQueryML 예제 실행하기 ### --

-- 1단계: 빅쿼리UI 에서 census 데이터셋 만들기


-- 2단계: 데이터 검증

# 데이터셋을 검증하고 로지스틱 회귀 모델의 학습 데이터로 사용할 열을 식별합니다.
# 미국 인구조사 데이터셋에서 100개의 행을 반환

SELECT
  age,
  workclass,
  marital_status,
  education_num,
  occupation,
  hours_per_week,
  income_bracket
FROM
  `bigquery-public-data.ml_datasets.census_adult_income`
LIMIT
  100;
  
# 쿼리 결과에서는 census_adult_income 소득 계층인 income_bracket 열에 <=50K 또는 >50K 값 중 하나만 있음을 보여줍니다. 
# census_adult_income 테이블의 교육 수준을 나타내는 education 열과 education_num 열에는 동일한 데이터가 서로 다른 형식으로 표시된다는 것을 보여줍니다. 
# functional_weight 열은 인구조사기관에서 특정 행이 대표한다고 판단하는 개별의 수입니다. 
# 이 functional_weight 열의 값은 특정 행의 income_bracket 값과 관련 없는 것으로 나타납니다.


-- 3단계: 학습 데이터 선택

# 로지스틱 회귀 모델을 학습하는 데 사용되는 데이터를 선택합니다.
# X(Feature): 연령(age), 수행된 작업 유형(workclass),결혼 여부(marital_status), 교육 수준(education_num), 직업(occupation), 주당 근무 시간(hours_per_week), 소득 계층(income_bracket) 
# Y(Label): 인구조사 응답자 소득 계층(predicted_income_bracket)을 분류하여 예측합니다.
# 예시: X 속성을 가진 학습 데이터를 컴파일하는 뷰 생성하기

CREATE OR REPLACE VIEW
  `census.input_view` AS
SELECT
  age,
  workclass,
  marital_status,
  education_num,
  occupation,
  hours_per_week,
  income_bracket,
  CASE
    WHEN MOD(functional_weight, 10) < 8 THEN 'training'
    WHEN MOD(functional_weight, 10) = 8 THEN 'evaluation'
    WHEN MOD(functional_weight, 10) = 9 THEN 'prediction'
  END AS dataframe
FROM
  `bigquery-public-data.ml_datasets.census_adult_income`;

# 결과: 
# 1. 인구조사 응답자의 데이터를 추출하는 데, 응답자의 교육 수준을 나타내는 education_num과 응답자의 직업 유형을 나타내는 workclass가 포함됩니다. 
# 2. 데이터가 중복되는 여러 카테고리를 제외합니다. 예를 들어 census_adult_income 테이블의 education 열과 education_num 열에는 동일한 데이터가 서로 다른 형식으로 표시되므로 이 쿼리는 education 열을 제외합니다. 
# 3. dataframe 열은 제외된 functional_weight 열을 사용하여 학습용 데이터 소스의 80% 라벨을 지정하고 평가 및 예측에 사용하도록 나머지 데이터를 예약합니다. 
# 4. 이러한 열이 포함된 뷰를 만들므로 나중에 이 열을 사용하여 학습 및 예측을 수행할 수 있습니다.

-- ### 실행 한 후 반드시 View 로 저장함. View 이름은 input_view 로 지정함 ###

-- 4단계: 로지스틱 회귀 모델 만들기 --

# 학습 데이터를 검증했으므로 다음 단계에서는 데이터를 사용하여 로지스틱 회귀 모델을 만듭니다.
# CREATE MODEL 문을 'LOGISTIC_REG' 옵션과 함께 사용하면 로지스틱 회귀 모델을 만들고 학습시킵니다. 
# CREATE MODEL 문을 사용하여 이전 쿼리의 뷰에서 새로운 바이너리 로지스틱 회귀 모델을 학습시킵니다.

CREATE OR REPLACE MODEL
  `census.census_model`
OPTIONS
  ( model_type='LOGISTIC_REG',
    auto_class_weights=TRUE,
    data_split_method='NO_SPLIT',
    input_label_cols=['income_bracket'],
    max_iterations=15) AS
SELECT
  * EXCEPT(dataframe)
FROM
  `census.input_view`
WHERE
  dataframe = 'training';

# 쿼리 세부 정보

# 1. CREATE MODEL 문은 SELECT 문의 학습 데이터를 사용하여 모델을 학습시킵니다.
# 2. OPTIONS 절은 모델 유형과 학습 옵션을 지정합니다. 여기서 LOGISTIC_REG 옵션은 로지스틱 회귀 모델 유형을 지정합니다. 바이너리 로지스틱 회귀 모델과 멀티클래스 로지스틱 회귀 모델을 구분하여 지정할 필요는 없습니다. BigQuery ML은 라벨 열의 고유 값 수를 기반으로 학습할 대상을 결정할 수 있습니다.

# 3. input_label_cols 옵션은 SELECT 문에서 라벨 열로 사용할 열을 지정합니다. 여기서 레이블 열은 income_bracket이므로 모델은 각 행에 있는 다른 값을 기반으로 income_bracket의 두 값 중 가장 가능성이 높은 값을 학습합니다.

# 4. 'auto_class_weights=TRUE' 옵션은 학습 데이터에서 클래스 레이블의 균형을 맞춥니다. 기본적으로 학습 데이터는 가중치가 더해지지 않습니다. 학습 데이터 라벨의 균형이 맞지 않는 경우 모델은 가장 인기 있는 라벨 클래스에 더 가중치를 둬서 예측하도록 학습할 수 있습니다. 이 예시에서는 데이터 세트의 응답자 대부분이 저소득층에 속합니다. 이것은 저소득층을 너무 많이 예측하는 모델로 이어질 수 있습니다. 클래스 가중치는 각 클래스의 가중치를 해당 클래스의 빈도에 반비례하게 계산하여 클래스 라벨의 균형을 맞춥니다.

# 5. SELECT 문은 2단계의 뷰를 쿼리합니다. 이 뷰에는 모델 학습용 특성 데이터가 포함된 열만 포함됩니다. WHERE 절은 학습 데이터 프레임에 속하는 행만 학습 데이터에 포함되도록 input_view의 행을 필터링합니다.

-- ### 탐색 패널의 리소스 섹션에서 [PROJECT_ID] > census를 확장한 다음 census_model을 클릭한 후 스키마 탭을 클릭합니다. 모델 스키마는 BigQuery ML이 로지스틱 회귀를 수행하는 데 사용한 속성을 나열합니다. 

-- 5단계: ML.EVALUATE 함수를 사용하여 모델 평가

# 모델을 만든 후에는 ML.EVALUATE 함수를 사용하여 모델의 성능을 평가합니다. ML.EVALUATE 함수는 실제 데이터를 기준으로 예측 값을 평가합니다.

SELECT * FROM ML.EVALUATE 
(MODEL `census.census_model`,
  (
    SELECT
      *
    FROM
      `my-pc-project-357506.census.input_view`
    WHERE
      dataframe = 'evaluation'
  )
);



# 쿼리 세부정보

# ML.EVALUATE 함수는 1단계에서 학습시킨 모델과 SELECT 서브 쿼리에서 반환된 평가 데이터를 받아들입니다. 
# ML.EVALUTE 함수는 모델에 대한 단일 행의 통계를 반환합니다. 
# 예시 쿼리는 input_view의 데이터를 평가 데이터로 사용합니다. WHERE 절은 서브 쿼리에 evaluation 데이터 프레임의 행만 포함되도록 입력 데이터를 필터링합니다.

--- ### 반드시 Query Setting 에서 데이터 위치를 US로 해줘야 함 ### --

# 로지스틱 회귀의 평가 항목은 precision, recall, accuracy, f1_score, log_loss, roc_auc 등이 열에 나타남. (자세한 설명은 PT에 있음)

# 입력 데이터를 제공하지 않고도 ML.EVALUATE를 호출할 수 있습니다. 
# ML.EVALUATE는 자동으로 예약된 평가 데이터 세트를 사용하는 학습 중에 계산된 평가 측정항목을 검색합니다. 
# data_split_method 학습 옵션에 NO_SPLIT가 지정된 이 CREATE MODEL 쿼리에서는 전체 입력 데이터 세트가 학습과 평가에 모두 사용됩니다. 
# 입력 데이터 없이 ML.EVALUATE를 호출하면 학습 데이터셋에서 평가 측정항목이 검색됩니다. 이 평가 효과는 모델 학습 데이터와 별도로 유지된 데이터 세트에 대한 평가 실행보다 적습니다.

-- 6단계: ML.PREDICT 함수를 사용하여 소득 계층 예측 --

# 특정 응답자가 속한 소득 계층을 식별하려면 ML.PREDICT 함수를 사용합니다. 
# 예시 쿼리는 prediction 데이터 프레임에 있는 모든 응답자의 소득 계층을 예측합니다.

SELECT
  *
FROM
  ML.PREDICT (MODEL `my-pc-project-357506.census.census_model`,
    (
    SELECT
      *
    FROM
      `my-pc-project-357506.census.input_view`
    WHERE
      dataframe = 'prediction'
     )
);

  # 쿼리 세부 정보
  # 1. ML.PREDICT 함수는 'prediction' 데이터프레임의 행만 포함하도록 필터링된 input_view의 데이터와 모델을 사용하여 결과를 예측합니다. 
  # 2. 최상위 SELECT 문은 ML.PREDICT 함수의 출력을 조회합니다.
  # 3. predicted_income_bracket은 income_bracket의 예측 값입니다.

  -- 7단계: Explainable AI 메서드로 예측 결과 설명 --

# 모델에서 이러한 예측 결과를 생성하는 이유를 알아보려면 ML.EXPLAIN_PREDICT 함수를 사용하면 됩니다.
# ML.EXPLAIN_PREDICT는 ML.PREDICT의 확장된 버전입니다. 
# ML.EXPLAIN_PREDICT는 예측 결과를 출력할 뿐만 아니라 예측 결과를 설명하는 추가 열을 출력합니다. 
# 따라서 실제로는 ML.EXPLAIN_PREDICT만 실행해야 하며 실행 중인 ML.PREDICT를 건너뜁니다. 

SELECT
*
FROM
ML.EXPLAIN_PREDICT(MODEL `my-pc-project-357506.census.census_model`,
  (
  SELECT
    *
  FROM
    `my-pc-project-357506.census.input_view`
  WHERE
    dataframe = 'evaluation'),
  STRUCT(3 as top_k_features)
);


# 로지스틱 회귀 모델에서 Shapley 값은 모델의 각 특성에 대해 특성 기여값을 생성하는 데 사용됩니다. 
# ML.EXPLAIN_PREDICT는 쿼리에서 top_k_features가 3으로 설정되었기 때문에 제공된 테이블의 행당 특성 기여 항목 3개를 출력합니다. 
# 이러한 기여 항목은 절댓값을 기준으로 내림차순으로 정렬됩니다. 
# 예시의 행 1에서는 hours_per_week 특성이 전체 예측에 가장 많이 기여했지만 이 예시의 행 2에서는 occupation가 전체 예측에 가장 많이 기여했습니다.

