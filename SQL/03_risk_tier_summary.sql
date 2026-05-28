-- ============================================================
-- 03_risk_tier_summary.sql
-- Auto Loan Default Risk Analysis
-- Jeffrey A. Symons | Financial Data Analyst
--
-- Purpose: Summarize portfolio composition by risk tier.
-- Shows how loans and defaults are distributed across the
-- four risk tiers, and what percentage of the portfolio
-- and total defaults each tier represents.
--
-- Output Column Definitions:
--   risk_tier            : 0=Low Risk, 1=Moderate, 2=Elevated, 3=High Risk
--   risk_tier_label      : Human readable risk tier description
--   segment_count        : Number of unique segments in this tier
--   total_loans          : Total loans in this risk tier
--   total_defaults       : Total defaults in this risk tier
--   default_rate_pct     : Default rate for this risk tier
--   pct_of_portfolio     : % of total loan volume in this tier
--   pct_of_defaults      : % of total defaults in this tier
--   loss_density_ratio   : (% of defaults) / (% of portfolio volume)
--                          > 1.0 = tier generates more defaults than volume share
--                          < 1.0 = tier generates fewer defaults than volume share
--
-- Key Insight:
--   Risk Tier 3 (28.84% of volume) generates 38.49% of all defaults
--   Loss density ratio of 1.33 proves Tier 3 punches above its weight
--   This is the mathematical justification for Policy 1 recommendation
--
-- Actual Results:
--   Tier 0: 19.47% of volume, 11.74% of defaults, ratio = 0.60
--   Tier 1: 23.11% of volume, 19.08% of defaults, ratio = 0.83
--   Tier 2: 28.58% of volume, 30.69% of defaults, ratio = 1.07
--   Tier 3: 28.84% of volume, 38.49% of defaults, ratio = 1.33
-- ============================================================

WITH segment_summary AS (
    SELECT
        -- Concatenated bucket key (credit score | LTV | inquiries)
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
            ELSE '0-59.99' 
        END
        || '|' ||
        CASE 
            WHEN NO_OF_INQUIRIES >= 3 THEN '3'
            WHEN NO_OF_INQUIRIES >= 2 THEN '2'
            WHEN NO_OF_INQUIRIES >= 1 THEN '1'
            ELSE '0' 
        END AS bucket,
        
        COUNT(*) AS loans,
        SUM(loan_default) AS defaults,
        ROUND(SUM(loan_default) * 100.0 / COUNT(*), 2) AS default_rate,
        
        -- Risk Tier Assignment:
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
    GROUP BY bucket
    HAVING COUNT(*) > 100  -- Exclude statistically unreliable small segments
)
-- Risk Tier Summary
SELECT
    risk_tier,
    
    -- Human readable label for each risk tier
    CASE risk_tier
        WHEN 0 THEN 'Tier 0: Low Risk (0-14% Default Rate)'
        WHEN 1 THEN 'Tier 1: Moderate Risk (15-19% Default Rate)'
        WHEN 2 THEN 'Tier 2: Elevated Risk (20-24% Default Rate)'
        WHEN 3 THEN 'Tier 3: High Risk (25%+ Default Rate)'
    END AS risk_tier_label,
    
    COUNT(*) AS segment_count,        -- Number of unique segments in this tier
    SUM(loans) AS total_loans,        -- Total loans in this risk tier
    SUM(defaults) AS total_defaults,  -- Total defaults in this risk tier
    
    -- Default rate for this tier
    ROUND(SUM(defaults) * 100.0 / SUM(loans), 2) AS default_rate_pct,
    
    -- Share of total portfolio volume
    ROUND(SUM(loans) * 100.0 / 
        (SELECT SUM(loans) FROM segment_summary), 2) AS pct_of_portfolio,
    
    -- Share of total portfolio defaults
    ROUND(SUM(defaults) * 100.0 / 
        (SELECT SUM(defaults) FROM segment_summary), 2) AS pct_of_defaults,
    
    -- Loss density ratio: (% of defaults) / (% of portfolio volume)
    -- > 1.0 = this tier generates more defaults than its volume share suggests
    -- < 1.0 = this tier is safer than its volume share suggests
    -- Tier 3 ratio of 1.33 is the core justification for Policy 1
    ROUND(
        (SUM(defaults) * 100.0 / (SELECT SUM(defaults) FROM segment_summary)) /
        (SUM(loans) * 100.0 / (SELECT SUM(loans) FROM segment_summary))
    , 2) AS loss_density_ratio

FROM segment_summary
GROUP BY risk_tier
ORDER BY risk_tier;
