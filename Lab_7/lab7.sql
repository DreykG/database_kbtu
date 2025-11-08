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




--PART 2:
--ex2.1:
CREATE VIEW employee_details AS
SELECT 
  e.emp_id, 
  e.emp_name, 
  d.dept_name, 
  d.location
FROM employees e 
JOIN departments d ON e.dept_id = e.dept_id;

SELECT * FROM employee_details;



--ex2.2:
CREATE VIEW dept_statistics AS
SELECT 
  d.dept_id, 
  d.dept_name, 
  count(e.emp_id) as employee_count, 
  avg(e.salary) as avg_salary, 
  min(e.salary) as min_salary, 
  max(e.salary) as max_salary
FROM departments d
LEFT JOIN employees e ON e.dept_id = d.dept_id
GROUP BY d.dept_id, d.dept_name;

SELECT * FROM dept_statistics
ORDER BY employee_count DESC;



--ex2.3:
CREATE VIEW project_overview AS 
SELECT 
  p.project_id,
  p.project_name,
  p.budget,
  d.dept_id,
  d.dept_name,
  d.location,
  COUNT(DISTINCT e.emp_id) as team_size
FROM projects p
JOIN departments d ON p.dept_id = d.dept_id
LEFT JOIN employees e ON e.dept_id = d.dept_id
GROUP BY 
  p.project_id,
  p.project_name,
  p.budget,
  d.dept_id,
  d.dept_name,
  d.location;

SELECT * FROM project_overview ORDER BY project_id ASC;
  


--ex2.4:
CREATE VIEW high_earners AS
SELECT 
  e.emp_id,
  e.emp_name,
  e.salary,
  d.dept_name
FROM employees e 
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 55000;

SELECT * FROM high_earners;



--PART 3:
--ex3.1:
--CREATE OR REPLACE VIEW column_name AS - используется для именения Представления
CREATE OR REPLACE VIEW employee_details AS
  SELECT 
    e.emp_id, 
    e.emp_name, 
    d.dept_name, 
    d.location,
    e.salary,
    CASE
      WHEN e.salary > 60000 THEN 'High'
      WHEN e.salary > 50000 THEN 'Medium'
      ELSE 'Standard'
    END as salary_grade
  FROM employees e
  JOIN departments d ON e.dept_id = d.dept_id;
  
SELECT * FROM employee_details ORDER BY emp_id ASC;




--ex3.2:
ALTER VIEW high_earners RENAME TO top_performers;
SELECT * FROM top_performers;



--ex3.3:
CREATE VIEW temp_view AS
SELECT 
  emp_id,
  emp_name,
  salary
FROM employees WHERE salary < 50000;

SELECT * FROM temp_view;
DROP VIEW temp_view;



--PART 4:
--ex4.1:
CREATE VIEW employee_salaries AS
SELECT
  e.emp_id,
  e.emp_name,
  e.dept_id,
  e.salary
FROM employees e;

SELECT * FROM employee_salaries ORDER BY emp_id ASC;
  


--ex4.2:
UPDATE employee_salaries SET salary=52000 WHERE emp_name='John Smith';
SELECT * FROM employees WHERE emp_name = 'John Smith';



--ex4.3:
INSERT INTO employee_salaries VALUES(6, 'Alice Johnson', 102, 58000);
SELECT * FROM employee_salaries ORDER BY emp_id ASC;



--ex4.4:
CREATE VIEW it_employees AS
SELECT 
  e.emp_id,
  e.emp_name,
  e.dept_id,
  e.salary
FROM employees e 
WHERE dept_id=101
WITH LOCAL CHECK OPTION;

--INSERT INTO it_employees (emp_id, emp_name, dept_id, salary)
--VALUES (7, 'Bob Wilson', 103, 60000);



--PART 5:
--ex5.1:
CREATE MATERIALIZED VIEW dept_summary_mv AS
SELECT 
    d.dept_id, d.dept_name,
    COALESCE(COUNT(DISTINCT e.emp_id), 0) as total_employees,
    COALESCE(SUM(e.salary), 0) as total_salaries,
    COALESCE(COUNT(DISTINCT p.project_id), 0) as total_projects,
    COALESCE(SUM(p.budget), 0) as total_project_budget
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = p.dept_id
GROUP BY d.dept_id, d.dept_name
WITH DATA;

SELECT * FROM dept_summary_mv ORDER BY total_employees DESC;



--ex5.2:
INSERT INTO employees VALUES(8,'Charlie Brown',101,54000);

REFRESH MATERIALIZED VIEW dept_summary_mv; --Обновили наши данные в Материализованном Представлении.

SELECT * FROM dept_summary_mv ORDER BY total_employees DESC;



--ex5.3:
CREATE UNIQUE INDEX dept_summary_mv_dept_id_uniqidx
ON dept_summary_mv (dept_id);

REFRESH MATERIALIZED VIEW CONCURRENTLY dept_summary_mv;
--Преимущество CONCURRENTLY - возможность обновлять материализованное 
--представление без блокировки SELECT запросов
SELECT * FROM dept_summary_mv ORDER BY total_employees DESC;



