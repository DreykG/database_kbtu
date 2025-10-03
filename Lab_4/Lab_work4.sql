-- Create tables
CREATE TABLE employees (
 employee_id SERIAL PRIMARY KEY,
 first_name VARCHAR(50),
 last_name VARCHAR(50),
 department VARCHAR(50),
 salary NUMERIC(10,2),
 hire_date DATE,
 manager_id INTEGER,
 email VARCHAR(100)
);
CREATE TABLE projects (
 project_id SERIAL PRIMARY KEY,
 project_name VARCHAR(100),
 budget NUMERIC(12,2),
 start_date DATE,
 end_date DATE,
 status VARCHAR(20)
);

CREATE TABLE assignments (
 assignment_id SERIAL PRIMARY KEY,
 employee_id INTEGER REFERENCES employees(employee_id),
 project_id INTEGER REFERENCES projects(project_id),
 hours_worked NUMERIC(5,1),
 assignment_date DATE
);
-- Insert sample data
INSERT INTO employees (first_name, last_name, department,
salary, hire_date, manager_id, email) VALUES
('John', 'Smith', 'IT', 75000, '2020-01-15', NULL,
'john.smith@company.com'),
('Sarah', 'Johnson', 'IT', 65000, '2020-03-20', 1,
'sarah.j@company.com'),
('Michael', 'Brown', 'Sales', 55000, '2019-06-10', NULL,
'mbrown@company.com'),
('Emily', 'Davis', 'HR', 60000, '2021-02-01', NULL,
'emily.davis@company.com'),
('Robert', 'Wilson', 'IT', 70000, '2020-08-15', 1, NULL),
('Lisa', 'Anderson', 'Sales', 58000, '2021-05-20', 3,
'lisa.a@company.com');

INSERT INTO projects (project_name, budget, start_date,
end_date, status) VALUES
('Website Redesign', 150000, '2024-01-01', '2024-06-30',
'Active'),
('CRM Implementation', 200000, '2024-02-15', '2024-12-31',
'Active'),
('Marketing Campaign', 80000, '2024-03-01', '2024-05-31',
'Completed'),
('Database Migration', 120000, '2024-01-10', NULL, 'Active');

INSERT INTO assignments (employee_id, project_id,
hours_worked, assignment_date) VALUES
(1, 1, 120.5, '2024-01-15'),
(2, 1, 95.0, '2024-01-20'),
(1, 4, 80.0, '2024-02-01'),
(3, 3, 60.0, '2024-03-05'),
(5, 2, 110.0, '2024-02-20'),
(6, 3, 75.5, '2024-03-10');

-- SELECT * FROM employees;
-- SELECT * FROM projects;
-- SELECT * FROM assignments;







-- My work

-- Part 1: Basic SELECT Queries

-- Task 1.1: Write a query to select all employees, displaying their 
--full name (concatenated first and last name), department, and salary.
SELECT first_name || ' ' || last_name AS full_name, department, salary FROM employees;


--Task 1.2: Use SELECT DISTINCT to find all unique departments in the company
SELECT DISTINCT department FROM employees;
  

--Task 1.3: Select all projects with their names and budgets, and create a new column called
-- budget_category using a CASE expression:
-- • 'Large' if budget > 150000
-- • 'Medium' if budget between 100000 and 150000
-- • 'Small' otherwise
ALTER TABLE projects ADD column budget_category VARCHAR(30);
update projects SET budget_category=
  CASE
      WHEN budget > 150000 THEN 'Large'
      WHEN budget between 100000 AND 150000 THEN 'Medium'
      ELSE 'Small'
  END;
SELECT project_name, budget,budget_category FROM projects;


--Task 1.4: Write a query using COALESCE to display employee names and their emails. If email is
--NULL, display 'No email provided'.
SELECT first_name, COALESCE(email, 'No email provided') FROM employees;



-- Part 2: WHERE Clause and Comparison Operators

--Task 2.1: Find all employees hired after January 1, 2020
SELECT * FROM employees WHERE hire_date > '2020-01-01';


--Task 2.2: Find all employees whose salary is between 60000 and 70000 (use the BETWEEN operator)
SELECT * FROM employees WHERE salary BETWEEN 60000 AND 70000;


--Task 2.3: Find all employees whose last name starts with 'S' or 'J' (use the LIKE operator).
SELECT * FROM employees WHERE last_name LIKE 'S%' OR last_name LIKE 'J%';


--Task 2.4: Find all employees who have a manager (manager_id IS NOT NULL) and work in the IT department
SELECT * FROM employees WHERE manager_id IS NOT NULL AND department='IT';



-- Part 3: String and Mathematical Functions

-- Task 3.1: Create a query that displays:
SELECT 
  UPPER(first_name || ' ' || last_name) as full_name, 
  LENGTH(last_name), 
  SUBSTRING(email FROM 1 FOR 3) as email_prefix
FROM employees;


-- Task 3.2: Calculate the following for each employee:
SELECT
  (first_name || ' ' || last_name) as full_name,
  salary*12 as annual_salary,
  ROUND(salary,2) as monthly_salary,
  (salary*1.1) as raisly_salary
FROM employees;


-- Task 3.3: Use the format() function to create a formatted string for each project: 
-- "Project:[name] - Budget: $[budget] - Status: [status]"
SELECT
  format('Project: %s - Budget: $%s - Status: %s',
    project_name, 
    to_char(budget, 'FM999,999,999.00'),    --FM delete all probels
    status) as project_summary
FROM projects;


-- Task 3.4: Calculate how many years each employee has been with the company (use date functions and the current date)
SELECT 
  (first_name || ' ' || last_name) as full_name,
  extract(YEAR FROM AGE(current_date, hire_date)) AS year_work_time
