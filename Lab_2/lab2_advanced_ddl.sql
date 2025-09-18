--Part 1: Multiple Database Management
-----------Task 1.1: Database Creation with Parameters-----------

--1) university_main
CREATE DATABASE IF NOT EXISTS university_main
    OWNER = CURRENT_USER  --Set up the owner of DB is current user
    TEMPLATE = template0    --use template "template0" for creating DB
    ENCODING = 'UTF8';      --Set encoding


--2) Creating database university_archive
CREATE DATABASE IF NOT EXISTS university_archive
    CONNECTION LIMIT = 50       --Sets the connection limit to 50
    TEMPLATE = template0;


--3) Creating database university_test
CREATE DATABASE IF NOT EXISTS university_test
    IS_TEMPLATE = true
    CONNECTION LIMIT = 10;



-----------Task 1.2: Tablespace Operations-----------

--1) Creating tablespace student_data
CREATE TABLESPACE IF NOT EXISTS student_data 
    LOCATION = '/data/students';


--2) Creating tablespace course_data with owner
CREATE TABLESPACE IF NOT EXISTS course_data 
    OWNER = CURRENT_USER
    LOCATION = '/data/courses';


--3) Creating DB university_distributed
CREATE DATABASE IF NOT EXISTS university_distributed
    TABLESPACE = student_data
    ENCODING = 'LATIN9';



--Part 2: Complex Table Creation
-----------Task 2.1: University Management System-----------

--Connecting to base university_main
\c university_main
CREATE TABLE IF NOT EXISTS students(
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone CHAR(15),         -- CHAR() is fixed size of string. Here should be exactly 15 symbols. Not more, not less.
    date_of_birth DATE,     --Stores the date in the YYYY-MM-DD (year-month-day) format. Does not include the time.
    enrollment_date DATE,
    gpa DECIMAL(3, 2),      --decimal number with 2 decimal places (for storing GPA). 3-total lenght of number / 2-lenght after decimal
    is_active BOOLEAN,
    graduation_year SMALLINT
);

CREATE TABLE IF NOT EXISTS professors(
    professor_id INT AUTO_INCREMENT PRIMARY KEY,
    frist_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    office_number VARCHAR(20),
    hire_date DATE,
    salary DECIMAL(9, 2),
    is_tenured BOOLEAN,
    years_experience INT
);

CREATE TABLE IF NOT EXISTS courses(
    courses_id INT AUTO_INCREMENT PRIMARY KEY,
    course_code VARCHAR(8),
    course_title VARCHAR(100),
    description TEXT,       --Unlimited text
    credits SMALLINT,
    max_enrollment INT,
    course_fee DECIMAL(5,2),
    is_online BOOLEAN,
    created_at TIMESTAMP WITHOUT TIME ZONE
);



-----------Task 2.2: Time-based and Specialized Tables-----------

CREATE TABLE IF NOT EXISTS class_schedule (
    schedule_id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT,
    professor_id INT,
    classroom VARCHAR(20),
    class_date DATE,
    start_time TIME WITHOUT TIME ZONE,
    end_time TIME WITHOUT TIME ZONE,
    duration INTERVAL
);


CREATE TABLE IF NOT EXISTS student_records (
    record_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    course_id INT,
    semester VARCHAR(20),
    year INT,
    grade CHAR(2),
    attendance_percentage DECIMAL(5, 1),
    submission_timestamp TIMESTAMP WITH TIME ZONE,
    last_updated TIMESTAMP WITH TIME ZONE,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)   
);



--Part 3: Advanced ALTER TABLE Operations
-----------Task 3.1: Modifying Existing Tables-----------

--Modify students table:
ALTER TABLE students
    ADD COLUMN middle_name VARCHAR(30),
    ADD COLUMN student_status VARCHAR(20),
    ALTER COLUMN phone SET DATA TYPE VARCHAR(20),       --SET DATA TYPE (TYPE) - changes the type of a column of a table.
    ALTER COLUMN student_status SET DEFAULT 'ACTIVE',   --(SET/DROP) DEFAULT (value) - These forms set or remove the default value for a column.
    ALTER COLUMN gpa SET DEFAULT 0.00;


--Modify professors table:
ALTER TABLE professors
    ADD COLUMN department_code CHAR(5),
    ADD COLUMN research_area TEXT,
    ALTER COLUMN years_experience SET DATA TYPE SMALLINT,
    ALTER COLUMN is_tenured SET DEFAULT false,
    ADD COLUMN last_promotion_date DATE;


