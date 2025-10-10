--Task 1.1: Basic CHECK Constraint
CREATE TABLE employees (
  employee_id SERIAL PRIMARY KEY,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  age INT check(age between 18 AND 36),   --CHECK - тип ограничения для проверки условий
  salary NUMERIC check(salary > 0)
);

--Task 1.2: Named CHECK Constraint

CREATE TABLE products_catalog(
  product_id SERIAL PRIMARY KEY,
  product_name VARCHAR(100),
  regular_price NUMERIC,
  discount_price NUMERIC,
  Constraint valid_discount CHECK(    --CONSTRAINT - ключевое слово для создания именованного ограничения
    regular_price > 0 AND
    discount_price > 0 AND
    discount_price < regular_price
    )
);

--Task 1.3: Multiple Column CHECK
CREATE TABLE bookings(
  booking_id SERIAL PRIMARY KEY,
  check_in_date DATE,
  check_out_date DATE,
  num_guests INT,
  CHECK (num_guests BETWEEN 1 AND 10),
  CHECK (check_out_date > check_in_date)
);

--Task 1.4: Testing CHECK Constraints
--1. Successfully insert valid data (at least 2 rows per table)
INSERT INTO employees(first_name, last_name, age, salary) values ('Vlad', 'Lizko', 19, 350000);
INSERT INTO employees(first_name, last_name, age, salary) values ('Timur', 'Kim', 18, 300000);
INSERT INTO employees(first_name, last_name, age, salary) values ('Anatoly', 'LizKim', 21, 100000);

--2. Attempt to insert invalid data that violates each CHECK constraint
-- INSERT INTO employees(first_name, last_name, age, salary) values ('Vlad', 'Lizko', 15, 350000);
-- INSERT INTO employees(first_name, last_name, age, salary) values ('Timur', 'Kim', 12, 300000);
-- INSERT INTO employees(first_name, last_name, age, salary) values ('Anatoly', 'LizKim', 56, -1000);

--3. Document which constraint is violated and why
--In 1st age < 18, In second Age < 18 too, in 3rd age>36 and salary < 0;

--Part 2: NOT NULL Constraints
--Task 2.1: NOT NULL Implementation
CREATE TABLE customers(
  customer_id SERIAL PRIMARY KEY NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  registration_date DATE NOT NULL
);


--Task 2.2: Combining Constraints
CREATE TABLE inventory(
  item_id SERIAL PRIMARY KEY NOT NULL,
  item_name TEXT NOT NULL,
  quantity INT NOT NULL CHECK(quantity >= 0),
  unit_price NUMERIC NOT NULL CHECK(unit_price > 0),
  last_updated TIMESTAMP NOT NULL 
);

--Task 2.3: Testing NOT NULL
--Successfully insert complete records
INSERT INTO inventory(item_name,quantity,unit_price,last_updated) VALUES ('Bow', 10, 50000, '2025-10-10 16:51:49');
INSERT INTO inventory(item_name,quantity,unit_price,last_updated) VALUES ('AK-47', 15, 50000, '2025-06-10 06:11:49');
INSERT INTO inventory(item_name,quantity,unit_price,last_updated) VALUES ('RPG', 8, 999000, '2025-02-10 11:51:49');

--Attempt to insert records with NULL values in NOT NULL columns
-- INSERT INTO inventory(item_name,quantity,unit_price,last_updated) VALUES ('Bow', 10, NULL, '2025-10-10 16:51:49');
-- INSERT INTO inventory(item_name,quantity,unit_price,last_updated) VALUES (NULL, 15, 50000, '2025-06-10 06:11:49');
-- INSERT INTO inventory(item_name,quantity,unit_price,last_updated) VALUES ('RPG', NULL, 999000, NULL);

--Insert records with NULL values in nullable columns
INSERT INTO customers(email, phone, registration_date) values ('vlad123@gmail.com', NULL, '2024-08-21');
INSERT INTO customers(email, phone, registration_date) values ('vlad123@gmail.com', NULL, '2023-09-12');


--Part 3: UNIQUE Constraints
--Task 3.1: Single Column UNIQUE

