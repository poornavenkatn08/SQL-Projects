-- ============================================================================
-- SaaS Customer Churn Prediction & Retention Analytics
-- Schema Creation Script — RavenStack AI SaaS Platform
-- Author: Poorna Venkat Neelakantam
-- Dataset Credit: River @ Rivalytics (Kaggle)
-- 
-- BUSINESS CONTEXT: RavenStack is a stealth-mode AI SaaS startup delivering
-- AI-driven team tools. This schema captures every sign-up, subscription,
-- feature use, support ticket, and churn event from their pilot program.
--
-- TABLE RELATIONSHIPS:
-- accounts (PK: account_id)
--   ├── subscriptions (FK → accounts.account_id)
--   │   └── feature_usage (FK → subscriptions.subscription_id)
--   ├── support_tickets (FK → accounts.account_id)
--   └── churn_events (FK → accounts.account_id)
-- ============================================================================


-- ============================================================================
-- STEP 1: DROP EXISTING TABLES (if re-running)
-- Order matters due to foreign key dependencies — drop children first
-- ============================================================================
USE Raven_stack;
DROP TABLE IF EXISTS churn_events;
DROP TABLE IF EXISTS support_tickets;
DROP TABLE IF EXISTS feature_usage;
DROP TABLE IF EXISTS subscriptions;
DROP TABLE IF EXISTS accounts;


-- ============================================================================
-- STEP 2: CREATE TABLES
-- ============================================================================


-- TABLE 1: ACCOUNTS (500 rows)
-- The core customer table. Each row = one company using RavenStack.
-- This is the parent table that all other tables reference.

CREATE TABLE accounts (
    account_id          VARCHAR(20)     PRIMARY KEY,
    account_name        VARCHAR(100)    NOT NULL,
    industry            VARCHAR(50)     NOT NULL,       -- DevTools, FinTech, Cybersecurity, HealthTech, EdTech
    country             VARCHAR(10)     NOT NULL,       -- ISO-2 country code (US, UK, IN, AU, DE, CA, FR)
    signup_date         DATE            NOT NULL,
    referral_source     VARCHAR(50)     NOT NULL,       -- organic, ads, event, partner, other
    plan_tier           VARCHAR(20)     NOT NULL,       -- Basic, Pro, Enterprise
    seats               INTEGER         NOT NULL,       -- Licensed user count (1-163)
    is_trial            VARCHAR(10)     NOT NULL,       -- 'True' or 'False' (stored as text)
    churn_flag          VARCHAR(10)     NOT NULL        -- 'True' or 'False' (stored as text)
);


-- TABLE 2: SUBSCRIPTIONS (5,000 rows)
-- Tracks every subscription period for each account.
-- One account can have multiple subscriptions (upgrades, renewals, plan changes).

CREATE TABLE subscriptions (
    subscription_id     VARCHAR(20)     PRIMARY KEY,
    account_id          VARCHAR(20)     NOT NULL,
    start_date          DATE            NOT NULL,
    end_date            DATE,                           -- NULL = currently active subscription
    plan_tier           VARCHAR(20)     NOT NULL,       -- Plan at time of billing
    seats               INTEGER         NOT NULL,
    mrr_amount          DECIMAL(10,2)   NOT NULL,       -- Monthly Recurring Revenue ($0 - $33,830)
    arr_amount          DECIMAL(12,2)   NOT NULL,       -- Annual Recurring Revenue
    is_trial            VARCHAR(10)     NOT NULL,       -- 'True' or 'False'
    upgrade_flag        VARCHAR(10)     NOT NULL,       -- 'True' if upgraded mid-cycle
    downgrade_flag      VARCHAR(10)     NOT NULL,       -- 'True' if downgraded mid-cycle
    churn_flag          VARCHAR(10)     NOT NULL,       -- 'True' if subscription ended
    billing_frequency   VARCHAR(20)     NOT NULL,       -- 'monthly' or 'annual'
    auto_renew_flag     VARCHAR(10)     NOT NULL,       -- 'True' or 'False' (~80% True)

    CONSTRAINT fk_subscriptions_account
        FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);


