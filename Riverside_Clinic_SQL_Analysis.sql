-- ========================================================================
-- Riverside Primary Care Clinic
-- Patient and Billing Analysis
-- Analyst: Chibuzor Rosemary John
-- Tool: MySQL Workbench
-- Date: April  2026
-- Program 3MTT NextGen Fellow
-- GitHub: github.com/Chibuzor-Rosemary
-- ========================================================================
-- Purpose: Analyze patient attendance patterns and biling performance to identify areas 
-- for clinical and financial improvement

USE clinic_db;

-- ========================================================================
-- PATENT ATTENDANCE ANALYSIS
-- ========================================================================

-- Query 1: Overall no-show rate
-- Calculates total patients, no-shows and no-show rate as a percentage

SELECT 
COUNT(*) AS total_patients,
SUM(CASE WHEN showed_up = 'No' THEN 1 ELSE 0 END) AS total_noshows,
ROUND(SUM(CASE WHEN showed_up = 'No' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS noshowrate_percent
FROM patients;

-- Query 2: No-shows By Doctor
-- Identifies which provider has more no-shows

SELECT doctor,
COUNT(*) AS total_patients,
SUM(CASE WHEN showed_up = 'No' THEN 1 ELSE 0 END) AS noshows
FROM patients
GROUP BY doctor
ORDER BY noshows DESC;

-- Query 3: Wait time analysis by doctor
-- Compares average and maximum wait times per provider to identify scheduling issues

SELECT doctor,
ROUND(AVG(wait_time), 1) AS avg_wait_minutes,
MAX(wait_time) AS longest_wait
FROM patients
GROUP BY doctor
ORDER BY avg_wait_minutes DESC;

-- ==================================================================================
-- BILLING AND REVENUE ANALYSIS
-- ==================================================================================

-- Query 4: Overall revenue summary
-- Total billed, collected, outstanding and collection rate for the clinic

SELECT
SUM(bill_amount) AS total_billed,
SUM(amount_paid) AS total_collected,
SUM(bill_amount - amount_paid) AS total_outstanding,
ROUND(SUM(amount_paid) * 100.0 / SUM(bill_amount), 1) AS collection_rate_percent
FROM billing;

-- Query 5: Revenue by insurance type
-- Breakdown performance by Medicaid, Medicare and Private
 
SELECT insurance,
SUM(bill_amount) AS total_billed,
SUM(amount_paid) AS total_colllected,
SUM(bill_amount - amount_paid) AS outstanding,
ROUND(SUM(amount_paid) * 100.0 / SUM(bill_amount), 1) AS collection_rate_percent
FROM billing
GROUP BY insurance
ORDER BY outstanding DESC;

--  Query 6: Medicaid folllow up flags
-- Identifies Medicaid patients with outstanding balances for urgent follow up

SELECT patients.patient_name,
patients.doctor,
billing.bill_amount,
billing.amount_paid,
billing.bill_amount - billing.amount_paid AS outstanding,
CASE WHEN billing.bill_amount - billing.amount_paid > 0 
THEN 'Urgent Follow Up'
ELSE 'cleared'
END AS action_required 
FROM patients
JOIN billing ON patients.patient_id = billing.patient_id
WHERE billing.insurance = 'Medicaid'
ORDER BY outstanding DESC;

-- ==================================================================================
-- COMBINED PROVIDER ANALYSIS
-- ==================================================================================
-- Query 7: No show billing impact
-- Shows revenue at risk from no show patients

SELECT patients.patient_name,
patients.doctor,
patients.insurance,
billing.bill_amount AS lost_revenue,
billing.bill_amount - billing.amount_paid AS outstanding
FROM patients
JOIN billing ON patients.patient_id = billing.patient_id
WHERE patients.showed_up = 'No'
ORDER BY billing.bill_amount DESC;

-- Query 8: Complete provider performance
-- Master query Combining attendance, wait times and billing by doctor

SELECT patients.doctor,
COUNT(*) AS total_patients,
SUM(CASE WHEN patients.showed_up = 'No' THEN 1 ELSE 0 END) AS noshows,
ROUND(AVG(Patients.wait_time), 1) AS avg_wait,
SUM(billing.bill_amount) AS total_billed,
SUM(billing.amount_paid) AS total_collected,
SUM(billing.bill_amount - billing.amount_paid) AS outstanding
FROM patients
JOIN billing ON patients.patient_id = billing.patient_id
GROUP BY patients.doctor
ORDER BY noshows DESC;


