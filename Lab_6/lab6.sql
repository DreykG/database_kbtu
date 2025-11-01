--Part 1: Database Setup
--Step 1.1: Create Sample Tables
-- Create table: employees
CREATE TABLE employees (
 emp_id INT PRIMARY KEY,
 emp_name VARCHAR(50),
 dept_id INT,
 salary DECIMAL(10, 2)
);
-- Create table: departments
CREATE TABLE departments (
 dept_id INT PRIMARY KEY,
 dept_name VARCHAR(50),
 location VARCHAR(50)
);
-- Create table: projects
CREATE TABLE projects (
 project_id INT PRIMARY KEY,
 project_name VARCHAR(50),
 dept_id INT,
 budget DECIMAL(10, 2)
);
--Step 1.2: Insert Sample Data
-- Insert data into employees
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 102, 60000),
(3, 'Mike Johnson', 101, 55000),
(4, 'Sarah Williams', 103, 65000),
(5, 'Tom Brown', NULL, 45000);
-- Insert data into departments
INSERT INTO departments (dept_id, dept_name, location) VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Finance', 'Building C'),
(104, 'Marketing', 'Building D');
-- Insert data into projects
INSERT INTO projects (project_id, project_name, dept_id,
budget) VALUES
(1, 'Website Redesign', 101, 100000),
(2, 'Employee Training', 102, 50000),
(3, 'Budget Analysis', 103, 75000),
(4, 'Cloud Migration', 101, 150000),
(5, 'AI Research', NULL, 200000);



-- Part 2: CROSS JOIN Exercises
-- Exercise 2.1: Basic CROSS JOIN
-- SELECT e.emp_name, d.dept_name
-- FROM employees e CROSS JOIN departments d;

-- CROSS JOIN (перекрёстное соединение) - это операция в SQL,
-- которая создаёт декартово произведение двух таблиц.


-- Exercise 2.2: Alternative CROSS JOIN Syntax
-- SELECT e.emp_name, d.dept_name
-- FROM employees e, departments d;

-- SELECT e.emp_name, d.dept_name
-- FROM employees e 
-- INNER JOIN departments d ON TRUE;

-- INNER JOIN (внутреннее соединение) - это операция в SQL, 
-- которая возвращает только те строки, для которых выполняется условие соединения в обеих таблицах.


--Exercise 2.3: Practical CROSS JOIN
-- SELECT e.emp_name, p.project_name
-- FROM employees e 
-- CROSS JOIN projects p;


-- Part 3: INNER JOIN Exercises
-- Exercise 3.1: Basic INNER JOIN with ON
-- SELECT e.emp_name, d.dept_name, d.location
-- FROM employees e
-- INNER JOIN departments d ON e.dept_id = d.dept_id;

--Exercise 3.2: INNER JOIN with USING
-- SELECT emp_name, dept_name, location
-- FROM employees
-- INNER JOIN departments USING (dept_id);

--USING говорит SQL:
--"Соедини эти две таблицы по колонке с ОДИНАКОВЫМ ИМЕНЕМ, 
--и в результате покажи эту колонку ТОЛЬКО ОДИН РАЗ"

--Exercise 3.3: NATURAL INNER JOIN
-- SELECT emp_name, dept_name, location
-- FROM employees
-- NATURAL INNER JOIN departments;


--Exercise 3.4: Multi-table INNER JOIN
-- SELECT e.emp_name, d.dept_name, p.project_name
-- FROm employees e
-- INNER JOIN departments d ON e.dept_id = d.dept_id
-- INNER JOIN projects p ON d.dept_id = p.dept_id;



--Part 4: LEFT JOIN Exercises
--Exercise 4.1: Basic LEFT JOIN
-- SELECT e.emp_name, e.dept_id as emp_dept, d.dept_id as dept_dept, d.dept_id
-- FROM employees e
-- LEFT JOIN departments d ON e.dept_id = d.dept_id;


-- Exercise 4.2: LEFT JOIN with USING
-- SELECT emp_name, dept_id as emp_dept, dept_id as dept_dept, dept_id
-- FROM employees
-- LEFT JOIN departments USING(dept_id);


--Exercise 4.3: Find Unmatched Records
-- SELECT e.emp_name, e.dept_id
-- FROM employees e
-- LEFT JOIN departments d ON e.dept_id = d.dept_id
-- WHERE d.dept_id IS NULL;


