# Auto Loan Default Risk Analysis
### A Credit Risk Analytics Portfolio Project by Jeffrey A. Symons

---

## Business Problem

Auto lenders face a fundamental challenge: how do you identify which loan applicants are likely to default *before* approving them? Approving too many high-risk borrowers increases charge-offs and hurts portfolio profitability. Approving too few leaves money on the table and reduces volume.

This project analyzes a vehicle loan dataset to:
- Identify the key credit and demographic factors that predict loan default
- Quantify the default rate across different risk segments
- Build a simple scoring framework that could support underwriting strategy
- Deliver actionable insights a lending team could act on

This mirrors the kind of credit risk analytics I performed throughout my 25-year career in auto finance — analyzing large consumer lending datasets to drive policy decisions, optimize targeting, and improve portfolio performance.

---

## Dataset

**Source:** Vehicle Loan Default Prediction Dataset (Kaggle)  
**Records:** ~199,000 vehicle loan applications  
**Target Variable:** `loan_default` (1 = defaulted, 0 = did not default)  
**Key Features:**
- Credit bureau attributes (credit score, bureau inquiries, delinquency history)
- Loan characteristics (loan amount, LTV, asset cost, disbursed amount)
- Borrower demographics (age, employment type, income)
- Account history (primary/secondary account history)

**Overall Default Rate:** ~17.6% (35,428 defaults out of 199,717 records)

---

## Tools Used

- **SQL** — data exploration, KPI calculations, risk segmentation queries
- **Python (Pandas, Matplotlib, Seaborn)** — data analysis and visualization
- **JupyterLab** — interactive analysis environment
- **GitHub** — version control and portfolio hosting

---

## Key Findings

### 1. Credit Score is the Strongest Default Predictor
Borrowers with lower credit scores default at significantly higher rates. The data shows a clear inverse relationship between credit score and default probability — consistent with industry experience in subprime auto lending.

### 2. Bureau Inquiries Signal Risk
Borrowers with 3+ recent bureau inquiries default at nearly 2x the rate of borrowers with 0-1 inquiries. This aligns with the "credit hungry" signal that experienced auto lenders watch closely.

### 3. LTV is a Key Risk Driver
High LTV loans (>100%) default at materially higher rates than lower LTV loans. This validates the industry practice of using LTV caps as a credit policy tool — something I applied directly at OpenRoad Lending when identifying lender approval barriers.

### 4. Employment Type Matters
Self-employed borrowers show higher default rates than salaried employees — consistent with income volatility risk in consumer lending.

### 5. A Simple Risk Segmentation Framework
By combining credit score tiers and LTV bands, we can create a basic risk scorecard that separates the portfolio into low, medium, and high risk segments with meaningfully different default rates:

| Risk Tier | Default Rate | % of Portfolio |
|-----------|-------------|----------------|
| Low Risk | ~8% | ~35% |
| Medium Risk | ~17% | ~45% |
| High Risk | ~31% | ~20% |

---

## Business Recommendations

Based on this analysis, a lending team could:

1. **Tighten credit score floor** — applicants below a threshold score should require compensating factors (lower LTV, stronger employment) before approval
2. **Add LTV caps by credit tier** — high LTV + low credit score is the highest risk combination and deserves the most conservative policy
3. **Flag bureau inquiry spikes** — 3+ inquiries in the past 6 months should trigger additional review
4. **Segment direct mail targeting** — use credit tier and employment type to identify lower-risk prospects for acquisition campaigns, improving response-to-funding conversion

These are the kinds of data-driven policy recommendations I delivered throughout my career in auto finance.

---

## Project Structure

```
auto-loan-default-analysis/
│
├── README.md                  # This file — project overview and findings
├── data/
│   └── README.md              # Data source description (data not included — download from Kaggle)
├── sql/
│   └── analysis.sql           # SQL queries for data exploration and KPI analysis
└── notebooks/
    └── analysis.ipynb         # Python analysis and visualizations
```

---

## About the Author

Jeffrey A. Symons is a financial data analyst with 25+ years of experience in consumer and auto lending, specializing in credit risk analytics, portfolio performance monitoring, and data-driven strategy. Currently completing a Data Analytics bootcamp at Texas State University (Python, Tableau, Machine Learning — expected July 2026).

- LinkedIn: [linkedin.com/in/jeffsymons](https://linkedin.com/in/jeffsymons)
- Email: aggie72_95@att.net
