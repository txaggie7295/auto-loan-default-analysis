-- ============================================================
-- 01_segment_analysis.sql
-- Auto Loan Default Risk Analysis
-- Jeffrey A. Symons | Financial Data Analyst
-- 
-- Purpose: Segment vehicle loans by credit score, LTV, and
-- bureau inquiries to identify default risk patterns and
-- assign risk tiers for underwriting policy analysis.
--
-- Output Column Definitions:
--   loans           : Total loans in this segment
--   loan_default    : Total defaults in this segment
--   default_perc    : Default rate for this segment
--   credit_segment  : CIBIL credit score tier with label
--   ltv_band        : Loan-to-Value ratio band
--   inquiries       : Bureau inquiry count band
--   buckets         : Concatenated key (credit|ltv|inquiries)
--   default_bucket  : Default rate range label
--   risk_tier       : 0=Low Risk, 1=Moderate, 2=Elevated, 3=High Risk
--
-- Run this first. Export results to Excel for pivot analysis.
-- ============================================================

SELECT  
    COUNT(*) AS loans,
    SUM(loan_default) AS loan_default,
    ROUND(SUM(loan_default) * 100.0 / COUNT(*), 2) AS default_perc,
    
    -- Credit Score Segment
    -- Note: Scores 0 = No Bureau History (50% of dataset)
    --       Scores 1-100 = CIBIL derogatory status codes
    --       Scores 300-900 = Actual CIBIL credit scores
    CASE 
        WHEN perform_cns_score >= 700 THEN '700-900: Prime'
        WHEN perform_cns_score >= 650 THEN '650-699: Near-Prime'
        WHEN perform_cns_score >= 600 THEN '600-649: Subprime'
        WHEN perform_cns_score >= 300 THEN '300-599: Deep Subprime'
        WHEN perform_cns_score >=   1 THEN '001-100: Derogatory'
        ELSE '000: No Credit History' 
    END AS credit_segment,
    
    -- LTV Band
    CASE 
        WHEN ltv >= 80 THEN '80-99.99'
        WHEN ltv >= 75 THEN '75-79.99'
        WHEN ltv >= 70 THEN '70-74.99'
        WHEN ltv >= 60 THEN '60-69.99'
        WHEN ltv >= 0  THEN '0-59.99' 
        ELSE 'Unknown' 
    END AS ltv_band,   
    
    -- Bureau Inquiries
    CASE 
        WHEN NO_OF_INQUIRIES >= 3 THEN '3'
        WHEN NO_OF_INQUIRIES >= 2 THEN '2'
        WHEN NO_OF_INQUIRIES >= 1 THEN '1'
        ELSE '0' 
    END AS inquiries,    
    
    -- Concatenated Risk Segment Key (credit score | LTV | inquiries)
    CASE 
        WHEN perform_cns_score >= 700 THEN '700-900'
        WHEN perform_cns_score >= 650 THEN '650-699'
        WHEN perform_cns_score >= 600 THEN '600-649'
        WHEN perform_cns_score >= 300 THEN '300-599'
        WHEN perform_cns_score >=   1 THEN '001-100'
        ELSE '000' 
    END 
    || '|' ||   
    CASE 
        WHEN ltv >= 80 THEN '80-99.99'
        WHEN ltv >= 75 THEN '75-79.99'
        WHEN ltv >= 70 THEN '70-74.99'
        WHEN ltv >= 60 THEN '60-69.99'
        WHEN ltv >= 0  THEN '0-59.99'
        ELSE 'Unknown' 
    END
    || '|' ||
    CASE 
        WHEN NO_OF_INQUIRIES >= 3 THEN '3'
        WHEN NO_OF_INQUIRIES >= 2 THEN '2'
        WHEN NO_OF_INQUIRIES >= 1 THEN '1'
        ELSE '0' 
    END AS buckets,
    
    -- Default Rate Bucket Label
    CASE 
        WHEN ROUND(SUM(loan_default) * 100.0 / COUNT(*), 2) >= 25 THEN '25+' 
        WHEN ROUND(SUM(loan_default) * 100.0 / COUNT(*), 2) >= 20 THEN '20-24'
        WHEN ROUND(SUM(loan_default) * 100.0 / COUNT(*), 2) >= 15 THEN '15-19' 
        ELSE '0-14' 
    END AS default_bucket,
    
    -- Risk Tier Assignment
    --   0 = Low Risk    (0-14% default rate)
    --   1 = Moderate    (15-19% default rate)
    --   2 = Elevated    (20-24% default rate)
    --   3 = High Risk   (25%+ default rate)
    CASE 
        WHEN ROUND(SUM(loan_default) * 100.0 / COUNT(*), 2) >= 25 THEN 3 
        WHEN ROUND(SUM(loan_default) * 100.0 / COUNT(*), 2) >= 20 THEN 2
        WHEN ROUND(SUM(loan_default) * 100.0 / COUNT(*), 2) >= 15 THEN 1 
        ELSE 0 
    END AS risk_tier

FROM vehicle_loans
GROUP BY credit_segment, ltv_band, inquiries
HAVING COUNT(*) > 100  -- Exclude statistically unreliable small segments
ORDER BY default_perc DESC;
