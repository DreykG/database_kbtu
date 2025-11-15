-- Create tables
CREATE TABLE departments (
 dept_id INT PRIMARY KEY,
 dept_name VARCHAR(50),
 location VARCHAR(50)
);
CREATE TABLE employees (
 emp_id INT PRIMARY KEY,
 emp_name VARCHAR(100),
 dept_id INT,
 salary DECIMAL(10,2),
 FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
CREATE TABLE projects (
 proj_id INT PRIMARY KEY,
 proj_name VARCHAR(100),
 budget DECIMAL(12,2),
 dept_id INT,
 FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

-- Insert sample data
INSERT INTO departments VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Operations', 'Building C');
INSERT INTO employees VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 101, 55000),
(3, 'Mike Johnson', 102, 48000),
(4, 'Sarah Williams', 102, 52000),
(5, 'Tom Brown', 103, 60000);
INSERT INTO projects VALUES
(201, 'Website Redesign', 75000, 101),
(202, 'Database Migration', 120000, 101),
(203, 'HR System Upgrade', 50000, 102),
(204, 'Database Migration', NULL,102);



--Part 2: Creating Basic Indexes
-- Exercise 2.1: Create a Simple B-tree Index
CREATE INDEX emp_salary_idx ON employees(salary);



-- List all indexes on employees table
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees';



--Exercise 2.2: Create an Index on a Foreign Key
CREATE INDEX emp_dept_idx ON employees(dept_id);
SELECT * FROM employees WHERE dept_id = 101;



--Exercise 2.3: View Index Information
SELECT
  tablename,
  indexname,
  indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;



-- Part 3: Multicolumn Indexes
-- Exercise 3.1: Create a Multicolumn Index
CREATE INDEX emp_dept_salary_idx ON employees(dept_id,salary);
-- This query can use the multicolumn index



--Exercise 3.2: Understanding Column Order
CREATE INDEX emp_salary_dept_idx ON employees(salary, dept_id);

-- Query 1: Filters by dept_id first
SELECT * FROM employees WHERE dept_id = 102 AND salary > 50000;

-- Query 2: Filters by salary first
SELECT * FROM employees WHERE salary > 50000 AND dept_id = 102;




--Part 4: Unique Indexes
-- Exercise 4.1: Create a Unique Index
ALTER TABLE employees ADD COLUMN email VARCHAR(100);
UPDATE employees SET email = 'john.smith@company.com' WHERE emp_id = 1;
UPDATE employees SET email = 'jane.doe@company.com' WHERE emp_id = 2;
UPDATE employees SET email = 'mike.johnson@company.com' WHERE emp_id = 3;
UPDATE employees SET email = 'sarah.williams@company.com' WHERE emp_id = 4;
UPDATE employees SET email = 'tom.brown@company.com' WHERE emp_id = 5;

CREATE UNIQUE INDEX emp_email_unique_idx ON employees(email);

-- This should fail with a unique violation error
-- INSERT INTO employees (emp_id, emp_name, dept_id, salary, email)
-- VALUES (6, 'New Employee', 101, 55000, 'john.smith@company.com');



--Exercise 4.2: Unique Index vs UNIQUE Constraint
-- Add a phone column with UNIQUE constraint
ALTER TABLE employees ADD COLUMN phone VARCHAR(20) UNIQUE;

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees' AND indexname LIKE '%phone%';



--Part 5: Indexes and Sorting
-- Exercise 5.1: Create an Index for Sorting
CREATE INDEX emp_salary_desc_idx ON employees(salary DESC);

SELECT emp_name, salary
FROM employees
ORDER BY salary DESC;



--Exercise 5.2: Index with NULL Handling
CREATE INDEX proj_budget_nulls_first_idx ON projects(budget NULLS FIRST);

--NULLS FIRST - указывает, что NULL значения будут идти первыми в индексе
SELECT proj_name, budget
FROM projects
ORDER BY budget NULLS FIRST;



--Part 6: Indexes on Expressions
-- Exercise 6.1: Create a Function-Based Index
CREATE INDEX emp_name_lower_idx ON employees(LOWER(emp_name));
--LOWER(emp_name) - функция, которая преобразует значение в нижний регистр
-- Функциональный индекс - индекс создается не на самом столбце, а на результате функции


-- This query can use the expression index
SELECT * FROM employees WHERE LOWER(emp_name) = 'john smith';



--Exercise 6.2: Index on Calculated Values
ALTER TABLE employees ADD COLUMN hire_date DATE;
UPDATE employees SET hire_date = '2020-01-15' WHERE emp_id = 1;
UPDATE employees SET hire_date = '2019-06-20' WHERE emp_id = 2;
UPDATE employees SET hire_date = '2021-03-10' WHERE emp_id = 3;
UPDATE employees SET hire_date = '2020-11-05' WHERE emp_id = 4;
UPDATE employees SET hire_date = '2018-08-25' WHERE emp_id = 5;

-- Create index on the year extracted from hire_date
CREATE INDEX emp_hire_year_idx ON employees(EXTRACT(YEAR FROM hire_date));
-- EXTRACT(YEAR FROM hire_date) - функция, извлекающая год из даты приема на работу
-- Функциональный индекс - индекс создается на результате функции (годе), а не на самой дате

SELECT emp_name, hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 2020;



--Part 7: Managing Indexes
-- Exercise 7.1: Rename an Index
ALTER INDEX emp_salary_idx RENAME TO employees_salary_index;

SELECT indexname FROM pg_indexes WHERE tablename = 'employees';



-- Exercise 7.2: Drop Unused Indexes
DROP INDEX emp_salary_dept_idx; --redundant multicolumn index



-- Exercise 7.3: Reindex
REINDEX INDEX employees_salary_index;
--REINDEX полностью перестраивает индекс с нуля.
-- Все данные сортируются заново
-- Старый индекс удаляется
-- Новый индекс становится активным
-- Восстанавливает поврежденные структуры индекса

-- After bulk INSERT operations
-- When index becomes bloated
-- After significant data modifications



--Part 8: Practical Scenarios
-- Exercise 8.1: Optimize a Slow Query
SELECT e.emp_name, e.salary, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 50000
ORDER BY e.salary DESC;

-- Index for the WHERE clause
CREATE INDEX emp_salary_filter_idx ON employees(salary) WHERE salary > 50000;



--Exercise 8.2: Partial Index
--Create an index only for high-budget projects (budget > 80000):
CREATE INDEX proj_high_budget_idx ON projects(budget) WHERE budget > 80000;

SELECT proj_name, budget
FROM projects
WHERE budget > 80000;



--Exercise 8.3: Analyze Index Usage
EXPLAIN SELECT * FROM employees WHERE salary > 52000;
-- EXPLAIN показывает КАК PostgreSQL будет выполнять ваш запрос, 
-- помогая понять использует ли он индексы и где возможны проблемы с производительностью.



--Part 9: Index Types Comparison
-- Exercise 9.1: Create a Hash Index
CREATE INDEX dept_name_hash_idx ON departments USING HASH (dept_name);

SELECT * FROM departments WHERE dept_name = 'IT';
-- Только для:   =
-- Очень быстрый для точного совпадения
-- ПЛохо работает с >, <, BETWEEN, сортировкой и поиску по шаблону



--Exercise 9.2: Compare Index Types
-- B-tree index
CREATE INDEX proj_name_btree_idx ON projects(proj_name);
--Тут по дефолту юзается Б-трии индекс. Он самый эффиктивный для операций: >,<,BETWEEN и тд.

-- Hash index
CREATE INDEX proj_name_hash_idx ON projects USING HASH (proj_name);

-- Equality search (both can be used)
SELECT * FROM projects WHERE proj_name = 'Website Redesign';

-- Range search (only B-tree can be used)
SELECT * FROM projects WHERE proj_name > 'Database';



--Part 10: Cleanup and Best Practices
-- Exercise 10.1: Review All Indexes

-- List all indexes and their sizes:
SELECT
  schemaname,
  tablename,
  indexname,
  pg_size_pretty(pg_relation_size(indexname::regclass)) as index_size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;



--Exercise 10.2: Drop Unnecessary Indexes
-- Drop the duplicate expression indexes
DROP INDEX IF EXISTS proj_name_hash_idx;
-- Keep only necessary indexes



-- Exercise 10.3: Document Your Indexes
-- Create a view that documents all custom indexes:
CREATE VIEW index_documentation AS
SELECT
  tablename,
  indexname,
  indexdef,
 'Improves salary-based queries' as purpose
FROM pg_indexes
WHERE schemaname = 'public' AND indexname LIKE '%salary%';

SELECT * FROM index_documentation;