-- TABLE 3: FEATURE_USAGE (25,000 rows)
-- Tracks which product features each subscription used, when, and how much.
-- Links to subscriptions (not directly to accounts).

CREATE TABLE feature_usage (
    usage_id                VARCHAR(20)     PRIMARY KEY,
    subscription_id         VARCHAR(20)     NOT NULL,
    usage_date              DATE            NOT NULL,
    feature_name            VARCHAR(50)     NOT NULL,   -- From pool of 40 SaaS features
    usage_count             INTEGER         NOT NULL,   -- Event frequency
    usage_duration_secs     INTEGER         NOT NULL,   -- Time spent in seconds
    error_count             INTEGER         NOT NULL,   -- Logged errors during usage
    is_beta_feature         VARCHAR(10)     NOT NULL,   -- 'True' for ~10% of features

    CONSTRAINT fk_feature_usage_subscription
        FOREIGN KEY (subscription_id) REFERENCES subscriptions(subscription_id)
);


-- TABLE 4: SUPPORT_TICKETS (2,000 rows)
-- Every support interaction filed by a customer.
-- Links directly to accounts.

CREATE TABLE support_tickets (
    ticket_id                       VARCHAR(20)     PRIMARY KEY,
    account_id                      VARCHAR(20)     NOT NULL,
    submitted_at                    TIMESTAMP       NOT NULL,
    closed_at                       TIMESTAMP,                  -- NULL if still open
    resolution_time_hours           DECIMAL(8,2),               -- Hours to resolve
    priority                        VARCHAR(20)     NOT NULL,   -- low, medium, high, urgent
    first_response_time_minutes     INTEGER,                    -- Minutes to first response
    satisfaction_score              INTEGER,                    -- 1-5 scale (NULL = no response, ~41% null)
    escalation_flag                 VARCHAR(10)     NOT NULL,   -- 'True' if escalated (~5%)

    CONSTRAINT fk_support_tickets_account
        FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);


-- TABLE 5: CHURN_EVENTS (600 rows)
-- Records why and when each churned account left.
-- Only populated for churned accounts (churn_flag = 'True').

CREATE TABLE churn_events (
    churn_event_id              VARCHAR(20)     PRIMARY KEY,
    account_id                  VARCHAR(20)     NOT NULL,
    churn_date                  DATE            NOT NULL,
    reason_code                 VARCHAR(50),                    -- pricing, support, features, budget, competitor, unknown
    refund_amount_usd           DECIMAL(10,2)   DEFAULT 0,     -- $0 default, ~25% have credit/refund
    preceding_upgrade_flag      VARCHAR(10)     NOT NULL,       -- Had upgrade within 90 days before churn
    preceding_downgrade_flag    VARCHAR(10)     NOT NULL,       -- Had downgrade within 90 days before churn
    is_reactivation             VARCHAR(10)     NOT NULL,       -- ~10% were previously churned and returned
    feedback_text               TEXT,                           -- Optional customer comment (~25% null)

    CONSTRAINT fk_churn_events_account
        FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);


-- ============================================================================
-- STEP 3: CREATE INDEXES FOR QUERY PERFORMANCE
-- These speed up the JOINs and WHERE clauses used in our 16 analysis queries.
-- ============================================================================

-- Indexes on foreign keys (used in every JOIN)
CREATE INDEX idx_subscriptions_account_id ON subscriptions(account_id);
CREATE INDEX idx_feature_usage_subscription_id ON feature_usage(subscription_id);
CREATE INDEX idx_support_tickets_account_id ON support_tickets(account_id);
CREATE INDEX idx_churn_events_account_id ON churn_events(account_id);

