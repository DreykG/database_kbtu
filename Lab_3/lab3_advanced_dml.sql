--Part A: Database and Table Setup
--1. Create database and tables

CREATE DATABASE IF NOT EXISTS advanced_lab;

CREATE TABLE IF NOT EXISTS employees(
    emp_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(30),
    last_name VARCHAR(30),
    department VARCHAR(50),
    salary INT,
    hire_date DATE,
    status VARCHAR(30) DEFAULT 'Active'      
);
CREATE TABLE IF NOT EXISTS departments(
    dept_id INT AUTO_INCREMENT PRIMARY KEY,
    dept_name VARCHAR(50),
    budget INT,
    manager_id INT
);
CREATE TABLE IF NOT EXISTS projects(
    project_id INT AUTO_INCREMENT PRIMARY KEY,
    project_name VARCHAR(50),
    dept_id INT,
    start_date DATE,
    end_date DATE,
    budget INT,
);


--Part B: Advanced INSERT Operations

--2. INSERT with column specification
INSERT INTO employees(emp_id,first_name,last_name,department) VALUES (1, Timur, Kim, IT);
INSERT INTO employees(emp_id,first_name,last_name,department) VALUES (2, Vladislav, Lizko, IT);
INSERT INTO employees(emp_id,first_name,last_name,department) VALUES (3, Anatoly, Kim, HR);

--3. INSERT with DEFAULT values
INSERT INTO employees(emp_id,first_name,last_name,department, salary, status) VALUES (1, Timur, Kim, IT, DEFAULT, DEFAULT);
INSERT INTO employees(emp_id,first_name,last_name,department, salary, status) VALUES (2, Vladislav, Lizko, Biotechnology, DEFAULT, DEFAULT);
INSERT INTO employees(emp_id,first_name,last_name,department, salary, status) VALUES (3, Anatoly, Kim, HR, DEFAULT, DEFAULT);


--4. INSERT multiple rows in single statement
INSERT INTO departments(dept_id,dept_name,budget,manager_id)
    VALUES (1, IT, 300000,5);
INSERT INTO departments(dept_id,dept_name,budget,manager_id)
    VALUES (2, Biotechnology, 321000,5);
INSERT INTO departments(dept_id,dept_name,budget,manager_id)
    VALUES (3, HR, 200000,8);


--5. INSERT with expressions
INSERT INTO employees(emp_id,first_name,last_name,department,hire_date,salary) 
    VALUES(4, Taka, Frizov, Sales, CURRENT_DATE, 5000*1.1);

--6. INSERT from SELECT (subquery)
CREATE TABLE IF NOT EXISTS temp_employees(
    emp_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(30),
    last_name VARCHAR(30),
    department VARCHAR(50),
    salary INT,
    hire_date DATE,
    status VARCHAR(30) DEFAULT 'Active' 
);

INSERT INTO temp_employees(emp_id,first_name,last_name,department,salary,hire_date,status)
    SELECT emp_id, first_name, last_name, department, salary, hire_date, status
        FROM employees WHERE department='IT';


--Part C: Complex UPDATE Operations
--7. UPDATE with arithmetic expressions
UPDATE employees SET salary = salary*1.1;


--8. UPDATE with WHERE clause and multiple conditions
UPDATE employees SET status='Senior' WHERE salary > 60000 AND hire_date < '2020-01-01';


--9. UPDATE using CASE expression
UPDATE employees SET department=
    CASE
        WHEN salary > 80000 THEN 'Management'
        WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
        ELSE 'Junior'
    END;


--10. UPDATE with DEFAULT
UPDATE employees SET department=DEFAULT WHERE status='Inactive';


--11. UPDATE with subquery
UPDATE department SET budget = (SELECT AVG(salary) FROM employees WHERE employees.department = departments.dept_name);


--12. UPDATE multiple columns
UPDATE employees SET salary = salary*1.5, status = 'Promoted' WHERE department='Sales';


--Part D: Advanced DELETE Operations
--13. DELETE with simple WHERE condition
DELETE FROM employees WHERE status='Terminated';


