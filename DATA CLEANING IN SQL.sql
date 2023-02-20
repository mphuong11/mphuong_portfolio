--Select data
select * from credit_train order by Loan_ID

--Calculate missing value
SELECT SUM(CASE WHEN loan_id is null THEN 1 ELSE 0 END) as loan_id,
       SUM(CASE WHEN customer_id is null THEN 1 ELSE 0 END) as customer_id,
       SUM(CASE WHEN loan_status is null THEN 1 ELSE 0 END) as loan_status,
       SUM(CASE WHEN Current_Loan_Amount is null THEN 1 ELSE 0 END) as Current_Loan_Amount,
       SUM(CASE WHEN Term is null THEN 1 ELSE 0 END) as Term,
       SUM(CASE WHEN credit_score is null THEN 1 ELSE 0 END) as credit_score,
       SUM(CASE WHEN Annual_Income is null THEN 1 ELSE 0 END) as Annual_Income,
       SUM(CASE WHEN Years_in_current_job is null THEN 1 ELSE 0 END) as Years_in_current_job,
       SUM(CASE WHEN home_ownership is null THEN 1 ELSE 0 END) as home_ownership,
       SUM(CASE WHEN purpose is null THEN 1 ELSE 0 END) as purpose,
       SUM(CASE WHEN monthly_debt is null THEN 1 ELSE 0 END) as monthly_debt,
       SUM(CASE WHEN years_of_credit_history is null THEN 1 ELSE 0 END) as years_of_credit_history,
       SUM(CASE WHEN months_since_last_delinquent is null THEN 1 ELSE 0 END) as months_since_last_delinquent,
       SUM(CASE WHEN number_of_open_accounts is null THEN 1 ELSE 0 END) as number_of_open_accounts,
       SUM(CASE WHEN number_of_credit_problems is null THEN 1 ELSE 0 END) as number_of_credit_problems,
       SUM(CASE WHEN current_credit_balance is null THEN 1 ELSE 0 END) as current_credit_balance,
       SUM(CASE WHEN maximum_open_credit is null THEN 1 ELSE 0 END) as maximum_open_credit,
       SUM(CASE WHEN bankruptcies is null THEN 1 ELSE 0 END) as bankruptcies,
       SUM(CASE WHEN tax_liens is null THEN 1 ELSE 0 END) as tax_liens
FROM credit_train

--Delete duplicate rows
WITH duplicate as(
select *, ROW_NUMBER() OVER (
    PARTITION BY Loan_ID ORDER by loan_id,Current_Loan_Amount, credit_score DESC, Annual_Income DESC, months_since_last_delinquent desc, maximum_open_credit DESC, bankruptcies desc, tax_liens DESC
) row_num
from credit_train)

delete from duplicate WHERE row_num > 1


--Drop column with >50% missing values
select * from credit_train
ALTER TABLE credit_train 
DROP COLUMN months_since_last_delinquent

--Credit score is within the range of 300-850
--Remove this zeros from the values
With credit as (
    select loan_id, credit_score / 10 as Credit_score from credit_train
)
ALTER TABLE credit_train
ADD cre INT

UPDATE credit_train
SET cre = (select credit.Credit_score from credit where credit_train.Loan_ID = credit.loan_id)

UPDATE credit_train 
SET Credit_Score = cre
WHERE Credit_Score > 850

ALTER TABLE credit_train
DROP COLUMN cre

--Fill null values to credit_score by means technique 
Select AVG(credit_score) from credit_train

UPDATE credit_train 
SET Credit_Score = (select AVG(Credit_Score) from credit_train)
WHERE Credit_Score is NULL  

--Fill null values to annual_income by means technique 
select annual_income from credit_train 

Select cast(AVG(cast(Annual_Income as decimal)) as int) from credit_train

UPDATE credit_train 
SET Annual_Income = (Select cast(AVG(cast(Annual_Income as decimal)) as int) from credit_train)
WHERE Annual_Income is NULL  

--Fill null values to Maximum_Open_Credit by means technique 
Select cast(AVG(cast(Maximum_Open_Credit as decimal)) as int) from credit_train

UPDATE credit_train 
SET Maximum_Open_Credit = (Select cast(AVG(cast(Maximum_Open_Credit as decimal)) as int) from credit_train)
WHERE Maximum_Open_Credit is NULL  

--Fill null vaalues by zero
UPDATE credit_train 
SET bankruptcies = 0
WHERE bankruptcies is NULL 

UPDATE credit_train 
SET Tax_Liens = 0
WHERE Tax_Liens is NULL  

--Check
select * from credit_train