--ex5.4:
-- CREATE MATERIALIZED VIEW project_stats_mv AS 
-- SELECT 
--   p.project_name,
--   p.budget,
--   d.dept_name,
--   COUNT(DISTINCT emp_id) as team_size
-- FROm projects p 
-- JOIN departments d ON p.dept_id = d.dept_id
-- LEFT JOIN employees e ON e.dept_id = d.dept_id
-- GROUP BY p.project_name, p.budget, d.dept_name
-- WITH NO DATA;

--REFRESH MATERIALIZED VIEW project_stats_mv;
--SELECT * FROM project_stats_mv;



--PART 6:
--ex6.1:
-- • A basic role named analyst (no login)
CREATE ROLE analyst;
-- • A role named data_viewer with LOGIN and password 'viewer123'
CREATE ROLE data_viewer WITH LOGIN PASSWORD 'viewer123';
-- • A user named report_user with password 'report456'
CREATE USER report_user WITH PASSWORD 'report456';

SELECT rolname FROM pg_roles WHERE rolname NOT LIKE 'pg_%';



--ex6.2:
-- 1. db_creator - может создавать БД, имеет логин
CREATE ROLE db_creator WITH 
  CREATEDB 
  LOGIN 
  PASSWORD 'creator789';

-- 2. user_manager - может создавать роли, имеет логин
CREATE ROLE user_manager WITH 
  CREATEROLE 
  LOGIN 
  PASSWORD 'manager101';

-- 3. admin_user - суперпользователь с логином
CREATE ROLE admin_user WITH 
  SUPERUSER 
  LOGIN 
  PASSWORD 'admin999';



--ex6.3:
-- 1. SELECT на таблицы employees, departments, projects для analyst
GRANT SELECT ON employees, departments, projects TO analyst;

-- 2. ALL PRIVILEGES на представление employee_details для data_viewer
GRANT ALL PRIVILEGES ON employee_details TO data_viewer;

-- 3. SELECT и INSERT на таблицу employees для report_user
GRANT SELECT, INSERT ON employees TO report_user;




--ex6.4:
-- 1. Создаем групповые роли
CREATE ROLE hr_team;
CREATE ROLE finance_team;
CREATE ROLE it_team;

CREATE USER hr_user1 WITH PASSWORD 'hr001';
CREATE USER hr_user2 WITH PASSWORD 'hr002';
CREATE USER finance_user1 WITH PASSWORD 'fin001';

GRANT hr_team TO hr_user1,hr_user2;
GRANT finance_team TO finance_user1;

GRANT SELECT, UPDATE ON employees TO hr_team;
GRANT SELECT ON dept_statistics TO finance_team;

-- Проверим все роли
SELECT 
    rolname,
    rolcanlogin as can_login,
    rolinherit as inherits
FROM pg_roles 
WHERE rolname IN ('hr_team', 'finance_team', 'it_team', 'hr_user1', 'hr_user2', 'finance_user1')
ORDER BY rolname;

-- Посмотрим членство в группах
SELECT 
    rolname as user_name,
    ARRAY(
        SELECT m.rolname 
        FROM pg_auth_members am 
        JOIN pg_roles m ON am.roleid = m.oid 
        WHERE am.member = r.oid
    ) as member_of_groups
FROM pg_roles r
WHERE r.rolname IN ('hr_user1', 'hr_user2', 'finance_user1');


--ex6.5:
REVOKE UPDATE ON employees FROM hr_team;
REVOKE hr_team FROM hr_user2;
REVOKE ALL PRIVILEGES ON employee_details FROM data_viewer;



--ex6.6:
ALTER ROLE analyst WITH LOGIN PASSWORD 'analyst123';
ALTER ROLE user_manager SUPERUSER;
ALTER ROLE analyst WITH PASSWORD NULL;
ALTER ROLE data_viewer CONNECTION LIMIT 5;



--PART 7:
--ex7.1:
-- 1. Создаем родительскую роль read_only и даем SELECT на все таблицы в public
CREATE ROLE read_only;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;

-- 2. Создаем дочерние роли
CREATE ROLE junior_analyst WITH LOGIN PASSWORD 'junior123';
CREATE ROLE senior_analyst WITH LOGIN PASSWORD 'senior123';

-- 3. Назначаем read_only для обоих аналитиков
GRANT read_only TO junior_analyst, senior_analyst;

-- 4. Даем дополнительные права INSERT и UPDATE на employees только senior_analyst
GRANT INSERT, UPDATE ON employees TO senior_analyst;

-- Проверим членство в ролях
SELECT 
    rolname as user_name,
    ARRAY(
        SELECT m.rolname 
        FROM pg_auth_members am 
        JOIN pg_roles m ON am.roleid = m.oid 
        WHERE am.member = r.oid
    ) as member_of_roles
FROM pg_roles r
WHERE r.rolname IN ('junior_analyst', 'senior_analyst');

-- Проверим привилегии для всех ролей в иерархии
SELECT 
    grantee,
    table_name,
    privilege_type
