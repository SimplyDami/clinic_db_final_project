-- clinic_final_project.sql
-- Week 8 Final Project: Clinic Booking / Patient Management Database
-- Save this file and upload to your GitHub repository.
-- MySQL (InnoDB) compatible.

-- Drop database if exists (useful during development)
DROP DATABASE IF EXISTS clinic_db;
CREATE DATABASE clinic_db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE clinic_db;

-- -----------------------------------------------------
-- Table: departments
-- Clinic departments (e.g., Cardiology, Pediatrics)
-- -----------------------------------------------------
CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table: specialties
-- Doctor specialties (e.g., Dermatology, ENT)
-- -----------------------------------------------------
CREATE TABLE specialties (
    specialty_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT NULL
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table: doctors
-- Clinic doctors
-- -----------------------------------------------------
CREATE TABLE doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(60) NOT NULL,
    last_name VARCHAR(60) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(30) NULL,
    department_id INT NULL,
    hire_date DATE NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_doctor_department FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table: doctor_specialties (Many-to-Many)
-- A doctor can have multiple specialties and a specialty can belong to many doctors
-- -----------------------------------------------------
CREATE TABLE doctor_specialties (
    doctor_id INT NOT NULL,
    specialty_id INT NOT NULL,
    PRIMARY KEY (doctor_id, specialty_id),
    CONSTRAINT fk_ds_doctor FOREIGN KEY (doctor_id)
        REFERENCES doctors(doctor_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_ds_specialty FOREIGN KEY (specialty_id)
        REFERENCES specialties(specialty_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table: patients
-- -----------------------------------------------------
CREATE TABLE patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(60) NOT NULL,
    last_name VARCHAR(60) NOT NULL,
    date_of_birth DATE NULL,
    gender ENUM('Male','Female','Other') NULL,
    email VARCHAR(150) NULL,
    phone VARCHAR(30) NULL,
    address TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_patient_email (email)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table: appointments
-- Appointment links patient to doctor (Many appointments to one patient/doctor)
-- -----------------------------------------------------
CREATE TABLE appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_datetime DATETIME NOT NULL,
    duration_minutes SMALLINT NOT NULL DEFAULT 30,
    status ENUM('Scheduled','Completed','Cancelled','No-Show') NOT NULL DEFAULT 'Scheduled',
    reason TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_appointment_patient FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_appointment_doctor FOREIGN KEY (doctor_id)
        REFERENCES doctors(doctor_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Indexes to make searching appointments efficient
CREATE INDEX idx_appointments_patient ON appointments(patient_id);
CREATE INDEX idx_appointments_doctor ON appointments(doctor_id);
CREATE INDEX idx_appointments_datetime ON appointments(appointment_datetime);

-- -----------------------------------------------------
-- Table: treatments
-- Types of treatments/procedures the clinic provides
-- -----------------------------------------------------
CREATE TABLE treatments (
    treatment_id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(30) NOT NULL UNIQUE, -- e.g., "TREAT-001"
    name VARCHAR(120) NOT NULL,
    description TEXT NULL,
    price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    duration_minutes SMALLINT NULL
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table: prescriptions
-- A prescription created during an appointment
-- -----------------------------------------------------
CREATE TABLE prescriptions (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL,
    notes TEXT NULL,
    issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_prescription_appointment FOREIGN KEY (appointment_id)
        REFERENCES appointments(appointment_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table: medications
-- Catalog of medicines
-- -----------------------------------------------------
CREATE TABLE medications (
    medication_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    brand VARCHAR(120) NULL,
    form VARCHAR(50) NULL, -- e.g., tablet, syrup
    strength VARCHAR(50) NULL, -- e.g., 500mg
    UNIQUE KEY uq_medication_name_brand (name, brand)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table: prescription_items
-- Items within a prescription (Many-to-Many between prescriptions and medications with dosage details)
-- -----------------------------------------------------
CREATE TABLE prescription_items (
    prescription_id INT NOT NULL,
    medication_id INT NOT NULL,
    dosage VARCHAR(100) NULL, -- e.g., "1 tablet twice daily"
    duration_days INT NULL,
    instructions TEXT NULL,
    PRIMARY KEY (prescription_id, medication_id),
    CONSTRAINT fk_pi_prescription FOREIGN KEY (prescription_id)
        REFERENCES prescriptions(prescription_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_pi_medication FOREIGN KEY (medication_id)
        REFERENCES medications(medication_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table: appointment_treatments
-- Link treatments done during an appointment (Many-to-Many)
-- -----------------------------------------------------
CREATE TABLE appointment_treatments (
    appointment_id INT NOT NULL,
    treatment_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    price_at_time DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    PRIMARY KEY (appointment_id, treatment_id),
    CONSTRAINT fk_at_appointment FOREIGN KEY (appointment_id)
        REFERENCES appointments(appointment_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_at_treatment FOREIGN KEY (treatment_id)
        REFERENCES treatments(treatment_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table: payments
-- Payments for appointments / treatments
-- -----------------------------------------------------
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    method ENUM('Cash','Card','Mobile Money','Insurance') NOT NULL,
    paid_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reference VARCHAR(150) NULL,
    CONSTRAINT fk_payment_appointment FOREIGN KEY (appointment_id)
        REFERENCES appointments(appointment_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Optional: users (for clinic staff login if needed)
-- -----------------------------------------------------
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(80) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL, -- store a salted hash, not plain text
    full_name VARCHAR(150) NULL,
    role ENUM('Admin','Doctor','Reception','Pharmacist') NOT NULL DEFAULT 'Reception',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Example constraints & data integrity notes:
-- - Emails for doctors are UNIQUE.
-- - doctor_specialties is a many-to-many join table.
-- - appointment -> patient (cascade delete) so patient's appointments removed when patient removed.
-- - appointment -> doctor (restrict delete) so you cannot delete a doctor with scheduled appointments.
-- -----------------------------------------------------

-- -----------------------------------------------------
-- (Optional) Example seed data (commented-out)
-- Uncomment to insert small sample data during testing
-- -----------------------------------------------------
/*
INSERT INTO departments (name, description) VALUES
('General Medicine','General outpatient services'),
('Pediatrics','Child healthcare');

INSERT INTO specialties (name, description) VALUES
('General Practice','Primary care'),
('Pediatrics','Child specialist');

INSERT INTO doctors (first_name, last_name, email, phone, department_id) VALUES
('Amina','Mohammed','amina.mohammed@example.com','+2347012345678', 1),
('Chinedu','Okeke','chinedu.okeke@example.com','+2348012345678', 2);

INSERT INTO doctor_specialties (doctor_id, specialty_id) VALUES
(1,1),
(2,2);

INSERT INTO patients (first_name,last_name,date_of_birth,gender,email,phone) VALUES
('Damilola','Adebisi','2000-05-14','Female','dami@example.com','07043921320');

INSERT INTO appointments (patient_id,doctor_id,appointment_datetime,reason) VALUES
(1,1,'2025-09-20 10:00:00','Regular check-up');

INSERT INTO treatments (code, name, price) VALUES
('T001','General Consultation',1500.00),
('T002','Blood Test',2500.00);
*/
