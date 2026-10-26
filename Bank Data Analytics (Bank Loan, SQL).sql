CREATE DATABASE bank_loans;
USE bank_loans;

CREATE TABLE loans_raw (
    state_abbr VARCHAR(10),
    account_id VARCHAR(50),
    age VARCHAR(20),
    bh_name VARCHAR(100),
    bank_name VARCHAR(100),
    branch_name VARCHAR(100),
    caste VARCHAR(50),
    center_id BIGINT,
    city VARCHAR(100),
    client_id INT,
    client_name VARCHAR(100),
    close_client VARCHAR(50),
    closed_date DATE,
    credit_officer_name VARCHAR(100),
    date_of_birth DATE,
    disb_by VARCHAR(50),
    disbursement_date DATE,
    disbursement_date_years VARCHAR(20),
    gender_id VARCHAR(10),
    home_ownership VARCHAR(50),
    loan_status VARCHAR(50),
    next_meeting_date DATE,
    product_code VARCHAR(50),
    grade VARCHAR(10),
    sub_grade VARCHAR(10),
    product_id VARCHAR(50),
    purpose_category VARCHAR(100),
    region_name VARCHAR(100),
    religion VARCHAR(50),
    verification_status VARCHAR(50),
    state_abbrre VARCHAR(10),
    state_name VARCHAR(100),
    tranfer_logic VARCHAR(50),
    is_delinquent_loan VARCHAR(5),
    is_default_loan VARCHAR(5),
    age_t VARCHAR(20),
    delinq_2_yrs INT,
    application_type VARCHAR(50),
    loan_amount DECIMAL(15,2),
    funded_amount DECIMAL(15,2),
    funded_amount_inv DECIMAL(15,2),
    term_months INT,
    int_rate DECIMAL(5,2),
    total_pymnt DECIMAL(15,2),
    total_pymnt_inv DECIMAL(15,2),
    total_rec_prncp DECIMAL(15,2),
    total_fees DECIMAL(15,2),
    total_rec_int DECIMAL(15,2),
    total_rec_late_fee DECIMAL(15,2),
    recoveries DECIMAL(15,2),
    collection_recovery_fee DECIMAL(15,2),
    loan_status_calc VARCHAR(50),
    year INT,
    month INT,
    age_group VARCHAR(20),
    closed_flag VARCHAR(5),
    default_flag VARCHAR(5),
    delinquent_flag VARCHAR(5),
    verified_flag VARCHAR(5),
    collection_rate_pct DECIMAL(7,2),
    recovery_rate_pct DECIMAL(7,2)
);
select * from loans_raw;
select count(*) from loans_raw;

# Query 1: Total Loan Amount Funded->Measures the total value of loans disbursed.
SELECT 
    ROUND(SUM(Loan_Amount) / 1000000, 2) AS Total_Loan_Funded_Millions
FROM loans_raw;

# Query 2: Total Loans Count->Tracks how many loans were issued.
SELECT COUNT(*) AS Total_Loans
FROM loans_raw;

# Query 3: Total Collection->Total repayments received (principal + interest).
SELECT 
    ROUND(SUM(Total_Pymnt) / 1000000, 2) AS Total_Collection_Millions
FROM loans_raw;

# Query 4: Total Interest Earned->Revenue earned only from interest.
SELECT SUM(Total_Rrec_int) AS Total_Interest
FROM loans_raw;

#Query 4: Total Interest Earned->Compare loans & collections by branch.
SELECT 
    ROUND((SUM(total_rec_int) / SUM(Loan_Amount)) * 100, 2) AS Interest_Percentage
FROM loans_raw;

# Query 5: Branch-Wise Loan Performance->Compare loans & collections by branch.
SELECT 
    Branch_Name, 
    ROUND(SUM(Loan_Amount) / 1000000, 2) AS Total_Loans_Millions, 
    ROUND(SUM(Total_Pymnt) / 1000000, 2) AS Total_Collection_Millions
FROM loans_raw
GROUP BY Branch_Name
ORDER BY SUM(Loan_Amount) DESC;

# Query 6: State-Wise Loan Portfolio->Distribution of loans across states.
SELECT 
    State_Name, 
    ROUND(SUM(Loan_Amount) / 1000000, 2) AS Total_Loan_Amount_Millions
FROM loans_raw
GROUP BY State_Name
ORDER BY SUM(Loan_Amount) DESC;

# Query 7: Religion-Wise Loan Distribution->Check fairness/inclusivity of lending.
SELECT 
    Religion, 
    COUNT(*) AS Total_Loans,
    ROUND(SUM(Loan_Amount) / 1000000, 2) AS Total_Loan_Amount_Millions
