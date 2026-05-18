-- ============================================================
-- Auto Loan Default Risk Analysis
-- Jeffrey A. Symons | Financial Data Analyst
-- Vehicle Loan Default Prediction Dataset
-- ============================================================

-- ============================================================
-- 1. OVERALL DEFAULT RATE
-- ============================================================
SELECT 
    COUNT(*) AS total_loans,
    SUM(loan_default) AS total_defaults,
    ROUND(SUM(loan_default) * 100.0 / COUNT(*), 2) AS default_rate_pct
FROM vehicle_loans;


-- ============================================================
-- 2. DEFAULT RATE BY CREDIT SCORE TIER
-- Credit score is typically the strongest predictor of default
-- ============================================================
SELECT
    CASE 
        WHEN credit_score >= 750 THEN '750+ (Prime)'
        WHEN credit_score >= 700 THEN '700-749 (Near Prime)'
        WHEN credit_score >= 650 THEN '650-699 (Subprime)'
        WHEN credit_score >= 600 THEN '600-649 (Deep Subprime)'
        ELSE 'Below 600 (Very High Risk)'
    END AS credit_tier,
    COUNT(*) AS loan_count,
    SUM(loan_default) AS defaults,
    ROUND(SUM(loan_default) * 100.0 / COUNT(*), 2) AS default_rate_pct,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS pct_of_portfolio
FROM vehicle_loans
GROUP BY credit_tier
ORDER BY MIN(credit_score) DESC;


-- ============================================================
-- 3. DEFAULT RATE BY LTV BAND
-- High LTV loans carry more risk — lenders use LTV caps
-- as a key credit policy tool
-- ============================================================
SELECT
    CASE
        WHEN ltv <= 80 THEN '0-80% (Low LTV)'
        WHEN ltv <= 90 THEN '81-90%'
        WHEN ltv <= 100 THEN '91-100%'
        WHEN ltv <= 110 THEN '101-110% (Underwater)'
        ELSE '110%+ (High Risk)'
    END AS ltv_band,
    COUNT(*) AS loan_count,
    SUM(loan_default) AS defaults,
    ROUND(SUM(loan_default) * 100.0 / COUNT(*), 2) AS default_rate_pct
FROM vehicle_loans
GROUP BY ltv_band
ORDER BY MIN(ltv);


-- ============================================================
-- 4. DEFAULT RATE BY BUREAU INQUIRY COUNT
-- Multiple recent inquiries signal credit-seeking behavior
-- and are a key risk flag in auto lending
-- ============================================================
SELECT
    CASE
        WHEN no_of_inquiries = 0 THEN '0 Inquiries'
        WHEN no_of_inquiries = 1 THEN '1 Inquiry'
        WHEN no_of_inquiries = 2 THEN '2 Inquiries'
        WHEN no_of_inquiries BETWEEN 3 AND 5 THEN '3-5 Inquiries'
        ELSE '6+ Inquiries'
    END AS inquiry_band,
    COUNT(*) AS loan_count,
    SUM(loan_default) AS defaults,
    ROUND(SUM(loan_default) * 100.0 / COUNT(*), 2) AS default_rate_pct
FROM vehicle_loans
GROUP BY inquiry_band
ORDER BY MIN(no_of_inquiries);


-- ============================================================
-- 5. DEFAULT RATE BY EMPLOYMENT TYPE
-- Employment stability is a key income risk indicator
-- ============================================================
SELECT
    employment_type,
    COUNT(*) AS loan_count,
    SUM(loan_default) AS defaults,
    ROUND(SUM(loan_default) * 100.0 / COUNT(*), 2) AS default_rate_pct
FROM vehicle_loans
GROUP BY employment_type
ORDER BY default_rate_pct DESC;