--14. DELETE with complex WHERE clause
DELETE FROM employees WHERE salary < 40000 AND hire_date > DATE '2023-01-01' AND department IS NULL;


--15. DELETE with subquery
DELETE departments WHERE dept_id NOT IN 
    (SELECT DISTINCT department FROM employees WHERE department IS NOT NULL) --DISTINCT - убирает дубликаты


--16. DELETE with RETURNING clause
DELETE FROM projects 
    WHERE end_date < DATE '2023-01-01'
    RETURNING *;        --'RETURNING *' - это специальная конструкция в PostgreSQL, 
                        --которая возвращает данные удаленных, обновленных или вставленных строк.



--Part E: Operations with NULL Values
--17. INSERT with NULL values
INSERT INTO employees(first_name, last_name, salary, department) 
VALUES ('Den', 'Abdurakhamov', NULL, NULL);


--18. UPDATE NULL handling
UPDATE employees SET department='Unassigned' WHERE department IS NULL;


--19. DELETE with NULL conditions
DELETE FROM employees WHERE salary IS NULL OR department IS NULL;


--Part F: RETURNING Clause Operations
--20. INSERT with RETURNING
INSERT INTO employees(first_name,last_name,salary,department)
    VALUES('Radrigo','Baile',90000,'ICT') 
        RETURNING emp_id, first_name || ' ' || last_name AS full_name;      --|| - concatination of data.


--21. UPDATE with RETURNING
UPDATE employees SET salary = salary+5000 
    WHERE department='IT'
        RETURNING 
        emp_id,
        (salary-5000) AS old_salary,
        salary AS new_salary;


--22. DELETE with RETURNING all columns
DELETE FROM employees WHERE hire_date < DATE '2020-01-01'
    RETURNING *;


--Part G: Advanced DML Patterns 
--23. Conditional INSERT
INSERT INTO employees(first_name,last_name,department,salary)
    SELECT 'Vladislav','Lizko','IT','70000'
    WHERE NOT EXISTS (
    SELECT 1 FROM employees
    WHERE first_name='Vladislav' AND last_name='Lizko'
    );
                --Ищет в таблице employees запись с first_name='John' и last_name='Doe'
                --Если находит - возвращает 1 (или любую другую константу)
                --Если не находит - возвращает пустой результат
                --Если NOT EXISTS = TRUE → выполняется INSERT
                --Если NOT EXISTS = FALSE → INSERT не выполняется


--24. UPDATE with JOIN logic using subqueries
UPDATE employees SET salary=
    CASE 
        WHEN department IN(
            SELECT dept_name FROM departments WHERE budget > 100000
        )  > 100000 THEN salary*1.1
        ELSE salary*1.05
    END;


--25. Bulk operations
INSERT INTO employees(first_name,last_name,department,salary) VALUES
        ('Liza','Oiranov','IT',60000),
        ('Aziza','Nurpesh','HR',50000),
        ('Lena','Ferangel','Salse',55000),
        ('Tamerlan','Osmanov','IT',70000),
        ('Vaas','Montenegro','Games',115000);

UPDATE employees SET salary = salary*1.1 
    WHERE first_name IN ('Liza','Aziza','Lena','Tamerlan','Vaas');


--26. Data migration simulation
CREATE TABLE IF NOT EXISTS employee_archive(
    emp_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(30),
    last_name VARCHAR(30),
    department VARCHAR(50),
    salary INT,
    hire_date DATE,
    status VARCHAR(30)
);

INSERT INTO employee_archive SELECT * FROM employees WHERE status='Inactive';
DELETE FROM employees WHERE status='Inactive';


--27. Complex business logic
UPDATE projects SET end_date= end_date + INTERVAL '30 Days'
    WHERE budget > 50000 AND dept_id IN(
        SELECT dept_id FROM departments WHERE dept_name IN(
            SELECT department FROM employees
                GROUP BY department HAVING COUNT(*) > 3
        )
    );