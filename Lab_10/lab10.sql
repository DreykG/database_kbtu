CREATE TABLE accounts (
 id SERIAL PRIMARY KEY,
 name VARCHAR(100) NOT NULL,
 balance DECIMAL(10, 2) DEFAULT 0.00
);
CREATE TABLE products (
 id SERIAL PRIMARY KEY,
 shop VARCHAR(100) NOT NULL,
 product VARCHAR(100) NOT NULL,
 price DECIMAL(10, 2) NOT NULL
);
-- Insert test data
INSERT INTO accounts (name, balance) VALUES
 ('Alice', 1000.00),
 ('Bob', 500.00),
 ('Wally', 750.00);
INSERT INTO products (shop, product, price) VALUES
 ('Joe''s Shop', 'Coke', 2.50),
 ('Joe''s Shop', 'Pepsi', 3.00);


-- 3.2 Task 1: Basic Transaction with COMMIT
-- Objective: Transfer money between accounts using a transaction.
BEGIN;
UPDATE accounts SET balance = balance - 100.00
    WHERE name = 'Alice';
UPDATE accounts SET balance = balance + 100.00
    WHERE name = 'Bob';
COMMIT;

-- a) Alice: 900.00, Bob: 600.00.
-- b) It is important that both UPDATES are in the same transaction, 
-- so that it does not happen that the money was debited 
-- from Alice and Bob did not receive it (or vice versa). This is a guarantee of atomicity.
-- c) If there had been no transaction and the system had crashed, 
-- the debit from Alice would have already occurred, 
-- but the transfer to Bob would not. The money would have been "lost." 
-- An automatic ROLLBACK would have occurred with the transaction if it failed.




-- 3.3 Task 2: Using ROLLBACK
-- Objective: Understand how ROLLBACK undoes changes
BEGIN;
UPDATE accounts SET balance = balance - 500.00
    WHERE name = 'Alice';
SELECT * FROM accounts WHERE name = 'Alice';
-- Oops! Wrong amount, let's undo
ROLLBACK;
SELECT * FROM accounts WHERE name = 'Alice';

-- a) After the UPDATE, the balance was 400.00 (1000 - 500).
-- b) After the ROLLBACK, the balance was 1000.00 again.
-- c) ROLLBACK is used for errors in logic (transferred to the wrong person), 
-- business logic failures (did not have enough money) or deadlock (mutual blocking).




-- 3.4 Task 3: Working with SAVEPOINTs
BEGIN;
UPDATE accounts SET balance = balance - 100.00
    WHERE name = 'Alice';
    SAVEPOINT my_savepoint;
UPDATE accounts SET balance = balance + 100.00
    WHERE name = 'Bob';
-- Oops, should transfer to Wally instead
ROLLBACK TO my_savepoint;
UPDATE accounts SET balance = balance + 100.00
    WHERE name = 'Wally';
COMMIT;




-- 3.5 Task 4: Isolation Level Demonstration
-- Scenario A: READ COMMITTED
-- Terminal 1:

BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to make changes and COMMIT
-- Then re-run:
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;

-- Terminal 2 (while Terminal 1 is still running):

BEGIN;
DELETE FROM products WHERE shop = 'Joe''s Shop';
INSERT INTO products (shop, product, price)
    VALUES ('Joe''s Shop', 'Fanta', 3.50);
COMMIT;

-- Scenario B: SERIALIZABLE
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to make changes and COMMIT
-- Then re-run:
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;

-- Terminal 2 (while Terminal 1 is still running):

BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
DELETE FROM products WHERE shop = 'Joe''s Shop';
INSERT INTO products (shop, product, price)
    VALUES ('Joe''s Shop', 'Fanta', 3.50);
COMMIT;




-- 3.6 Task 5: Phantom Read Demonstration
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT MAX(price), MIN(price) FROM products
    WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2
SELECT MAX(price), MIN(price) FROM products
    WHERE shop = 'Joe''s Shop';