-- ============================================================
-- 6. RISK SEGMENTATION MATRIX
-- Combining credit score tier and LTV band
-- This is the foundation of a basic risk scorecard
-- ============================================================
SELECT
    CASE 
        WHEN credit_score >= 700 THEN 'Prime (700+)'
        WHEN credit_score >= 650 THEN 'Near Prime (650-699)'
        ELSE 'Subprime (<650)'
    END AS credit_segment,
    CASE
        WHEN ltv <= 90 THEN 'Low LTV (<=90%)'
        WHEN ltv <= 100 THEN 'Medium LTV (91-100%)'
        ELSE 'High LTV (>100%)'
    END AS ltv_segment,
    COUNT(*) AS loan_count,
    SUM(loan_default) AS defaults,
    ROUND(SUM(loan_default) * 100.0 / COUNT(*), 2) AS default_rate_pct,
    CASE
        WHEN ROUND(SUM(loan_default) * 100.0 / COUNT(*), 2) < 12 THEN 'LOW RISK'
        WHEN ROUND(SUM(loan_default) * 100.0 / COUNT(*), 2) < 22 THEN 'MEDIUM RISK'
        ELSE 'HIGH RISK'
    END AS risk_classification
FROM vehicle_loans
GROUP BY credit_segment, ltv_segment
ORDER BY default_rate_pct;


-- ============================================================
-- 7. AVERAGE LOAN CHARACTERISTICS BY DEFAULT STATUS
-- Understand the profile of defaulters vs non-defaulters
-- ============================================================
SELECT
    CASE WHEN loan_default = 1 THEN 'Defaulted' ELSE 'Performing' END AS loan_status,
    COUNT(*) AS loan_count,
    ROUND(AVG(disbursed_amount), 0) AS avg_loan_amount,
    ROUND(AVG(ltv), 1) AS avg_ltv,
    ROUND(AVG(credit_score), 0) AS avg_credit_score,
    ROUND(AVG(no_of_inquiries), 1) AS avg_inquiries,
    ROUND(AVG(age_at_disbursement), 1) AS avg_borrower_age
FROM vehicle_loans
GROUP BY loan_default;


-- ============================================================
-- 8. MONTHLY DEFAULT TREND (if date field available)
-- Vintage analysis — how do default rates vary by origination month?
-- ============================================================
SELECT
    DATE_TRUNC('month', disbursement_date) AS origination_month,
    COUNT(*) AS loans_originated,
    SUM(loan_default) AS defaults,
    ROUND(SUM(loan_default) * 100.0 / COUNT(*), 2) AS default_rate_pct
FROM vehicle_loans
WHERE disbursement_date IS NOT NULL
GROUP BY origination_month
ORDER BY origination_month;


-- ============================================================
-- 9. TOP 10 HIGHEST RISK COMBINATIONS
-- Identify the riskiest segments to inform credit policy
-- ============================================================
SELECT
    CASE 
        WHEN credit_score >= 750 THEN '750+'
        WHEN credit_score >= 700 THEN '700-749'
        WHEN credit_score >= 650 THEN '650-699'
        WHEN credit_score >= 600 THEN '600-649'
        ELSE '<600'
    END AS credit_tier,
    CASE
        WHEN ltv <= 80 THEN '<=80%'
        WHEN ltv <= 90 THEN '81-90%'
        WHEN ltv <= 100 THEN '91-100%'
        WHEN ltv <= 110 THEN '101-110%'
        ELSE '>110%'
    END AS ltv_band,
    employment_type,
    COUNT(*) AS loan_count,
    SUM(loan_default) AS defaults,
    ROUND(SUM(loan_default) * 100.0 / COUNT(*), 2) AS default_rate_pct
FROM vehicle_loans
GROUP BY credit_tier, ltv_band, employment_type
HAVING COUNT(*) >= 100  -- Only segments with meaningful volume
ORDER BY default_rate_pct DESC
LIMIT 10;


-- ============================================================
-- 10. POLICY RECOMMENDATION SIMULATION
-- What if we tightened credit score floor to 650?
-- How much volume do we lose vs. defaults avoided?
-- ============================================================
SELECT
    'Current Policy (All Loans)' AS scenario,
    COUNT(*) AS total_loans,
    SUM(loan_default) AS total_defaults,
    ROUND(SUM(loan_default) * 100.0 / COUNT(*), 2) AS default_rate_pct,
    COUNT(*) - SUM(loan_default) AS performing_loans
FROM vehicle_loans

UNION ALL

SELECT
    'Tightened Policy (Score >= 650)' AS scenario,
    COUNT(*) AS total_loans,
    SUM(loan_default) AS total_defaults,
    ROUND(SUM(loan_default) * 100.0 / COUNT(*), 2) AS default_rate_pct,
    COUNT(*) - SUM(loan_default) AS performing_loans
FROM vehicle_loans
WHERE credit_score >= 650;