--Modify courses table:
ALTER TABLE course
    ADD COLUMN prerequisite_course_id INT,
    ADD COLUMN difficulty_level SMALLINT,
    ALTER COLUMN course_code SET DATA TYPE VARCHAR(10)
    ALTER COLUMN credits SET DEFAULT 3,
    ADD COLUMN lab_required BOOLEAN DEFAULT false;



-----------Task 3.2: Column Management Operations-----------
--For class_schedule table:

ALTER TABLE class_schedule
    ADD COLUMN room_capacity INT,
    DROP COLUMN duration,                 --DROP COLUMN - drops a column from a table
    ADD COLUMN session_type VARCHAR(15),
    ALTER COLUMN classroom SET DATA TYPE VARCHAR(30),
    ADD COLUMN equipment_needed TEXT;


--For student_records table:
ALTER TABLE student_records
    ADD COLUMN extra_credit_points DECIMAL(3,1),
    ALTER COLUMN grade SET DATA TYPE VARCHAR(5),
    ALTER COLUMN extra_credit_points SET DEFAULT 0.00,
    ADD COLUMN final_exam_date DATE,
    DROP COLUMN last_updated;


--Part 4: Table Relationships and Management
-----------Task 4.1: Additional Supporting Tables-----------

--Table: departments
CREATE TABLE IF NOT EXISTS departments(
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100),
    department_code CHAR(5),
    building VARCHAR(50),
    phone VARCHAR(15),
    budget DECIMAL(15,2),
    established_year INT
);


--Table: library_books
CREATE TABLE IF NOT EXISTS library_books(
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    isbn CHAR(13),
    title VARCHAR (200),
    author VARCHAR(100),
    publisher VARCHAR(100),
    publication_date DATE,
    price DECIMAL(7,2),
    is_available BOOLEAN,
    acquisition_timestamp TIMESTAMP WITHOUT TIME ZONE
);

--Table: student_book_loans
CREATE TABLE IF NOT EXISTS student_book_loans(
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    book_id INT,
    loan_date DATE,
    due_date DATE,
    return_date DATE,
    fine_amount DECIMAL (5,2),
    loan_status VARCHAR(20),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (book_id) REFERENCES library_books(book_id) 
);


-----------Task 4.2: Table Modifications for Integration-----------

--1)Add	foreign	key	columns:

ALTER TABLE professors
    ADD COLUMN department_id INT;

ALTER TABLE students
    ADD COLUMN advisor_id INT;

ALTER TABLE courses
    ADD COLUMN department_id INT;

--2)Create lookup tables:

--Table: grade_scale

CREATE TABLE IF NOT EXISTS grade_scale(
    grade_id INT AUTO_INCREMENT PRIMARY KEY,
    letter_grade CHAR(2),
    min_percentage DECIMAL(5,1),
    max_percentage DECIMAL(5,1),
    gpa_points DECIMAL(3,2)
);

--Table: semester_calendar

CREATE TABLE IF NOT EXISTS semester_calendar(
    semester_id INT AUTO_INCREMENT PRIMARY KEY,
    semester_name VARCHAR(20),
    academic_year INT,
    start_date DATE,
    end_date DATE,
    registration_deadline TIMESTAMP WITH TIME ZONE,
    is_current BOOLEAN
);

--Part 5: Table Deletion and Cleanup
-----------Task 5.1: Conditional Table Operations-----------

--1)Drop tables if they exist:
DROP TABLE IF EXISTS student_book_loans;
DROP TABLE IF EXISTS library_books;
DROP TABLE IF EXISTS grade_scale;

--2)Recreate one of the dropped tables with modified structure:
CREATE TABLE IF NOT EXISTS grade_scale(
    grade_id INT AUTO_INCREMENT PRIMARY KEY,
    letter_grade CHAR(2),
    description TEXT,
    min_percentage DECIMAL(5,1),
    max_percentage DECIMAL(5,1),
    gpa_points DECIMAL(3,2)
);

--3)Drop and recreat table "semester_calendar" with CASCADE
DROP TABLE IF EXISTS semester_calendar CASCADE;     --CASCADE: If the semester_calendar table has foreign keys, 
                                                    --then deleting it will also delete all 
                                                    --dependent objects (for example, related records in other tables).

CREATE TABLE IF NOT EXISTS semester_calendar(
    semester_id INT AUTO_INCREMENT PRIMARY KEY,
    semester_name VARCHAR(20),
    academic_year INT,
    start_date DATE,
    end_date DATE,
    registration_deadline TIMESTAMP WITH TIME ZONE,
    is_current BOOLEAN
);

-----------Task 5.2: Database Cleanup-----------
--1)Database operations:
DROP DATABASE IF EXISTS university_test;
DROP DATABASE IF EXISTS university_distributed;

CREATE DATABASE university_backup
    WITH TEMPLATE =  university_main;