FROM employees;


-- Task 4.1: Calculate the average salary for each department
SELECT department, AVG(salary) AS average_salary FROM employees GROUP BY department;


-- Task 4.2: Find the total hours worked on each project, including the project name
SELECT p.project_name, SUM(a.hours_worked) as total_hours_worked FROM projects p 
  JOIN assignments a ON p.project_id = a.project_id GROUP BY project_name;
  

-- Task 4.3: Count the number of employees in each department. Only show departments with more than 1 employee (use HAVING).
SELECT department, COUNT(*) FROM employees GROUP BY department HAVING COUNT(*) > 1;
 

-- Task 4.4: Find the maximum and minimum salary in the company, along with the total payroll (sum
-- of all salaries).
SELECT MAX(salary) as max_salary, MIN(salary) as min_salary, SUM(salary) as total_company_salary FROM employees;



-- Part 5: Set Operations

-- Task 5.1: Write two queries and combine them using UNION:
-- Query 1: Employees with salary > 65000
SELECT employee_id, (first_name || ' ' || last_name) as full_name, salary FROM employees WHERE salary > 65000
UNION
-- Query 2: Employees hired after 2020-01-01 Display employee_id, full name, and salary
SELECT employee_id, (first_name || ' ' || last_name) as full_name, salary 
FROM employees WHERE hire_date > '2020-01-01' ORDER BY employee_id ASC;


-- Task 5.2: Use INTERSECT to find employees who work in IT AND have a salary greater than 65000
SELECT employee_id, (first_name || ' ' || last_name) as full_name, salary, department
FROM employees WHERE department='IT'
INTERSECT
SELECT employee_id, (first_name || ' ' || last_name) as full_name, salary, department
FROM employees WHERE salary > 65000 ORDER BY employee_id ASC;


-- Task 5.3: Use EXCEPT to find all employees who are NOT assigned to any projects
SELECT e.employee_id, (e.first_name || ' ' || e.last_name) as full_name FROM employees e
EXCEPT
SELECT  a.employee_id, (e.first_name || ' ' || e.last_name) as full_name FROM assignments a 
JOIN employees e ON e.employee_id = a.employee_id;



-- Part 6: Subqueries

-- Task 6.1: Use EXISTS to find all employees who have at least one project assignment.
SELECT employee_id, (first_name || ' ' || last_name) as full_name FROM employees e
WHERE EXISTS (SELECT * FROM assignments a WHERE e.employee_id = a.employee_id);
-- EXISTS проверяет, существует ли хотя бы одна строка, возвращаемая подзапросом.
-- Как только внутри находится хотя бы одно совпадение → EXISTS = TRUE.
-- Если нет совпадений → FALSE.
-- SELECT 1 внутри подзапроса — просто формальность, можно писать и SELECT *, это не важно.


-- Task 6.2: Use IN with a subquery to find all employees working on projects with status 'Active'.
SELECT e.employee_id, (e.first_name || ' ' || e.last_name) as full_name FROM employees e 
WHERE employee_id IN(
SELECT a.employee_id FROM assignments a JOIN projects p ON a.project_id = p.project_id WHERE p.status='Active' ORDER BY e.employee_id ASC);


-- Task 6.3: Use ANY to find employees whose salary is greater than ANY employee in the Sales department.
SELECT e.employee_id, (e.first_name || ' ' || e.last_name) as full_name FROM employees e
WHERE e.salary > ANY(SELECT salary from employees WHERE department='Sales') ORDER BY e.employee_id ASC;



-- Part 7: Complex Queries

-- Task 7.1: Create a query that shows:
-- • Employee name
-- • Their department
-- • Average hours worked across all their assignments
-- • Their rank within their department by salary (use ORDER BY if window functions not
-- covered)
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name as full_name,
    e.department, 
    ROUND(AVG(a.hours_worked),2) as avg_hours_worked,
    RANK() OVER (PARTITION BY e.department ORDER BY e.salary DESC) AS salary_rank
FROM employees e 
LEFT JOIN assignments a ON e.employee_id = a.employee_id 
GROUP BY e.employee_id, e.first_name, e.last_name, e.department, e.salary 
ORDER BY e.department, salary_rank;


-- Task 7.2: Find projects where the total hours worked exceeds 150 hours. Display project name, 
--total hours, and number of employees assigned.
SELECT 
  p.project_name,
  SUM(a.hours_worked) AS total_hours,
  COUNT(DISTINCT a.employee_id) AS num_employees
FROM projects p JOIN assignments a ON p.project_id = a.project_id
GROUP BY p.project_name
HAVING SUM(a.hours_worked) > 150;
  

--Task 7.3: Create a report showing departments with their:
-- • Total number of employees
-- • Average salary
-- • Highest paid employee name Use GREATEST and LEAST functions somewhere in this
-- query
SELECT
  e1.department,
  COUNT(e1.department) as count_in_dep,
  ROUND(AVG(e1.salary),2) as average_salary_in_dep,
  
   -- Получаем имя самого высокооплачиваемого сотрудника в департаменте
  (SELECT (e2.first_name || ' ' || e2.last_name) as full_name FROM employees e2
  WHERE e2.department = e1.department ORDER BY e2.salary DESC LIMIT 1) as highest_salary,
  
  -- Используем GREATEST и LEAST (пример сравнения средней и максимальной зарплаты)
  ROUND(GREATEST(AVG(salary), MAX(salary)),2) as greatest_salary,
  ROUND(LEAST(AVG(salary), MIN(salary)),2) as least_salary

FROM employees e1
GROUP BY department;