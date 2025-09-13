# Clinic Booking / Patient Management Database

## 📌 Project Description
This project is a relational database schema for a **Clinic Booking System**.  
It is designed to manage patients, doctors, departments, appointments, prescriptions, and payments in a clinic.

The database demonstrates:
- **One-to-Many relationships** (e.g., one patient can have many appointments).
- **Many-to-Many relationships** (e.g., doctors can have multiple specialties).
- Proper use of **Primary Keys, Foreign Keys, NOT NULL, and UNIQUE constraints**.

---

## 📂 Files in this Repository
- `clinic_final_project.sql` → Contains all `CREATE DATABASE` and `CREATE TABLE` statements.

---

## ⚡ How to Run
1. Open **MySQL Workbench** or **phpMyAdmin**.  
2. Run the following command:
   ```sql
   SOURCE clinic_final_project.sql;