FROM information_schema.table_privileges 
WHERE grantee IN ('read_only', 'junior_analyst', 'senior_analyst')
ORDER BY grantee, table_name, privilege_type;



--ex7.2:
-- 1. Создаем роль project_manager
CREATE ROLE project_manager WITH LOGIN PASSWORD 'pm123';

-- 2. Передаем владение представлением dept_statistics
ALTER VIEW dept_statistics OWNER TO project_manager;

-- 3. Передаем владение таблицей projects
ALTER TABLE projects OWNER TO project_manager;

-- Проверка
SELECT tablename, tableowner
FROM pg_tables
WHERE schemaname = 'public';


--ex7.3:
-- 1. Создаем роль temp_owner
CREATE ROLE temp_owner WITH LOGIN;

-- 2. Создаем таблицу temp_table
CREATE TABLE temp_table(
    id INT
);
-- 3. Передаем владение temp_table на temp_owner
ALTER TABLE temp_table OWNER TO temp_owner;

-- 4. Переназначаем все объекты temp_owner на postgres
REASSIGN OWNED BY temp_owner TO postgres;

-- 5. Удаляем все объекты temp_owner
DROP OWNED BY temp_owner;

-- 6. Удаляем роль temp_owner
DROP ROLE temp_owner;



--ex7.4:
-- 1. Создаем представление для HR отдела
CREATE VIEW hr_employee_view AS
SELECT *
FROM employees
WHERE dept_id = 102;

-- 2. Даем права SELECT на это представление hr_team
GRANT SELECT ON hr_employee_view TO hr_team;

-- 3. Создаем представление для финансового отдела
CREATE VIEW finance_employee_view AS
SELECT emp_id, emp_name, salary
FROM employees;

-- 4. Даем права SELECT на это представление finance_team
GRANT SELECT ON finance_employee_view TO finance_team;



--PART 8:
--ex8.1:
-- Создаем комплексное представление дашборда для менеджеров отделов
CREATE VIEW dept_dashboard AS
SELECT 
    d.dept_name,  
    d.location,                    
    -- Количество сотрудников в отделе
    COUNT(DISTINCT e.emp_id) as employee_count,
    -- Средняя зарплата (округлено до 2 знаков)
    ROUND(AVG(e.salary), 2) as avg_salary, 
    -- Количество активных проектов
    COUNT(DISTINCT p.project_id) as active_projects,  
    -- Суммарный бюджет проектов (0 если нет проектов)
    COALESCE(SUM(p.budget), 0) as total_budget,              
    -- Бюджет на одного сотрудника с обработкой деления на ноль
    CASE 
    -- Если нет сотрудников - бюджет 0
        WHEN COUNT(DISTINCT e.emp_id) = 0 THEN 0          
        -- Бюджет на сотрудника
        ELSE ROUND(COALESCE(SUM(p.budget), 0) / COUNT(DISTINCT e.emp_id), 2)  
    END as budget_per_employee
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id               -- Присоединяем сотрудников отдела
LEFT JOIN projects p ON d.dept_id = p.dept_id                -- Присоединяем проекты отдела
GROUP BY d.dept_id, d.dept_name, d.location;                 -- Группируем по отделу




--ex8.2:
-- 1. Добавляем колонку created_date в таблицу projects
ALTER TABLE projects ADD COLUMN created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- 2. Создаем представление для проектов с высоким бюджетом
CREATE VIEW high_budget_projects AS
SELECT 
    p.project_name,
    p.budget,
    d.dept_name,
    p.created_date,
    -- Статус утверждения на основе бюджета
    CASE 
        WHEN p.budget > 150000 THEN 'Critical Review Required'    -- Бюджет > 150k
        WHEN p.budget > 100000 THEN 'Management Approval Needed'  -- Бюджет > 100k
        ELSE 'Standard Process'                                   -- Остальные случаи
    END as approval_status
FROM projects p
JOIN departments d ON p.dept_id = d.dept_id    -- Соединяем с отделами
WHERE p.budget > 75000;                        -- Только проекты с бюджетом > 75k




--ex8.3:
-- Level 1 - Viewer Role: только просмотр
CREATE ROLE viewer_role;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO viewer_role;

-- Level 2 - Entry Role: просмотр + добавление
CREATE ROLE entry_role;
GRANT viewer_role TO entry_role;
GRANT INSERT ON employees, projects TO entry_role;

-- Level 3 - Analyst Role: просмотр + добавление + изменение
CREATE ROLE analyst_role;
GRANT entry_role TO analyst_role;
GRANT UPDATE ON employees, projects TO analyst_role;

-- Level 4 - Manager Role: полный доступ
CREATE ROLE manager_role;
GRANT analyst_role TO manager_role;
GRANT DELETE ON employees, projects TO manager_role;

-- Создаем пользователей
CREATE USER alice WITH PASSWORD 'alice123';
CREATE USER bob WITH PASSWORD 'bob123';
CREATE USER charlie WITH PASSWORD 'charlie123';

-- Назначаем роли пользователям
GRANT viewer_role TO alice;
GRANT analyst_role TO bob;
GRANT manager_role TO charlie;
































