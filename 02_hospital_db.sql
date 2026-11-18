-- ============================================================
-- Database : hospital_db
-- Topics   : PRIMARY KEY, AUTO_INCREMENT, NOT NULL, UNIQUE,
--            DEFAULT, CHECK, FOREIGN KEY, constraint testing
-- Tested on: MariaDB (MySQL-compatible)
-- ============================================================

CREATE DATABASE IF NOT EXISTS hospital_db;
USE hospital_db;

CREATE TABLE departments (
    department_id   INT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE
);

INSERT INTO departments VALUES
    (1, 'Cardiology'),
    (2, 'Dermatology'),
    (3, 'Pediatrics'),
    (4, 'Orthopedics');

SELECT * FROM departments;

CREATE TABLE patient_registration (
    patient_id            INT PRIMARY KEY AUTO_INCREMENT,
    patient_name          VARCHAR(100) NOT NULL,
    email                 VARCHAR(100) UNIQUE,
    phone_no              VARCHAR(20)  NOT NULL UNIQUE,
    date_of_birth         DATE         NOT NULL,
    registration_date     DATETIME     DEFAULT CURRENT_TIMESTAMP,
    appointment_time      TIME,
    registration_datetime DATETIME     DEFAULT CURRENT_TIMESTAMP,
    gender                VARCHAR(10)  NOT NULL,
    age                   INT CHECK (age >= 0),
    consultation_fee      DECIMAL(8,2) DEFAULT 500.00,
    department_id         INT,
    CONSTRAINT chk_gender CHECK (gender IN ('Male', 'Female', 'Others')),
    CONSTRAINT fk_patient_department
        FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- All sample data below is fictional.
INSERT INTO patient_registration
    (patient_name, email, phone_no, date_of_birth, appointment_time,
     gender, age, consultation_fee, department_id)
VALUES
    ('Rahul Menon', 'rahul.menon@example.com', '9876543210', '1995-04-12', '10:30:00', 'Male',   31, 500.00, 1),
    ('Anjali Nair', 'anjali.nair@example.com', '9876501234', '1990-08-25', '11:00:00', 'Female', 36, 600.00, 2),
    ('Arun Kumar',  'arun.kumar@example.com',  '9847012345', '1982-01-17', '14:15:00', 'Male',   44, 500.00, 3),
    ('Meera Das',   'meera.das@example.com',   '9988776655', '1998-06-30', '09:45:00', 'Female', 28, 450.00, 4);

SELECT * FROM patient_registration;

-- A valid insert that relies on DEFAULT values
-- (consultation_fee defaults to 500.00; optional columns stay NULL)
INSERT INTO patient_registration
    (patient_name, phone_no, date_of_birth, gender, age)
VALUES
    ('Test Patient', '9000000231', '2000-01-01', 'Male', NULL);

SELECT patient_name, consultation_fee
FROM patient_registration
WHERE phone_no = '9000000231';

-- ------------------------------------------------------------
-- Constraint tests: each statement below is EXPECTED TO FAIL.
-- Uncomment one at a time to see the error.
-- ------------------------------------------------------------

-- CHECK constraint on gender (ERROR 4025)
-- INSERT INTO patient_registration (patient_name, phone_no, date_of_birth, gender)
-- VALUES ('Invalid Gender', '9000000002', '2000-01-01', 'Unknown');

-- CHECK constraint on age (ERROR 4025)
-- INSERT INTO patient_registration (patient_name, phone_no, date_of_birth, gender, age)
-- VALUES ('Negative Age', '9000000003', '2000-01-01', 'Male', -1);

-- PRIMARY KEY duplicate (ERROR 1062)
-- INSERT INTO patient_registration (patient_id, patient_name, phone_no, date_of_birth, gender)
-- VALUES (1, 'Duplicate Id', '9000000004', '2000-01-01', 'Male');

-- UNIQUE phone number duplicate (ERROR 1062)
-- INSERT INTO patient_registration (patient_name, phone_no, date_of_birth, gender)
-- VALUES ('Duplicate Phone', '9988776655', '2000-01-01', 'Male');

-- NOT NULL: patient_name is required (ERROR 1364)
-- INSERT INTO patient_registration (email) VALUES ('someone@example.com');

-- FOREIGN KEY: department 25 does not exist (ERROR 1452)
-- INSERT INTO patient_registration
--     (patient_name, phone_no, date_of_birth, gender, department_id)
-- VALUES ('Bad Department', '9000000005', '2000-01-01', 'Male', 25);

DESC patient_registration;