--Exercise 4.4: LEFT JOIN with Aggregation
-- SELECT d.dept_name, COUNT(e.emp_id) as employee_count
-- FROM departments d
-- LEFT JOIN employees e ON d.dept_id = e.dept_id
-- GROUP BY d.dept_id, d.dept_name
-- ORDER BY employee_count DESC;


--Part 5: RIGHT JOIN Exercises
--Exercise 5.1: Basic RIGHT JOIN
-- SELECT e.emp_name, d.dept_name
-- FROM employees e 
-- RIGHT JOIN departments d ON e.dept_id = d.dept_id;


-- Exercise 5.2: Convert to LEFT JOIN
-- SELECT e.emp_name, d.dept_name
-- FROM departments d 
-- LEFT JOIN employees e ON d.dept_id = e.dept_id;


--Exercise 5.3: Find Departments Without Employees
-- SELECT d.dept_name, e.emp_name
-- FROM employees e 
-- RIGHT JOIN departments d ON d.dept_id = e.dept_id
-- WHERE e.emp_id is NULL;


-- Part 6: FULL JOIN Exercises
--Exercise 6.1: Basic FULL JOIN
-- SELECT e.emp_name, e.dept_id as emp_dept, d.dept_id, d.dept_name
-- FROM employees e
-- FULL JOIN departments d ON e.dept_id = d.dept_id;


--Exercise 6.2: FULL JOIN with Projects
-- SELECT d.dept_name,p.project_name, p.budget
-- FROM departments d
-- FULL JOIN projects p ON p.dept_id = d.dept_id;

-- Exercise 6.3: Find Orphaned Records
-- SELECT 
--   CASE 
--     WHEN e.emp_id IS NULL THEN 'Department without employees'
--     WHEN d.dept_id IS NULL THEN 'Employee without department'
--     ELSE 'Matched'
--   END as record_status,
--   e.emp_name,
--   d.dept_name
-- FROM employees e 
-- FULL JOIN departments d ON e.dept_id = d.dept_id
-- WHERE d.dept_id IS NULL OR e.dept_id IS NULL;

--Part 7: ON vs WHERE Clause
-- SELECT e.emp_name, d.dept_name, e.salary
-- FROM employees e
-- LEFT JOIN departments d ON e.dept_id = d.dept_id AND
-- d.location = 'Building A';
-- Фильтр в ON clause при LEFT JOIN позволяет сохранить всех сотрудников, 
-- но показывать информацию об отделах только для отделов из Building A


--Exercise 7.2: Filtering in WHERE Clause (Outer Join)
-- SELECT e.emp_name, d.dept_name, e.salary
-- FROM employees e
-- LEFT JOIN departments d ON e.dept_id = d.dept_id
-- WHERE d.location = 'Building A';
--фильтр WHERE обрезает то, где нет совпадений и выводит только то где есть

-- Exercise 7.3: ON vs WHERE with INNER JOIN
-- SELECT e.emp_name, d.dept_name, e.salary
-- FROM employees e
-- INNER JOIN departments d ON e.dept_id = d.dept_id AND
-- d.location = 'Building A';

-- SELECT e.emp_name, d.dept_name, e.salary
-- FROM employees e
-- INNER JOIN departments d ON e.dept_id = d.dept_id
-- WHERE d.location = 'Building A';
--Inner сохранил только совпадающие строки.


-- Part 8: Complex JOIN Scenarios
-- Exercise 8.1: Multiple Joins with Different Types
-- SELECT
--   d.dept_name,
--   e.emp_name,
--   e.salary
--   -- p.project_name,
--   -- p.budget
-- FROM departments d
-- LEFT JOIN employees e ON d.dept_id = e.dept_id;

-- SELECT
--   d.dept_name,
--   e.emp_name,
--   e.salary,
--   p.project_name,
--   p.budget
-- FROM departments d
-- LEFT JOIN employees e ON d.dept_id = e.dept_id
-- LEFT JOIN projects p ON d.dept_id = p.dept_id
-- ORDER BY d.dept_name, e.emp_name;


--Exercise 8.2: Self Join
-- ALTER TABLE employees
--   ADD COLUMN manager_id INT;
  
-- UPDATE employees SET manager_id = 3 WHERE emp_id = 1;
-- UPDATE employees SET manager_id = 3 WHERE emp_id = 2;
-- UPDATE employees SET manager_id = NULL WHERE emp_id = 3;
-- UPDATE employees SET manager_id = 3 WHERE emp_id = 4;
-- UPDATE employees SET manager_id = 3 WHERE emp_id = 5;