--UNIQUE Constraint - это ограничение, которое гарантирует, 
--что все значения в столбце (или комбинации столбцов) являются уникальными. 
--Дубликаты запрещены, но NULL значения разрешены (если колонка не NOT NULL).

CREATE TABLE users(
    user_id SERIAL PRIMARY KEY,
    username TEXT UNIQUE,
    email TEXT UNIQUE,
    created_at TIMESTAMP
);

--Task 3.2: Multi-Column UNIQUE
CREATE TABLE course_enrollments(
  enrollment_id SERIAL PRIMARY KEY,
  student_id INT,
  course_code TEXT,
  semester TEXT,
  UNIQUE(student_id, course_code, semester)
);

--Task 3.3: Named UNIQUE Constraints
ALTER TABLE users
  ADD Constraint unique_username UNIQUE(username);
ALTER TABLE users
  ADD Constraint unique_email UNIQUE(email);

INSERT INTO users(username,email,created_at) values('Egor', 'goga2@gmail.com','2024-01-02 17:12:41');
INSERT INTO users(username,email,created_at) values('Dreyk', 'dreykoskal@gmail.com','2023-12-06 11:12:02');
--INSERT INTO users(username,email,created_at) values('Dreyk', 'rockydgmail.com','2013-05-14 12:42:54');


--Part 4: PRIMARY KEY Constraints
--Task 4.1: Single Column Primary Key
CREATE TABLE departments(
  dept_id INT PRIMARY KEY,
  dept_name TEXT NOT NULL,
  location TEXT
);

INSERT INTO departments values(1,'Growy', 'Sairan');
INSERT INTO departments values(2,'Forest', 'Hawai');
INSERT INTO departments values(3,'SkySea', 'Tropic');
--INSERT INTO departments values(1,'KBTU jastar', 'Tole bi');
--INSERT INTO departments values(NULL,'Piece of happy', 'airport');

--Task 4.2: Composite Primary Key
CREATE TABLE student_courses(
  student_id INT,
  course_id INT,
  enrollment_date DATE,
  grade TEXT,
  PRIMARY KEY(student_id, course_id)
);

--Task 4.3: Comparison Exercise
--1. The difference between UNIQUE and PRIMARY KEY
-- UNIQUE gives us garantie that in column will be only unique values without repeating.
-- UNIQUE can has a NULL values.It just garantie the unique of data.

-- PRIMARY KEY is special key to help which, we can get acces to data from another table.
-- PRIMARY KEY cant have NULL values.It define unique of data.

--2 When to use a single-column vs. composite PRIMARY KEY
-- single-column we use when only one column define the row.
-- composite - when only composition of some columns define the row.

--3. Why a table can have only one PRIMARY KEY but multiple UNIQUE constraints
-- The PRIMARY KEY is the main identifier of string.
-- Table can have only one "primary identity" for a row.

-- UNIQUE is just a constraint of uniqueness, you can add as many as you want.
-- For example, a user may be unique by ID, but also have a unique email and phone number.



--Part 5: FOREIGN KEY Constraints
--Task 5.1: Basic Foreign Key
CREATE TABLE employees_dept (
  emp_id INT primary Key,
  emp_name TEXT NOT NULL,
  dept_id INT references departments(dept_id),  --dept_id — внешний ключ (FOREIGN KEY), 
                                                --который ссылается на departments(dept_id).
                                                --Это значит, что значение dept_id в employees_dept должно 
                                                --существовать в таблице departments
  hire_data DATE 
);
INSERT INTO employees_dept VALUES(1,'first', 1);
INSERT INTO employees_dept VALUES(2,'second', 2);
INSERT INTO employees_dept VALUES(3,'thirs', 3);
--SELECT * from employees_dept;

--Task 5.2: Multiple Foreign Keys
CREATE TABLE authors(
  author_id INT PRIMARY KEY,
  author_name TEXT NOT NULL,
  country TEXT
);
INSERT INTO authors VALUES(1,'Stev', 'America');
INSERT INTO authors VALUES(2,'Alex', 'Spanish');
INSERT INTO authors VALUES(3,'Notch', 'Russia');