-- Indexes on commonly filtered columns
CREATE INDEX idx_accounts_churn_flag ON accounts(churn_flag);
CREATE INDEX idx_accounts_plan_tier ON accounts(plan_tier);
CREATE INDEX idx_accounts_industry ON accounts(industry);
CREATE INDEX idx_subscriptions_churn_flag ON subscriptions(churn_flag);
CREATE INDEX idx_churn_events_reason_code ON churn_events(reason_code);
CREATE INDEX idx_feature_usage_date ON feature_usage(usage_date);
CREATE INDEX idx_support_tickets_priority ON support_tickets(priority);


-- ============================================================================
-- STEP 4: LOAD DATA FROM CSV FILES
-- Adjust file paths to match your local setup.
-- For PostgreSQL use COPY, for MySQL use LOAD DATA INFILE.
-- ============================================================================

-- PostgreSQL syntax:
-- COPY accounts FROM '/path/to/ravenstack_accounts.csv' DELIMITER ',' CSV HEADER;
-- COPY subscriptions FROM '/path/to/ravenstack_subscriptions.csv' DELIMITER ',' CSV HEADER;
-- COPY feature_usage FROM '/path/to/ravenstack_feature_usage.csv' DELIMITER ',' CSV HEADER;
-- COPY support_tickets FROM '/path/to/ravenstack_support_tickets.csv' DELIMITER ',' CSV HEADER;
-- COPY churn_events FROM '/path/to/ravenstack_churn_events.csv' DELIMITER ',' CSV HEADER;

-- MySQL syntax:
-- LOAD DATA INFILE '/path/to/ravenstack_accounts.csv' INTO TABLE accounts
--     FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;


-- ============================================================================
-- STEP 5: VERIFY DATA LOAD
-- Run these after importing to confirm row counts match expected values.
-- ============================================================================

SELECT 'accounts' AS table_name, COUNT(*) AS row_count FROM accounts
UNION ALL
SELECT 'subscriptions', COUNT(*) FROM subscriptions
UNION ALL
SELECT 'feature_usage', COUNT(*) FROM feature_usage
UNION ALL
SELECT 'support_tickets', COUNT(*) FROM support_tickets
UNION ALL
SELECT 'churn_events', COUNT(*) FROM churn_events;




-- ============================================================================
-- STEP 6: QUICK DATA QUALITY CHECKS
-- ============================================================================

-- Check: All foreign keys have valid parent records (no orphans)
SELECT 'orphan_subscriptions' AS check_name, COUNT(*) AS orphan_count
FROM subscriptions s
LEFT JOIN accounts a ON s.account_id = a.account_id
WHERE a.account_id IS NULL

UNION ALL

SELECT 'orphan_feature_usage', COUNT(*)
FROM feature_usage fu
LEFT JOIN subscriptions s ON fu.subscription_id = s.subscription_id
WHERE s.subscription_id IS NULL

UNION ALL

SELECT 'orphan_support_tickets', COUNT(*)
FROM support_tickets st
LEFT JOIN accounts a ON st.account_id = a.account_id
WHERE a.account_id IS NULL

UNION ALL

SELECT 'orphan_churn_events', COUNT(*)
FROM churn_events ce
LEFT JOIN accounts a ON ce.account_id = a.account_id
WHERE a.account_id IS NULL;

-- Expected: All orphan counts should be 0


-- Check: Churn flag consistency between accounts and churn_events
SELECT 
    'accounts_flagged_churned' AS check_name,
    COUNT(*) AS count
FROM accounts WHERE churn_flag = 'True'

UNION ALL

SELECT 
    'unique_accounts_in_churn_events',
    COUNT(DISTINCT account_id)
FROM churn_events;

-- Expected: Both numbers should be close (110 churned accounts, ~110+ churn events)


-- ============================================================================
-- SCHEMA CREATION COMPLETE
-- Next: Run 01_analysis_queries.sql for the 16 business analysis queries
-- ============================================================================