FROM loans_raw
GROUP BY Religion
ORDER BY SUM(Loan_Amount) DESC;

# Query 8: Product Group-Wise Loan->Categorize loans by type (Personal, Auto, etc.).
SELECT 
    Purpose_Category, 
    COUNT(*) AS Loan_Count, 
    ROUND(SUM(Loan_Amount) / 1000000, 2) AS Loan_Amount_Millions
FROM loans_raw
GROUP BY Purpose_Category
ORDER BY Loan_Amount_Millions DESC;

# Query 9: Grade-Wise Loan Risk->Assess loans by credit grades (A, B, C…).
SELECT 
    Grade, 
    COUNT(*) AS Loan_Count, 
    ROUND(AVG(CAST(Int_Rate AS DECIMAL(10,5))) * 100, 2) AS Avg_Int_Rate_Percent
FROM loans_raw
GROUP BY Grade
ORDER BY Grade;

# Query 10: Default Loan Count->How many loans have defaulted?
SELECT COUNT(*) AS Default_Loans
FROM loans_raw
WHERE Is_Default_Loan = 1;

# Query 11: Delinquent Client Count->How many borrowers missed payments?
SELECT COUNT(DISTINCT Client_ID) AS Delinquent_Clients
FROM loans_raw
WHERE Delinq_2_Yrs > 0;

# Query 12: Delinquent Loan Rate->% of loans overdue.
SELECT 
    ROUND(SUM(CASE WHEN Delinq_2_Yrs > 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Delinquent_Rate_Percent
FROM loans_raw;

# Query 13: Default Loan Rate->% of loans that defaulted.
SELECT 
    (COUNT(CASE WHEN Is_Default_Loan = 1 THEN 1 END) / COUNT(*)) * 100 AS Default_Rate
FROM loans_raw;

# Query 14: Age Group-Wise Loan->Loans by borrower age groups.
SELECT 
    CASE 
        WHEN Age < 25 THEN 'Below 25'
        WHEN Age BETWEEN 25 AND 40 THEN '25-40'
        WHEN Age BETWEEN 41 AND 60 THEN '41-60'
        ELSE 'Above 60'
    END AS Age_Group,
    COUNT(*) AS Loan_Count,
    ROUND(SUM(Loan_Amount) / 1000000, 2) AS Total_Amount_Millions
FROM loans_raw
GROUP BY 
    CASE 
        WHEN Age < 25 THEN 'Below 25'
        WHEN Age BETWEEN 25 AND 40 THEN '25-40'
        WHEN Age BETWEEN 41 AND 60 THEN '41-60'
        ELSE 'Above 60'
    END
ORDER BY Age_Group;

# Query 15: Loan Maturity (by Term)->Loan portfolio by repayment terms.
SELECT 
    term_months AS Loan_Term_Months,
    COUNT(*) AS Loan_Count,
    ROUND(SUM(Loan_Amount)/1000000, 2) AS Total_Loan_Millions
FROM loans_raw
GROUP BY term_months
ORDER BY term_months;

# Qury 16: Unverified Loans
SELECT COUNT(*) AS No_Verified_Loans
FROM loans_raw
WHERE Verification_Status = 'Not Verified';

# Qury 16: Views (Reusable tables)
CREATE OR REPLACE VIEW Branch_Loan_Summary_Millions AS
SELECT 
    Branch_Name,
    ROUND(SUM(Loan_Amount)/1000000, 2) AS Total_Amount_Millions,
    ROUND(SUM(Total_Pymnt)/1000000, 2) AS Total_Collection_Millions
FROM loans_raw
GROUP BY Branch_Name
ORDER BY Total_Amount_Millions DESC;

SELECT * FROM Branch_Loan_Summary_Millions;

# Qury 16: Stored Procedure (Reusable function)
CALL StateLoanSummary('Karnataka');

# Window Function: Rank states by loan disbursed
SELECT State_Name, 
       SUM(Loan_Amount) AS Total_Loans,
       RANK() OVER (ORDER BY SUM(Loan_Amount) DESC) AS Loan_Rank
FROM loans_raw
GROUP BY State_Name;

# Window function — Rank branches by total loan and show running total
SELECT branch_name,
       total_loan_amount,
       RANK() OVER (ORDER BY total_loan_amount DESC) AS rank_by_loan,
       SUM(total_loan_amount) OVER (ORDER BY total_loan_amount DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM (
  SELECT branch_name, SUM(loan_amount) AS total_loan_amount
  FROM loans_raw
  GROUP BY branch_name
) t
ORDER BY total_loan_amount DESC;