CREATE TABLE publishers(
  publisher_id INT PRIMARY KEY,
  publisher_name TEXT NOT NULL,
  city TEXT
);
INSERT INTO publishers VALUES(1,'Nat.Library', 'New-Yourk');
INSERT INTO publishers VALUES(2,'RIM lubrary', 'Rim');
INSERT INTO publishers VALUES(3,'RU segment', 'Moskau');


CREATE TABLE books(
  book_id INT PRIMARY KEY,
  title TEXT NOT NULL,
  author_id INT REFERENCES authors(author_id),
  publisher_id INT REFERENCES publishers(publisher_id),
  publication_year INT,
  isbn TEXT UNIQUE
);

INSERT INTO books VALUES(1,'Minecraft', 1, 1, 2024,'001');
INSERT INTO books VALUES(2,'Spartta', 3, 2, 2002,'003');
-- select * FROM authors;
-- select * FROM publishers;
-- select * FROM books;


--Task 5.3: ON DELETE Options
--parent's
CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    category_name TEXT NOT NULL
);
--children's
CREATE TABLE products_fk (
  product_id INT PRIMARY KEY,
  product_name TEXT NOT NULL,
  category_id INT NOT NULL
    REFERENCES categories(category_id) ON DELETE RESTRICT
    --RESTRICT — запрещает удалить родителя, если есть зависимые строки;
);
--parent's
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    order_date DATE NOT NULL
);
--children's
CREATE TABLE order_items(
  item_id INT PRIMARY KEY,
  order_id INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
  --CASCADE — «удаляя родителя, автоматически удаляй всех детей».
  product_id INT NOT NULL REFERENCES products_fk(product_id),
  quantity INT NOT NULL CHECK (quantity > 0)
);

INSERT INTO categories VALUES
  (1, 'Electronics'),
  (2, 'Books');

INSERT INTO products_fk VALUES
  (101, 'Phone', 1),
  (102, 'Laptop', 1),
  (201, 'Novel', 2);

INSERT INTO orders VALUES
  (5001, DATE '2025-10-01'),
  (5002, DATE '2025-10-02');

INSERT INTO order_items VALUES
  (1, 5001, 101, 1),
  (2, 5001, 102, 2),
  (3, 5002, 201, 1);

-- Test the following scenarios:
-- 1. Try to delete a category that has products (should fail with RESTRICT)
-- 2. Delete an order and observe that order_items are automatically deleted (CASCADE)
-- 3. Document what happens in each case

--1
--DELETE FROM categories WHERE category_id=1;

-- DELETE FROM orders WHERE order_id=5001;
-- SELECT * FROM orders;
-- SELECT * FROM order_items;

--An attempt to DELETE FROM categories WHERE category_id = 1 
  --results in an error: the category cannot be deleted as long as 
  --there are products that link to it.

--The DELETE FROM orders WHERE order_id = 5001 
  --command automatically deletes all rows 
  --from order_items with order_id = 5001.

--ON DELETE RESTRICT protects the parent from deletion with existing links.
--ON DELETE CASCADE deletes child rows automatically with the parent row. 


--Part 6: Practical Application
--Task 6.1: E-commerce Database Design

CREATE TABLE customers(
  customer_id SERIAL NOT NULL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  phone TEXT NOT NULL UNIQUE,
  registration_date DATE NOT NULL default current_date
  );
  
CREATE TABLE products(
  product_id SERIAL NOT NULL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  price NUMERIC(10,2) NOT NULL CHECK(price>=0),
  stock_quantity INT CHECK(stock_quantity >= 0)
);

CREATE TABLE orders(
  order_id SERIAL NOT NULL PRIMARY KEY, 
  customer_id INT REFERENCES customers(customer_id) ON DELETE RESTRICT, 
  order_date DATE default current_date, 
  total_amount NUMERIC(10,2) NOT NULL default 0 CHECK(total_amount >= 0), 
  status TEXT NOT NULL CHECK (status IN ('pending','paid','shipped','cancelled','completed'))
);

CREATE TABLE order_details(
  order_detail_id SERIAL NOT NULL PRIMARY KEY, 
  order_id INT REFERENCES orders(order_id) ON DELETE CASCADE, 
  product_id INT REFERENCES products(product_id) ON DELETE RESTRICT, 
  quantity INT NOT NULL CHECK(quantity >= 0), 
  unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
  UNIQUE (order_id, product_id)
);












