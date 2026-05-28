# Auto Loan Default Risk Analysis
### A Credit Risk Analytics Portfolio Project by Jeffrey A. Symons

---

## Business Problem

Auto lenders face a fundamental challenge: how do you identify which loan applicants are likely to default *before* approving them? Approving too many high-risk borrowers increases charge-offs and hurts portfolio profitability. Approving too few leaves money on the table and restricts credit access.

This project analyzes a vehicle loan dataset of 231,464 records to:
- Identify the key credit and demographic factors that predict loan default
- Quantify default rates across credit score, LTV, and bureau inquiry dimensions
- Build a risk segmentation framework using a three-factor composite risk tier
- Simulate the portfolio impact of four underwriting policy scenarios
- Deliver actionable credit policy recommendations backed by data

This mirrors the kind of credit risk analytics I performed throughout my 25-year career in auto finance — analyzing large consumer lending datasets to drive policy decisions, optimize targeting, and improve portfolio performance.

---

## Dataset

**Source:** Vehicle Loan Default Prediction Dataset (Kaggle)
**Records:** 231,464 vehicle loan applications
**Target Variable:** `loan_default` (1 = defaulted, 0 = did not default)
**Overall Portfolio Default Rate:** 21.70%

**Key Features Used:**
- `perform_cns_score` — CIBIL credit score (India's equivalent of FICO)
- `ltv` — Loan-to-Value ratio
- `no_of_inquiries` — Bureau inquiry count
- `loan_default` — Default outcome (target variable)

**Important Dataset Note:**
50.16% of borrowers (116,950 records) have a CIBIL score of 0, indicating **No Bureau History** — borrowers with no credit file. This is characteristic of India's lending market where a large portion of the population remains credit invisible. Additionally, scores below 100 represent **CIBIL derogatory status codes** (prior write-offs, settlements, suits filed) rather than actual credit scores — these borrowers exhibit the highest default rates in the dataset.

---

## Tools Used

- **SQLite / DB Browser for SQLite** — data storage, querying, and analysis
- **SQL** — segmentation, aggregation, risk tiering, policy simulation
- **Excel** — pivot tables, risk matrix visualization, chart development
- **GitHub** — version control and portfolio hosting

---

## Methodology

**Three-Factor Risk Segmentation:**

Loans were segmented across three dimensions:

| Factor | Buckets | Rationale |
|--------|---------|-----------|
| Credit Score | Prime (700-900), Near-Prime (650-699), Subprime (600-649), Deep Subprime (300-599), Derogatory (001-100), No Credit History (000) | Primary default predictor |
| LTV Band | 0-59.99%, 60-69.99%, 70-74.99%, 75-79.99%, 80-99.99% | Secondary risk driver |
| Bureau Inquiries | 0, 1, 2, 3+ | Credit-seeking behavior signal |

Segments with fewer than 100 loans were excluded as statistically unreliable.

**Risk Tier Assignment:**

Each segment was assigned a risk tier based on its observed default rate:

| Risk Tier | Default Rate | Description |
|-----------|-------------|-------------|
| Tier 0 | 0 - 14% | Low Risk |
| Tier 1 | 15 - 19% | Moderate Risk |
| Tier 2 | 20 - 24% | Elevated Risk |
| Tier 3 | 25%+ | High Risk |

---

## Key Findings

### 1. Default Rates Span a 5x Range Across Segments
The lowest-risk segment (Prime borrowers, low LTV, no inquiries) defaults at **8.88%** while the highest-risk segment (No Credit History, high LTV, 3+ inquiries) defaults at **43.15%** — a nearly 5x spread that validates the value of multi-factor risk segmentation.

### 2. Credit Score is the Strongest Single Predictor
Across all LTV and inquiry combinations, higher credit scores consistently produce lower default rates. The gradient is clean and monotonic — every step down in credit tier meaningfully increases default risk.

### 3. LTV Compounds Credit Score Risk
High LTV loans (80-99.99%) default at nearly **1.7x the rate** of low LTV loans (0-59.99%) within the same credit tier. The combination of low credit score AND high LTV produces the most concentrated default exposure in the portfolio.

### 4. Bureau Inquiries Add a Third Risk Signal
Borrowers with 3+ recent bureau inquiries show materially higher default rates than borrowers with 0 inquiries — consistent with the "credit hungry" signal that experienced lenders watch closely. This effect is most pronounced in the already-risky deep subprime and no-credit-history segments.

### 5. No Credit History Borrowers Behave Like Deep Subprime
Despite having no derogatory credit history, borrowers with no credit bureau record (50% of this portfolio) default at rates comparable to deep subprime borrowers. This suggests that **absence of credit history is itself a meaningful risk signal** — and that alternative risk factors (LTV, income, inquiry behavior) must carry more weight when credit scores are unavailable.

### 6. Risk Tier 3 is Disproportionately Costly
The loss density analysis reveals the core portfolio problem:

| Risk Tier | Portfolio Share | Default Share | Loss Density Ratio |
|-----------|----------------|---------------|-------------------|
| Tier 0 - Low Risk | 19.47% | 11.74% | **0.60** |
| Tier 1 - Moderate | 23.11% | 19.08% | **0.83** |
| Tier 2 - Elevated | 28.58% | 30.69% | **1.07** |
| Tier 3 - High Risk | 28.84% | 38.49% | **1.33** |

Tier 3 segments represent **28.84% of loan volume** but generate **38.49% of all defaults** — a loss density ratio of 1.33, meaning every Tier 3 loan generates 33% more default exposure than the average portfolio loan.

---

## Policy Simulation Results

Four underwriting policy scenarios were simulated to quantify the tradeoff between defaults avoided and loan volume lost:

| Scenario | Total Loans | Default Rate | Defaults Avoided | Volume Lost |
|----------|-------------|-------------|-----------------|-------------|
| Current Policy | 231,464 | 21.70% | - | - |
| Policy 1: Decline Tier 3 | 164,718 | 18.76% | **38.49%** | **28.84%** |
| Policy 2: Decline Tiers 2+3 | 98,567 | 15.71% | 69.18% | 57.42% |
| Policy 3: Approve Tier 0 Only | 45,066 | 13.09% | 88.26% | 80.53% |

---

## Business Recommendation

**Policy 1 is the recommended approach.**

By declining only the highest-risk segments (Tier 3 - 25%+ historical default rate), a lender can:
- Reduce the portfolio default rate from **21.70% to 18.76%** - a 2.94 point improvement
- Avoid **38.49% of all defaults** (19,338 defaults eliminated)
- Retain **71.16% of loan volume** (164,718 loans approved)

This represents the most efficient policy tradeoff - for every loan declined, approximately **1.33 defaults are avoided**. More aggressive policies show rapidly diminishing returns: Policy 2 avoids more defaults but at nearly double the volume cost, while Policy 3 is not viable as a lending business.

**Note on APR/Pricing:** This dataset does not contain interest rate data. An extension of this analysis incorporating APR by segment would enable calculation of the optimal risk-based rate premium needed to offset expected credit losses in Tier 2 and Tier 3 segments - allowing a lender to continue approving higher-risk borrowers at a price that reflects their actual risk.

---

## Project Structure

```
auto-loan-default-analysis/
|
+-- README.md                        <- This file
+-- sql/
|   +-- 01_segment_analysis.sql      <- Main segmentation query with risk tiers
|   +-- 02_policy_simulation.sql     <- Four policy scenario simulations
|   +-- 03_risk_tier_summary.sql     <- Portfolio breakdown by risk tier
+-- data/
|   +-- README.md                    <- Dataset download instructions
+-- images/
    +-- (charts and visualizations)  <- To be added
```

---

## How to Run

1. Download the dataset from Kaggle:
   kaggle.com/datasets/avikpaul4u/vehicle-loan-default-prediction
2. Import the CSV into SQLite using DB Browser for SQLite
3. Name the table `vehicle_loans`
4. Run queries in order: 01 -> 02 -> 03
5. Export results to Excel for pivot table analysis and visualization

---

## About the Author

Jeffrey A. Symons is a financial data analyst with 25+ years of experience in consumer and auto lending, specializing in credit risk analytics, portfolio performance monitoring, and data-driven strategy. Currently completing a Data Analytics bootcamp at Texas State University (Python, Tableau, Machine Learning - expected July 2026).

- LinkedIn: linkedin.com/in/jeffsymons
- Email: aggie72_95@att.net
