-- ============================================================================
-- SaaS Customer Churn Prediction & Retention Analytics
-- SQL Analysis Queries — RavenStack AI SaaS Platform
-- Author: Poorna Venkat Neelakantam
-- Dataset Credit: River @ Rivalytics (Kaggle)
-- MYSQL VERSION
-- ============================================================================


-- ============================================================================
-- CATEGORY A: CHURN OVERVIEW
-- Business Goal: Understand the overall churn landscape
-- ============================================================================


-- QUERY 1: Overall Churn Rate + Churn Rate by Plan Tier

SELECT *
FROM (
    SELECT
        plan_tier,
        COUNT(*) AS total_accounts,
        SUM(CASE WHEN churn_flag = 'True' THEN 1 ELSE 0 END) AS churned_accounts,
        ROUND(
            SUM(CASE WHEN churn_flag = 'True' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
        ) AS churn_rate_pct
    FROM ravenstack_accounts
    GROUP BY plan_tier

    UNION ALL

    SELECT
        'ALL TIERS' AS plan_tier,
        COUNT(*) AS total_accounts,
        SUM(CASE WHEN churn_flag = 'True' THEN 1 ELSE 0 END) AS churned_accounts,
        ROUND(
            SUM(CASE WHEN churn_flag = 'True' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
        ) AS churn_rate_pct
    FROM ravenstack_accounts
) t
ORDER BY churn_rate_pct DESC;


-- QUERY 2: Churn Rate by Industry

SELECT
    industry,
    COUNT(*) AS total_accounts,
    SUM(CASE WHEN churn_flag = 'True' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        SUM(CASE WHEN churn_flag = 'True' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS churn_rate_pct,
    ROUND(AVG(seats), 1) AS avg_seats
FROM ravenstack_accounts
GROUP BY industry
ORDER BY churn_rate_pct DESC;


-- QUERY 3: Monthly Churn Trend (Cohort-Style)

SELECT
    DATE_FORMAT(DATE(ce.churn_date), '%Y-%m-01') AS churn_month,
    COUNT(DISTINCT ce.account_id) AS churned_accounts,
    SUM(s.mrr_amount) AS mrr_lost
FROM ravenstackk_churn_events ce
JOIN ravenstack_subscriptions s 
    ON ce.account_id = s.account_id
   AND s.churn_flag = 'True'
GROUP BY DATE_FORMAT(DATE(ce.churn_date), '%Y-%m-01')
ORDER BY churn_month;


-- ============================================================================
-- CATEGORY B: REVENUE IMPACT
-- Business Goal: Translate churn into DOLLARS — executives speak revenue
-- ============================================================================


-- QUERY 4: Total MRR Lost to Churn by Plan Tier

SELECT
    a.plan_tier,
    COUNT(DISTINCT a.account_id) AS churned_accounts,
    ROUND(SUM(s.mrr_amount), 2) AS total_mrr_lost,
    ROUND(SUM(s.arr_amount), 2) AS total_arr_lost,
    ROUND(AVG(s.mrr_amount), 2) AS avg_mrr_per_churned_account
FROM ravenstack_accounts a
JOIN ravenstack_subscriptions s 
    ON a.account_id = s.account_id
WHERE a.churn_flag = 'True'
  AND s.churn_flag = 'True'
GROUP BY a.plan_tier
ORDER BY total_mrr_lost DESC;


-- QUERY 5: Revenue at Risk — Active High-Risk Accounts

WITH account_health AS (
    SELECT
        a.account_id,
        a.account_name,
        a.plan_tier,
        a.industry,
        MAX(s.mrr_amount) AS current_mrr,
        COUNT(DISTINCT st.ticket_id) AS total_tickets,
        ROUND(AVG(st.satisfaction_score), 2) AS avg_satisfaction,
        SUM(CASE WHEN st.priority IN ('high', 'urgent') THEN 1 ELSE 0 END) AS critical_tickets,
        MAX(CASE WHEN s.downgrade_flag = 'True' THEN 1 ELSE 0 END) AS had_downgrade
    FROM ravenstack_accounts a
    LEFT JOIN ravenstack_subscriptions s 
        ON a.account_id = s.account_id
    LEFT JOIN support_tickets st 
        ON a.account_id = st.account_id
    WHERE a.churn_flag = 'False'
    GROUP BY a.account_id, a.account_name, a.plan_tier, a.industry
)
SELECT
    account_id,
    account_name,
    plan_tier,
    industry,
    current_mrr,
    total_tickets,
    avg_satisfaction,
    critical_tickets,
    had_downgrade,
    CASE
        WHEN had_downgrade = 1 AND avg_satisfaction < 3 THEN 'CRITICAL'
        WHEN critical_tickets >= 3 OR avg_satisfaction < 3 THEN 'HIGH'
        WHEN total_tickets >= 5 OR avg_satisfaction < 4 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS risk_level
FROM account_health
ORDER BY 
    CASE
        WHEN had_downgrade = 1 AND avg_satisfaction < 3 THEN 1
        WHEN critical_tickets >= 3 OR avg_satisfaction < 3 THEN 2
        WHEN total_tickets >= 5 OR avg_satisfaction < 4 THEN 3
        ELSE 4
    END,
    current_mrr DESC;


-- QUERY 6: Customer Lifetime Value (LTV) by Industry and Plan

SELECT
    a.industry,
    a.plan_tier,
    COUNT(DISTINCT a.account_id) AS total_accounts,
    ROUND(AVG(
        TIMESTAMPDIFF(
            MONTH,
            DATE(a.signup_date),
            COALESCE(DATE(ce.churn_date), CURRENT_DATE)
        )
    ), 1) AS avg_lifetime_months,
    ROUND(AVG(s.mrr_amount), 2) AS avg_mrr,
    ROUND(
        AVG(s.mrr_amount) * AVG(
            TIMESTAMPDIFF(
                MONTH,
                DATE(a.signup_date),
                COALESCE(DATE(ce.churn_date), CURRENT_DATE)
            )
        ), 2
    ) AS estimated_ltv
FROM ravenstack_accounts a
JOIN ravenstack_subscriptions s 
    ON a.account_id = s.account_id
LEFT JOIN churn_events ce 
    ON a.account_id = ce.account_id
GROUP BY a.industry, a.plan_tier
ORDER BY estimated_ltv DESC;


-- ============================================================================
-- CATEGORY C: BEHAVIORAL PATTERNS
-- Business Goal: Understand WHAT churned customers did differently
-- ============================================================================


-- QUERY 7: Feature Usage Comparison — Churned vs Retained

SELECT
    a.churn_flag,
    CASE WHEN a.churn_flag = 'True' THEN 'Churned' ELSE 'Retained' END AS status,
    COUNT(DISTINCT a.account_id) AS accounts,
    COUNT(DISTINCT fu.feature_name) AS distinct_features_used,
    ROUND(AVG(fu.usage_count), 2) AS avg_usage_count,
    ROUND(AVG(fu.usage_duration_secs), 2) AS avg_duration_secs,
    ROUND(AVG(fu.error_count), 2) AS avg_errors
FROM ravenstack_accounts a
JOIN ravenstack_subscriptions s 
    ON a.account_id = s.account_id
JOIN feature_usage fu 
    ON s.subscription_id = fu.subscription_id
GROUP BY a.churn_flag
ORDER BY a.churn_flag;


-- QUERY 8: Support Ticket Analysis — Churned vs Retained

SELECT
    CASE WHEN a.churn_flag = 'True' THEN 'Churned' ELSE 'Retained' END AS status,
    COUNT(DISTINCT a.account_id) AS accounts,
    COUNT(st.ticket_id) AS total_tickets,
    ROUND(COUNT(st.ticket_id) * 1.0 / COUNT(DISTINCT a.account_id), 2) AS tickets_per_account,
    ROUND(AVG(st.satisfaction_score), 2) AS avg_satisfaction,
    ROUND(AVG(st.resolution_time_hours), 2) AS avg_resolution_hours,
    SUM(CASE WHEN st.escalation_flag = 'True' THEN 1 ELSE 0 END) AS escalations
FROM ravenstack_accounts a
LEFT JOIN ravenstack_support_tickets st 
    ON a.account_id = st.account_id
GROUP BY a.churn_flag
ORDER BY a.churn_flag DESC;


-- QUERY 9: Resolution Time Impact on Churn

WITH resolution_buckets AS (
    SELECT
        a.account_id,
        a.churn_flag,
        CASE
            WHEN AVG(st.resolution_time_hours) <= 12 THEN '0-12 hrs'
            WHEN AVG(st.resolution_time_hours) <= 24 THEN '12-24 hrs'
            WHEN AVG(st.resolution_time_hours) <= 48 THEN '24-48 hrs'
            ELSE '48+ hrs'
        END AS resolution_bucket
    FROM ravenstack_accounts a
    JOIN ravenstack_support_tickets st 
        ON a.account_id = st.account_id
    GROUP BY a.account_id, a.churn_flag
)
SELECT
    resolution_bucket,
    COUNT(*) AS total_accounts,
    SUM(CASE WHEN churn_flag = 'True' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        SUM(CASE WHEN churn_flag = 'True' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    ) AS churn_rate_pct
FROM resolution_buckets
GROUP BY resolution_bucket
ORDER BY churn_rate_pct DESC;


-- QUERY 10: Upgrade/Downgrade Patterns Before Churn

SELECT
    CASE WHEN a.churn_flag = 'True' THEN 'Churned' ELSE 'Retained' END AS status,
    COUNT(DISTINCT a.account_id) AS total_accounts,
    SUM(CASE WHEN s.upgrade_flag = 'True' THEN 1 ELSE 0 END) AS total_upgrades,
    SUM(CASE WHEN s.downgrade_flag = 'True' THEN 1 ELSE 0 END) AS total_downgrades,
    ROUND(
        SUM(CASE WHEN s.downgrade_flag = 'True' THEN 1 ELSE 0 END) * 100.0 
        / NULLIF(COUNT(DISTINCT a.account_id), 0), 2
    ) AS downgrade_pct,
    ROUND(
        SUM(CASE WHEN s.upgrade_flag = 'True' THEN 1 ELSE 0 END) * 100.0 
        / NULLIF(COUNT(DISTINCT a.account_id), 0), 2
    ) AS upgrade_pct
FROM ravenstack_accounts a
JOIN ravenstack_subscriptions s 
    ON a.account_id = s.account_id
GROUP BY a.churn_flag
ORDER BY a.churn_flag DESC;


-- QUERY 11: Beta Feature Adoption vs Churn

SELECT
    CASE WHEN a.churn_flag = 'True' THEN 'Churned' ELSE 'Retained' END AS status,
    COUNT(DISTINCT a.account_id) AS accounts,
    SUM(CASE WHEN fu.is_beta_feature = 'True' THEN 1 ELSE 0 END) AS beta_usage_events,
    SUM(CASE WHEN fu.is_beta_feature = 'False' THEN 1 ELSE 0 END) AS standard_usage_events,
    ROUND(
        SUM(CASE WHEN fu.is_beta_feature = 'True' THEN 1 ELSE 0 END) * 100.0 
        / NULLIF(COUNT(fu.usage_id), 0), 2
    ) AS beta_usage_pct,
    ROUND(AVG(CASE WHEN fu.is_beta_feature = 'True' THEN fu.error_count END), 2) AS avg_beta_errors,
    ROUND(AVG(CASE WHEN fu.is_beta_feature = 'False' THEN fu.error_count END), 2) AS avg_standard_errors
FROM ravenstack_accounts a
JOIN ravenstack_subscriptions s 
    ON a.account_id = s.account_id
JOIN feature_usage fu 
    ON s.subscription_id = fu.subscription_id
GROUP BY a.churn_flag
ORDER BY a.churn_flag DESC;


-- ============================================================================
-- CATEGORY D: ADVANCED ANALYTICS
-- Business Goal: Strategic insights that demonstrate senior-level thinking
-- ============================================================================


-- QUERY 12: Cohort Retention Analysis

WITH signup_cohorts AS (
    SELECT
        account_id,
        churn_flag,
        MAKEDATE(YEAR(DATE(signup_date)), 1)
          + INTERVAL (QUARTER(DATE(signup_date)) - 1) * 3 MONTH AS cohort_quarter,
        DATE(signup_date) AS signup_date
    FROM ravenstack_accounts
),
churn_timing AS (
    SELECT
        sc.account_id,
        sc.cohort_quarter,
        sc.churn_flag,
        TIMESTAMPDIFF(
            MONTH,
            sc.signup_date,
            COALESCE(DATE(ce.churn_date), CURRENT_DATE)
        ) AS months_active
    FROM signup_cohorts sc
    LEFT JOIN ravenstack_churn_events ce 
        ON sc.account_id = ce.account_id
)
SELECT
    cohort_quarter,
    COUNT(*) AS cohort_size,
    ROUND(SUM(CASE WHEN months_active >= 3 OR churn_flag = 'False' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS retained_3m_pct,
    ROUND(SUM(CASE WHEN months_active >= 6 OR churn_flag = 'False' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS retained_6m_pct,
    ROUND(SUM(CASE WHEN months_active >= 12 OR churn_flag = 'False' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS retained_12m_pct
FROM churn_timing
GROUP BY cohort_quarter
ORDER BY cohort_quarter;


-- QUERY 13: Churn Reason Distribution with Revenue Impact

SELECT
    ce.reason_code,
    COUNT(DISTINCT ce.account_id) AS churned_accounts,
    ROUND(COUNT(DISTINCT ce.account_id) * 100.0 / (SELECT COUNT(*) FROM churn_events), 2) AS pct_of_all_churn,
    ROUND(SUM(s.mrr_amount), 2) AS total_mrr_lost,
    ROUND(AVG(s.mrr_amount), 2) AS avg_mrr_lost_per_account,
    ROUND(AVG(ce.refund_amount_usd), 2) AS avg_refund,
    SUM(CASE WHEN ce.preceding_downgrade_flag = 'True' THEN 1 ELSE 0 END) AS had_preceding_downgrade,
    SUM(CASE WHEN ce.is_reactivation = 'True' THEN 1 ELSE 0 END) AS reactivations
FROM ravenstack_churn_events ce
JOIN ravenstack_subscriptions s 
    ON ce.account_id = s.account_id
   AND s.churn_flag = 'True'
GROUP BY ce.reason_code
ORDER BY total_mrr_lost DESC;


-- QUERY 14: RFM-Style Scoring for SaaS

WITH account_rfm AS (
    SELECT
        a.account_id,
        a.account_name,
        a.plan_tier,
        a.churn_flag,
        MAX(DATE(fu.usage_date)) AS last_usage_date,
        DATEDIFF(CURRENT_DATE, MAX(DATE(fu.usage_date))) AS days_since_last_usage,
        COUNT(fu.usage_id) AS total_usage_events,
        MAX(s.mrr_amount) AS mrr
    FROM ravenstack_accounts a
    JOIN ravenstack_subscriptions s 
        ON a.account_id = s.account_id
    JOIN ravenstack_feature_usage fu 
        ON s.subscription_id = fu.subscription_id
    GROUP BY a.account_id, a.account_name, a.plan_tier, a.churn_flag
),
rfm_scored AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY days_since_last_usage DESC) AS recency_score,
        NTILE(5) OVER (ORDER BY total_usage_events ASC) AS frequency_score,
        NTILE(5) OVER (ORDER BY mrr ASC) AS monetary_score
    FROM account_rfm
)
SELECT
    account_id,
    account_name,
    plan_tier,
    churn_flag,
    days_since_last_usage,
    total_usage_events,
    mrr,
    recency_score,
    frequency_score,
    monetary_score,
    (recency_score + frequency_score + monetary_score) AS rfm_total,
    CASE
        WHEN (recency_score + frequency_score + monetary_score) >= 13 THEN 'Champion'
        WHEN (recency_score + frequency_score + monetary_score) >= 10 THEN 'Loyal'
        WHEN (recency_score + frequency_score + monetary_score) >= 7 THEN 'At Risk'
        ELSE 'Lost / Hibernating'
    END AS rfm_segment
FROM rfm_scored
ORDER BY rfm_total DESC;


-- QUERY 15: Referral Source Effectiveness — Who Brings Customers That STAY?

SELECT
    a.referral_source,
    COUNT(DISTINCT a.account_id) AS total_accounts,
    SUM(CASE WHEN a.churn_flag = 'True' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        SUM(CASE WHEN a.churn_flag = 'True' THEN 1 ELSE 0 END) * 100.0 / COUNT(DISTINCT a.account_id), 2
    ) AS churn_rate_pct,
    ROUND(AVG(s.mrr_amount), 2) AS avg_mrr,
    ROUND(SUM(s.mrr_amount), 2) AS total_mrr_generated,
    ROUND(AVG(a.seats), 1) AS avg_seats,
    ROUND(
        AVG(s.mrr_amount) * (
            1 - SUM(CASE WHEN a.churn_flag = 'True' THEN 1 ELSE 0 END) * 1.0 / COUNT(DISTINCT a.account_id)
        ), 2
    ) AS retention_weighted_mrr
FROM ravenstack_accounts a
JOIN ravenstack_subscriptions s 
    ON a.account_id = s.account_id
GROUP BY a.referral_source
ORDER BY retention_weighted_mrr DESC;


-- ============================================================================
-- Summary View for Tableau Export
-- Creates the master flat table that feeds both Python and Tableau
-- ============================================================================




SELECT
    a.account_id,
    a.account_name,
    a.industry,
    a.country,
    a.signup_date,
    a.referral_source,
    a.plan_tier,
    a.seats,
    a.is_trial,
    a.churn_flag,

    -- Subscription metrics
    COUNT(DISTINCT s.subscription_id) AS subscription_count,
    MAX(s.mrr_amount) AS latest_mrr,
    MAX(s.arr_amount) AS latest_arr,
    MAX(CASE WHEN s.upgrade_flag = 'True' THEN 1 ELSE 0 END) AS had_upgrade,
    MAX(CASE WHEN s.downgrade_flag = 'True' THEN 1 ELSE 0 END) AS had_downgrade,
    MAX(s.billing_frequency) AS billing_frequency,
    MAX(CASE WHEN s.auto_renew_flag = 'True' THEN 1 ELSE 0 END) AS auto_renew,

    -- Feature usage metrics
    COUNT(DISTINCT fu.feature_name) AS distinct_features_used,
    COALESCE(SUM(fu.usage_count), 0) AS total_usage_count,
    COALESCE(ROUND(AVG(fu.usage_duration_secs), 2), 0) AS avg_usage_duration_secs,
    COALESCE(SUM(fu.error_count), 0) AS total_errors,
    SUM(CASE WHEN fu.is_beta_feature = 'True' THEN 1 ELSE 0 END) AS beta_feature_events,

    -- Support metrics
    COUNT(DISTINCT st.ticket_id) AS total_tickets,
    COALESCE(ROUND(AVG(st.satisfaction_score), 2), 0) AS avg_satisfaction,
    COALESCE(ROUND(AVG(st.resolution_time_hours), 2), 0) AS avg_resolution_hours,
    COALESCE(ROUND(AVG(st.first_response_time_minutes), 2), 0) AS avg_first_response_min,
    SUM(CASE WHEN st.priority IN ('high', 'urgent') THEN 1 ELSE 0 END) AS critical_tickets,
    SUM(CASE WHEN st.escalation_flag = 'True' THEN 1 ELSE 0 END) AS escalations,

    -- Churn event details
    ce.churn_date,
    ce.reason_code,
    ce.refund_amount_usd,
    ce.preceding_upgrade_flag,
    ce.preceding_downgrade_flag,
    ce.is_reactivation,
    ce.feedback_text,

    -- Derived: Customer tenure in months
    TIMESTAMPDIFF(
        MONTH,
        DATE(a.signup_date),
        COALESCE(DATE(ce.churn_date), CURRENT_DATE)
    ) AS tenure_months

FROM ravenstack_accounts a
LEFT JOIN ravenstack_subscriptions s 
    ON a.account_id = s.account_id
LEFT JOIN ravenstack_feature_usage fu 
    ON s.subscription_id = fu.subscription_id
LEFT JOIN ravensatck_support_tickets st 
    ON a.account_id = st.account_id
LEFT JOIN ravenstack_churn_events ce 
    ON a.account_id = ce.account_id

GROUP BY
    a.account_id, a.account_name, a.industry, a.country, a.signup_date,
    a.referral_source, a.plan_tier, a.seats, a.is_trial, a.churn_flag,
    ce.churn_date, ce.reason_code, ce.refund_amount_usd,
    ce.preceding_upgrade_flag, ce.preceding_downgrade_flag,
    ce.is_reactivation, ce.feedback_text

ORDER BY a.churn_flag DESC, latest_mrr DESC;