-- SELECT e.emp_name as employee, m.emp_name as manager
-- FROM employees e
-- LEFT JOIN employees m ON e.manager_id = m.emp_id;


-- Exercise 8.3: Join with Subquery
--Find departments where the average employee salary is above $50,000.
-- SELECT d.dept_name, AVG(e.salary) AS avg_salary
-- FROM departments d
-- INNER JOIN employees e ON d.dept_id = e.dept_id
-- GROUP BY d.dept_id, d.dept_name
-- HAVING AVG(e.salary) > 50000;


--Lab Questions
-- 1. INNER JOIN vs LEFT JOIN
-- INNER JOIN: Only rows that match in both tables
-- LEFT JOIN: All rows from left table + matches from right (shows NULL for non-matches)
-- Example: INNER shows only employees with departments, LEFT shows all employees even without departments

-- 2. CROSS JOIN practical use
-- Create all possible combinations
-- Examples:
-- Products: all sizes × all colors
-- Scheduling: all employees × all time slots
-- Menu: all main dishes × all sides

-- 3. ON vs WHERE in joins
-- INNER JOIN: ON and WHERE work the same
-- OUTER JOIN:
-- ON = filter during joining (keeps all left rows)
-- WHERE = filter after joining (removes non-matches)
-- Example: LEFT JOIN with WHERE can remove rows you wanted to keep

-- 4. CROSS JOIN count
-- 5 rows × 10 rows = 50 rows total
-- Every row from table1 pairs with every row from table2

-- 5. NATURAL JOIN columns
-- Automatically joins on columns with identical names in both tables
-- If both have "id" and "name" columns, joins on both

-- 6. NATURAL JOIN risks
-- Unexpected joins on hidden columns
-- Breaks easily if someone adds same-named column
-- Hard to read - can't tell what columns are joined

--7. LEFT to RIGHT JOIN conversion
-- Original:
-- FROM A LEFT JOIN B ON A.id = B.id
-- Converted:
-- FROM B RIGHT JOIN A ON B.id = A.id

-- Same result: all from A + matches from B

-- 8. FULL OUTER JOIN use
-- When you need everything from both tables
-- Find missing relationships both ways
-- Example: Compare two customer lists to see who's in A only, B only, or both




--Additional Challenges (Optional)
-- 1. Simulate FULL OUTER JOIN using UNION

-- SELECT A.*, B.*
-- FROM A LEFT JOIN B ON A.id = B.id
-- UNION
-- SELECT A.*, B.*
-- FROM A RIGHT JOIN B ON A.id = B.id;

-- 1) LEFT JOIN gets all A + matches from B
-- 2) RIGHT JOIN gets all B + matches from A
-- 3) UNION combines both (removes duplicates)



-- 2. Employees in departments with multiple projects

-- SELECT e.emp_name, d.dept_name
-- FROM employees e
-- JOIN departments d ON e.dept_id = d.dept_id
-- WHERE d.dept_id IN (
--  SELECT dept_id 
--  FROM projects 
--  GROUP BY dept_id 
--  HAVING COUNT(*) > 1
-- );

-- * Subquery finds departments with >1 project
-- * Main query gets employees from those departments



-- 3. Organizational hierarchy with self-joins

-- SELECT
--   e1.emp_name AS Employee, 
--   e2.emp_name AS Manager,
--   e3.emp_name AS 'Manager\'s Manager'
-- FROM employees e1
-- LEFT JOIN employees e2 ON e1.manager_id = e2.emp_id
-- LEFT JOIN employees e3 ON e2.manager_id = e3.emp_id;

-- * First self-join: employee → manager
-- * Second self-join: manager → manager's manager
-- * LEFT JOIN keeps employees without managers



--4. Employee pairs in same department

-- SELECT
--   e1.emp_name AS Employee1, 
--   e2.emp_name AS Employee2,
--   d.dept_name
-- FROM employees e1
-- JOIN employees e2 ON e1.dept_id = e2.dept_id AND e1.emp_id < e2.emp_id
-- JOIN departments d ON e1.dept_id = d.dept_id;

-- * e1.emp_id < e2.emp_id prevents duplicates (A-B vs B-A)
-- * Same dept_id ensures they're in same department
-- * Shows each pair only once






































