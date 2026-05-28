-- ============================================================
-- 02_policy_simulation.sql
-- Auto Loan Default Risk Analysis
-- Jeffrey A. Symons | Financial Data Analyst
--
-- Purpose: Simulate the impact of four underwriting policy
-- scenarios on portfolio volume and default rates.
-- Shows the tradeoff between defaults avoided and volume lost
-- under each policy approach.
--
-- Policy Scenarios:
--   Current: Approve all segments
--   Policy 1: Decline Risk Tier 3 (25%+ default rate)
--   Policy 2: Decline Risk Tiers 2+3 (20%+ default rate)
--   Policy 3: Approve only Risk Tier 0 (0-14% default rate)
--
-- Output Column Definitions:
--   scenario             : Name of the policy being simulated
--   total_loans          : Number of loans approved under this policy
--   total_defaults       : Number of defaults remaining under this policy
--   default_rate_pct     : Portfolio default rate under this policy
--   loans_excluded       : Loans declined vs. current policy (volume lost)
--   defaults_avoided     : Defaults eliminated vs. current policy
--   pct_defaults_avoided : % of total defaults eliminated by this policy
--   pct_volume_lost      : % of total loan volume lost by this policy
--
-- Key Insight:
--   Policy 1 is the recommended approach - it avoids 38.49% of all
--   defaults while losing only 28.84% of volume, reducing the
--   portfolio default rate from 21.70% to 18.76%.
--   More aggressive policies show rapidly diminishing returns.
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
            WHEN ltv >= 80 THEN '80-84.99'
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
        
        COUNT(*) AS loans,             -- Total loans in this segment
        SUM(loan_default) AS defaults, -- Total defaults in this segment
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

-- Policy Simulation Results
SELECT
    scenario,             -- Policy being simulated
    total_loans,          -- Loans approved under this policy
    total_defaults,       -- Defaults remaining under this policy
    default_rate_pct,     -- Portfolio default rate under this policy
    loans_excluded,       -- Loans declined vs. current policy
    defaults_avoided,     -- Defaults eliminated vs. current policy
    pct_defaults_avoided, -- % of total defaults eliminated
    pct_volume_lost       -- % of total loan volume lost
FROM (

    -- ── BASELINE: Current Policy ──────────────────────────
    -- Approve all segments regardless of risk tier
    -- Establishes the baseline for comparison
    -- Result: 231,464 loans, 21.70% default rate
    SELECT
        'Current Policy (All Segments)' AS scenario,
        SUM(loans) AS total_loans,
        SUM(defaults) AS total_defaults,
        ROUND(SUM(defaults) * 100.0 / SUM(loans), 2) AS default_rate_pct,
        0 AS loans_excluded,
        0 AS defaults_avoided,
        SUM(loans) AS base_loans,
        SUM(defaults) AS base_defaults,
        0 as pct_defaults_avoided,
        0 as pct_volume_lost
    FROM segment_summary

    UNION ALL

    -- ── POLICY 1: Decline Risk Tier 3 ────────────────────
    -- Decline only highest risk segments (25%+ default rate)
    -- RECOMMENDED: Best balance of defaults avoided vs. volume lost
    -- Result: 38.49% of defaults avoided, 28.84% of volume lost
    --         Default rate improves from 21.70% to 18.76%
    SELECT
        'Policy 1: Decline Risk Tier 3 (25%+ Default Rate)' AS scenario,
        SUM(CASE WHEN risk_tier < 3 THEN loans ELSE 0 END) AS total_loans,
        SUM(CASE WHEN risk_tier < 3 THEN defaults ELSE 0 END) AS total_defaults,
        ROUND(SUM(CASE WHEN risk_tier < 3 THEN defaults ELSE 0 END) * 100.0 / 
              SUM(CASE WHEN risk_tier < 3 THEN loans ELSE 0 END), 2) AS default_rate_pct,
        SUM(CASE WHEN risk_tier = 3 THEN loans ELSE 0 END) AS loans_excluded,
        SUM(CASE WHEN risk_tier = 3 THEN defaults ELSE 0 END) AS defaults_avoided,
        SUM(loans) AS base_loans,
        SUM(defaults) AS base_defaults,
        ROUND(SUM(CASE WHEN risk_tier = 3 THEN defaults ELSE 0 END) *100.0 /
              SUM(defaults),2) as pct_defaults_avoided,
        ROUND(SUM(CASE WHEN risk_tier = 3 THEN loans ELSE 0 END) *100.0 /
              SUM(loans),2)  as pct_volume_lost
    FROM segment_summary

    UNION ALL

    -- ── POLICY 2: Decline Risk Tiers 2 and 3 ─────────────
    -- More aggressive - declines all 20%+ default rate segments
    -- Higher defaults avoided but significant volume impact
    -- Result: 69.18% of defaults avoided, 57.42% of volume lost
    SELECT
        'Policy 2: Decline Risk Tiers 2+3 (20%+ Default Rate)' AS scenario,
        SUM(CASE WHEN risk_tier < 2 THEN loans ELSE 0 END) AS total_loans,
        SUM(CASE WHEN risk_tier < 2 THEN defaults ELSE 0 END) AS total_defaults,
        ROUND(SUM(CASE WHEN risk_tier < 2 THEN defaults ELSE 0 END) * 100.0 / 
              SUM(CASE WHEN risk_tier < 2 THEN loans ELSE 0 END), 2) AS default_rate_pct,
        SUM(CASE WHEN risk_tier >= 2 THEN loans ELSE 0 END) AS loans_excluded,
        SUM(CASE WHEN risk_tier >= 2 THEN defaults ELSE 0 END) AS defaults_avoided,
        SUM(loans) AS base_loans,
        SUM(defaults) AS base_defaults,
        ROUND(SUM(CASE WHEN risk_tier >= 2 THEN defaults ELSE 0 END) *100.0 /
              SUM(defaults),2) as pct_defaults_avoided,
        Round(SUM(CASE WHEN risk_tier >= 2 THEN loans ELSE 0 END) *100.0 /
              SUM(loans),2)  as pct_volume_lost
    FROM segment_summary

    UNION ALL

    -- ── POLICY 3: Approve Only Risk Tier 0 ───────────────
    -- Most restrictive - safest segments only (<15% default rate)
    -- Academically interesting but not viable as a lending business
    -- Result: 88.26% of defaults avoided, 80.53% of volume lost
    SELECT
        'Policy 3: Approve Only Risk Tier 0 (0-14% Default Rate)' AS scenario,
        SUM(CASE WHEN risk_tier = 0 THEN loans ELSE 0 END) AS total_loans,
        SUM(CASE WHEN risk_tier = 0 THEN defaults ELSE 0 END) AS total_defaults,
        
        ROUND(SUM(CASE WHEN risk_tier = 0 THEN defaults ELSE 0 END) * 100.0 / 
              SUM(CASE WHEN risk_tier = 0 THEN loans ELSE 0 END), 2) AS default_rate_pct,
              
        SUM(CASE WHEN risk_tier > 0 THEN loans ELSE 0 END) AS loans_excluded,
        SUM(CASE WHEN risk_tier > 0 THEN defaults ELSE 0 END) AS defaults_avoided,
        SUM(loans) AS base_loans,
        SUM(defaults) AS base_defaults,
        ROUND(SUM(CASE WHEN risk_tier > 0 THEN defaults ELSE 0 END) *100.0 /
              SUM(defaults),2) as pct_defaults_avoided,
        ROUND(SUM(CASE WHEN risk_tier > 0 THEN loans ELSE 0 END) *100.0 /
              SUM(loans),2)  as pct_volume_lost
    FROM segment_summary
);