COMMIT;

-- Terminal 2:

BEGIN;
INSERT INTO products (shop, product, price)
    VALUES ('Joe''s Shop', 'Sprite', 4.00);
COMMIT;




-- 3.7 Task 6: Dirty Read Demonstration
-- Terminal 1:

BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to UPDATE but NOT commit
SELECT * FROM products WHERE shop = 'Joe''s Shop';
-- Wait for Terminal 2 to ROLLBACK
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;

-- Terminal 2:

BEGIN;
UPDATE products SET price = 99.99
    WHERE product = 'Fanta';
-- Wait here (don't commit yet)
-- Then:
ROLLBACK;



-- 4. Independent Exercises
-- Exercise 1
BEGIN;
    UPDATE accounts SET balance = balance - 200.00 WHERE name = 'Bob' AND balance >= 200;
    IF NOT FOUND THEN 
        ROLLBACK;
    ELSE
        UPDATE accounts SET balance = balance + 200.00 WHERE name = 'Wally';
        COMMIT;
    END IF;

--Exercise 2
BEGIN;
    INSERT INTO products(shop,product,price) VALUES ('Prime','Meat', 450);
    SAVEPOINT meat;
    UPDATE products SET price = 475 WHERE product='Meat';
    SAVEPOINT meat_new_price;
    DELETE FROM products WHERE product='Meat';
    ROLLBACK TO meat_new_price;
COMMIT;


--Exercise 3
-- 1. Подготовка таблицы
CREATE TABLE bank_accounts (
    id SERIAL PRIMARY KEY,
    account_number VARCHAR(20),
    balance DECIMAL(10, 2)
);
INSERT INTO bank_accounts (account_number, balance) 
VALUES ('ACC123', 1000.00);


-- 2. Две сессии пытаются снять 800 одновременно

-- СЕССИЯ 1:
BEGIN;
SELECT balance FROM bank_accounts WHERE account_number = 'ACC123';
-- Видит 1000, снимает
UPDATE bank_accounts SET balance = balance - 800 WHERE account_number = 'ACC123';
-- Не коммитим сразу


-- СЕССИЯ 2:
BEGIN;
SELECT balance FROM bank_accounts WHERE account_number = 'ACC123';
-- Тоже видит 1000, пытается снять
UPDATE bank_accounts SET balance = balance - 800 WHERE account_number = 'ACC123';
-- Блокируется и ждет


-- СЕССИЯ 1:
COMMIT;

-- СЕССИЯ 2:
-- Разблокируется, но balance уже 200, поэтому:
-- Если было условие WHERE balance >= 800 - не сработает
-- Если без условия - уйдет в минус (-600)
COMMIT;

-- 3. Проверяем результат
SELECT * FROM bank_accounts;
--READ COMMITTED результат: Баланс -600 (уход в минус)




-- 4. SERIALIZABLE уровень
UPDATE bank_accounts SET balance = 1000 WHERE account_number = 'ACC123';


-- СЕССИЯ 1:
BEGIN ISOLATION LEVEL SERIALIZABLE;
UPDATE bank_accounts SET balance = balance - 800 WHERE account_number = 'ACC123';


-- СЕССИЯ 2:
BEGIN ISOLATION LEVEL SERIALIZABLE;
UPDATE bank_accounts SET balance = balance - 800 WHERE account_number = 'ACC123';
-- Блокировка


-- СЕССИЯ 1:
COMMIT;

-- СЕССИЯ 2:
-- Получает ошибку "could not serialize access"
ROLLBACK; -- автоматически




--TASK 4
CREATE TABLE Sells (
    shop VARCHAR(50),
    product VARCHAR(50),
    price DECIMAL(10, 2)
);

-- Добавляем тестовые данные
INSERT INTO Sells (shop, product, price) VALUES
('Joe''s Shop', 'Coke', 2.50),
('Joe''s Shop', 'Pepsi', 3.00),
('Joe''s Shop', 'Fanta', 2.80);





------------------------------------------------
-- ПРОБЛЕМА: Sally видит MAX < MIN (без транзакций)
------------------------------------------------

-- Joe обновляет цены (без транзакции)
UPDATE Sells SET price = 1.50 WHERE product = 'Coke';  --Coke=1.50
UPDATE Sells SET price = 4.00 WHERE product = 'Pepsi'; --Pepsi=4.00


-- В этот момент Sally читает данные
SELECT MAX(price) as max_price, MIN(price) as min_price FROM Sells WHERE shop = 'Joe''s Shop';
-- Результат: MAX=4.00, MIN=1.50


-- Joe продолжает обновлять (без транзакции)
UPDATE Sells SET price = 5.00 WHERE product = 'Fanta'; --Fanta=5.00


-- Sally снова читает в середине процесса Joe:
SELECT MAX(price) as max_price, MIN(price) as min_price FROM Sells WHERE shop = 'Joe''s Shop';
-- Результат: MAX=5.00, MIN=1.50


-- теперь проблема!
-- Joe откатывает изменения:
UPDATE Sells SET price = 2.50 WHERE product = 'Coke';   -- Вернули Coke=2.50
UPDATE Sells SET price = 3.00 WHERE product = 'Pepsi';  -- Вернули Pepsi=3.00
-- НО Fanta осталась 5.00!


-- Sally читает финальные данные:
SELECT MAX(price) as max_price, MIN(price) as min_price FROM Sells WHERE shop = 'Joe''s Shop';
-- Результат: MAX=5.00, MIN=2.50
-- Но должно быть: MAX=3.00, MIN=2.50
-- Sally видит некорректные данные!










-- Восстанавливаем исходные данные
UPDATE Sells SET price = 2.50 WHERE product = 'Coke';
UPDATE Sells SET price = 3.00 WHERE product = 'Pepsi'; 
UPDATE Sells SET price = 2.80 WHERE product = 'Fanta';


-- Joe работает в транзакции:
BEGIN;
    UPDATE Sells SET price = 1.50 WHERE product = 'Coke';
    UPDATE Sells SET price = 4.00 WHERE product = 'Pepsi';
    UPDATE Sells SET price = 5.00 WHERE product = 'Fanta';
    
    -- Sally пытается прочитать в другом соединении:
    -- SELECT MAX(price), MIN(price) FROM Sells; -- Увидит старые данные!
    
    -- Joe решает откатить изменения:
ROLLBACK; -- все изменения отменяются!


-- Sally читает после отката:
SELECT MAX(price) as max_price, MIN(price) as min_price FROM Sells WHERE shop = 'Joe''s Shop';
-- Результат: MAX=3.00, MIN=2.50 
-- Данные корректные! Sally никогда не видела промежуточных состояний













-- Сценарий, где Sally видит логическую ошибку:


-- Joe начинает изменять цены последовательно:
UPDATE Sells SET price = 1.00 WHERE product = 'Coke';   -- MIN стал 1.00


-- Sally читает MIN:
SELECT MIN(price) FROM Sells WHERE shop = 'Joe''s Shop'; -- Видит 1.00


-- Joe меняет другие товары:
UPDATE Sells SET price = 6.00 WHERE product = 'Pepsi';   -- MAX стал 6.00
UPDATE Sells SET price = 7.00 WHERE product = 'Fanta';   -- MAX стал 7.00


-- Sally читает MAX:
SELECT MAX(price) FROM Sells WHERE shop = 'Joe''s Shop'; -- Видит 7.00


-- Joe откатывает первые изменения:
UPDATE Sells SET price = 2.50 WHERE product = 'Coke';    -- MIN снова 2.50

-- Теперь у Sally в голове: MIN=1.00, MAX=7.00
-- Но в реальности в базе: MIN=2.50, MAX=7.00
-- Sally думает что MIN < MAX (1.00 < 7.00), но это уже неактуально!



