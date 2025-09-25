USE vbc_project;

DROP TABLE IF EXISTS hospital_readmissions;

CREATE TABLE hospital_readmissions (
    age VARCHAR(20),
    time_in_hospital INT,
    n_lab_procedures INT,
    n_procedures INT,
    n_medications INT,
    n_outpatient INT,
    n_inpatient INT,
    n_emergency INT,
    medical_specialty VARCHAR(100),
    diag_1 VARCHAR(50),
    diag_2 VARCHAR(50),
    diag_3 VARCHAR(50),
    glucose_test VARCHAR(20),
    A1Ctest VARCHAR(20),
    `change` VARCHAR(10),
    diabetes_med VARCHAR(10),
    readmitted VARCHAR(10)
);

# Load CSV into MySQL (use LOCAL if secure-file-priv blocks normal infile)
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 9.4/Uploads/Hospital_Readmissions - hospital_readmissions.csv'
INTO TABLE hospital_readmissions
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

# --- Data Cleaning ---
SET SQL_SAFE_UPDATES = 0;
UPDATE hospital_readmissions
SET readmitted = LOWER(TRIM(readmitted));
SET SQL_SAFE_UPDATES = 1;

# --- KPIs ---
# 1. Total records
SELECT COUNT(*) AS total_records FROM hospital_readmissions;

# 2. Overall readmission rate
SELECT ROUND(AVG(CASE WHEN readmitted = 'yes' THEN 1 ELSE 0 END) * 100, 2) AS readmission_rate_percent
FROM hospital_readmissions;

# 3. Readmission rate by age group
SELECT age, ROUND(AVG(CASE WHEN readmitted = 'yes' THEN 1 ELSE 0 END) * 100, 2) AS readmission_rate_percent
FROM hospital_readmissions
GROUP BY age
ORDER BY readmission_rate_percent DESC;

# 4. Readmission rate by medical specialty
SELECT medical_specialty, ROUND(AVG(CASE WHEN readmitted = 'yes' THEN 1 ELSE 0 END) * 100, 2) AS readmission_rate_percent
FROM hospital_readmissions
GROUP BY medical_specialty
ORDER BY readmission_rate_percent DESC
LIMIT 10;

# 5. Average length of stay for readmitted vs non-readmitted
SELECT readmitted, ROUND(AVG(time_in_hospital), 2) AS avg_days
FROM hospital_readmissions
GROUP BY readmitted;

# 6. Avg meds prescribed for readmitted vs non-readmitted
SELECT readmitted, ROUND(AVG(n_medications), 2) AS avg_meds
FROM hospital_readmissions
GROUP BY readmitted;
