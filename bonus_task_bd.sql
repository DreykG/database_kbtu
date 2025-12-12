-- Схема базы данных банковской системы
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    iin varchar(12) UNIQUE NOT NULL CHECK (LENGTH(iin) = 12 AND iin ~ '^\d{12}$'),
    full_name varchar(50) NOT NULL,
    phone varchar(12) NOT NULL,
    email varchar(70) NOT NULL,
    status varchar(20) NOT NULL CHECK (status IN('active', 'blocked', 'frozen')),
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    daily_limit_kzt numeric(12, 2) DEFAULT 10000000
);

CREATE TABLE accounts (
    account_id SERIAL PRIMARY KEY,
    customer_id int NOT NULL REFERENCES customers(customer_id),
    account_number varchar(20) UNIQUE NOT NULL CHECK (account_number ~ '^KZ\d{18}$'),
    currency varchar(3) NOT NULL CHECK (currency IN('KZT', 'USD', 'EUR', 'RUB')),
    balance numeric(12, 2) DEFAULT 0.00 CHECK (balance >= 0),
    is_active boolean DEFAULT TRUE,
    opened_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    closed_at timestamptz
);

CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    from_account_id int REFERENCES accounts(account_id),
    to_account_id int REFERENCES accounts(account_id),
    amount numeric(12, 2) NOT NULL CHECK (amount > 0),
    currency varchar(3) NOT NULL CHECK (currency IN('KZT', 'USD', 'EUR', 'RUB')),
    exchange_rate numeric(10, 6),
    amount_kzt numeric(12, 2),
    type varchar(20) NOT NULL CHECK (type IN('transfer', 'deposit', 'withdrawal')),
    status varchar(20) NOT NULL CHECK (status IN('pending', 'completed', 'failed', 'reversed')),
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at timestamptz,
    description varchar(300)
);

CREATE TABLE exchange_rates (
    rate_id SERIAL PRIMARY KEY,
    from_currency varchar(3) NOT NULL CHECK (from_currency IN('KZT', 'USD', 'EUR', 'RUB')),
    to_currency varchar(3) NOT NULL CHECK (to_currency IN('KZT', 'USD', 'EUR', 'RUB')),
    rate numeric(10, 6) NOT NULL CHECK (rate > 0),
    valid_from timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_to timestamptz
);

CREATE TABLE audit_logs (
    log_id SERIAL PRIMARY KEY,
    table_name varchar(50) NOT NULL,
    record_id int NOT NULL,
    action varchar(50) NOT NULL CHECK (action IN('INSERT', 'UPDATE', 'DELETE')),
    old_values jsonb,
    new_values jsonb,
    changed_by int NOT NULL,
    changed_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ip_address inet NOT NULL
);

-- Примеры тестовых данных 
INSERT INTO customers (iin, full_name, phone, email, status, daily_limit_kzt) 
VALUES
    ('123456789012', 'Алексей Семенов', '77011223344', 'alex.semenov@bank.kz', 'active', 750000.00),
    ('234567890123', 'Ольга Васильева', '77022334455', 'olga.vasileva@company.com', 'active', 1500000.00),
    ('345678901234', 'Игорь Николаев', '77033445566', 'igor.nikolaev@service.kz', 'blocked', 0.00),
    ('456789012345', 'ТОО "ТехноПром"', '77044556677', 'info@technoprom.kz', 'active', 75000000.00),
    ('567890123456', 'Екатерина Морозова', '77055667788', 'katya.morozova@mail.ru', 'active', 3000000.00),
    ('678901234567', 'Артем Борисов', '77066778899', 'artem.borisov@work.kz', 'frozen', 25000.00),
    ('789012345678', 'Наталья Коваленко', '77077889900', 'natalia.kovalenko@shop.com', 'active', 80000.00),
    ('890123456789', 'ИП "ТоргСервис"', '77088990011', 'contact@torgservice.kz', 'active', 250000.00),
    ('901234567890', 'Виктор Петренко', '77099001122', 'viktor.petrenko@business.kz', 'active', 7500000.00),
    ('012345678901', 'Марина Сидорова', '77100112233', 'marina.sidorova@finance.kz', 'active', 200000.00);

INSERT INTO accounts (customer_id, account_number, currency, balance, is_active) 
VALUES
    (1, 'KZ123456789012345678', 'KZT', 280000.00, TRUE),
    (1, 'KZ234567890123456789', 'USD', 2500.00, FALSE),
    (2, 'KZ345678901234567890', 'KZT', 8500000.00, FALSE),
    (3, 'KZ456789012345678901', 'KZT', 250.00, TRUE),
    (4, 'KZ567890123456789012', 'KZT', 85000000.00, TRUE),
    (8, 'KZ890123456789012345', 'USD', 1200.00, FALSE),
    (5, 'KZ678901234567890123', 'EUR', 3800.00, TRUE),
    (7, 'KZ789012345678901234', 'RUB', 28000.00, TRUE),
    (9, 'KZ901234567890123456', 'KZT', 15000000.00, TRUE),
    (10, 'KZ012345678901234567', 'KZT', 1200.00, TRUE);

INSERT INTO exchange_rates (from_currency, to_currency, rate, valid_from, valid_to) 
VALUES
    ('USD', 'KZT', 480.500, CURRENT_TIMESTAMP, '2026-01-01'),
    ('KZT', 'USD', 0.00208, CURRENT_TIMESTAMP, '2026-01-01'),
    ('EUR', 'KZT', 520.750, CURRENT_TIMESTAMP, '2026-01-01'),
    ('KZT', 'EUR', 0.00192, CURRENT_TIMESTAMP, '2026-01-01'),
    ('RUB', 'KZT', 5.450, CURRENT_TIMESTAMP, '2026-01-01'),
    ('KZT', 'RUB', 0.183, CURRENT_TIMESTAMP, '2026-01-01'),
    ('USD', 'KZT', 470.200, '2024-06-01 09:00:00Z', CURRENT_TIMESTAMP),
    ('KZT', 'KZT', 1.000, CURRENT_TIMESTAMP, '2099-12-31'),
    ('EUR', 'USD', 1.082, CURRENT_TIMESTAMP, '2026-01-01'),
    ('USD', 'RUB', 95.300, CURRENT_TIMESTAMP, '2026-01-01');

INSERT INTO transactions (from_account_id, to_account_id, amount, currency, exchange_rate, amount_kzt, type, status, completed_at, description) 
VALUES
    (1, 4, 65000.00, 'KZT', 1.000, 65000.00, 'transfer', 'completed', CURRENT_TIMESTAMP, 'Оплата образовательных услуг'),
    (2, 1, 75.00, 'USD', 480.500, 36037.50, 'transfer', 'completed', CURRENT_TIMESTAMP, 'Перевод с долларового счета'),
    (6, 3, 150.00, 'EUR', 520.750, 78112.50, 'transfer', 'completed', CURRENT_TIMESTAMP, 'Международный денежный перевод'),
    (9, NULL, 25000.00, 'KZT', 1.000, 25000.00, 'withdrawal', 'completed', CURRENT_TIMESTAMP, 'Снятие в отделении банка'),
    (5, 4, 1500000.00, 'KZT', 1.000, 1500000.00, 'transfer', 'completed', CURRENT_TIMESTAMP, 'Оплата за поставку товаров'),
    (1, 7, 7500.00, 'KZT', 0.183, 7500.00, 'transfer', 'completed', CURRENT_TIMESTAMP, 'Перевод в российских рублях'),
    (9, 10, 2500.00, 'KZT', 1.000, 2500.00, 'transfer', 'completed', CURRENT_TIMESTAMP, 'Тестовый перевод между счетами'),
    (5, 9, 7500000.00, 'KZT', 1.000, 7500000.00, 'transfer', 'completed', CURRENT_TIMESTAMP, 'Крупный корпоративный платеж'),
    (NULL, 1, 45000.00, 'KZT', 1.000, 45000.00, 'deposit', 'completed', CURRENT_TIMESTAMP, 'Внесение через платежный терминал'),
    (7, 1, 2500.00, 'RUB', 5.450, 13625.00, 'transfer', 'completed', CURRENT_TIMESTAMP, 'Возврат денежных средств');


-- Задание 1: Процедура обработки перевода
CREATE PROCEDURE process_transfer(
    from_account_number varchar,
    to_account_number varchar,
    amount numeric(12, 2),
    currency varchar(3),
    description varchar(300),
    p_changed_by int DEFAULT 1,
    p_ip_address inet DEFAULT '192.168.1.5'
)
AS $$
DECLARE
    sender_account RECORD;
    recipient_account RECORD;
    rate_to_sender_currency numeric(10, 6);
    rate_to_kzt numeric(10, 6);
    rate_to_recipient_currency numeric(10, 6);
    debited_amount numeric(12, 2);
    credited_amount numeric(12, 2);
    kzt_equivalent numeric(12, 2);
    todays_total numeric(12, 2);     
    new_transaction_id int;
BEGIN
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

    -- Получаем данные отправителя с блокировкой
    SELECT a.account_id, a.currency, a.balance, c.customer_id, c.status, c.daily_limit_kzt
    INTO sender_account
    FROM accounts a 
    JOIN customers c ON a.customer_id = c.customer_id
    WHERE a.account_number = from_account_number 
      AND a.is_active = TRUE
    FOR UPDATE;
    
    IF NOT FOUND THEN 
        RAISE EXCEPTION 'ACC_001: Счет отправителя не найден или заблокирован.';
    END IF;

    -- Данные получателя
    SELECT a.account_id, a.currency
    INTO recipient_account
    FROM accounts a
    WHERE a.account_number = to_account_number 
      AND a.is_active = TRUE
    FOR UPDATE;
    
    IF NOT FOUND THEN 
        RAISE EXCEPTION 'ACC_002: Счет получателя не существует или не активен.';
    END IF;
    
    IF sender_account.status <> 'active' THEN 
        RAISE EXCEPTION 'CUST_001: Статус клиента-отправителя: %.', sender_account.status; 
    END IF;

    -- Конвертация в KZT для проверки лимита
    kzt_equivalent := amount;
    IF currency <> 'KZT' THEN
        SELECT rate INTO rate_to_kzt
        FROM exchange_rates
        WHERE from_currency = currency 
          AND to_currency = 'KZT' 
          AND valid_from <= CURRENT_TIMESTAMP
        ORDER BY valid_from DESC 
        LIMIT 1;
        
        IF NOT FOUND THEN 
            RAISE EXCEPTION 'RATE_002: Курс конвертации в KZT недоступен.'; 
        END IF;
        kzt_equivalent := amount * rate_to_kzt;
    END IF;

    -- Проверка дневного лимита переводов
    SELECT COALESCE(SUM(amount_kzt), 0.00) INTO todays_total
    FROM transactions
    WHERE from_account_id = sender_account.account_id 
      AND status = 'completed' 
      AND type = 'transfer' 
      AND DATE(created_at) = CURRENT_DATE;

    IF (todays_total + kzt_equivalent) > sender_account.daily_limit_kzt THEN
        RAISE EXCEPTION 'LIMIT_001: Превышен дневной лимит.';
    END IF;
    
    -- Расчет списываемой суммы
    rate_to_sender_currency := 1.0;
    debited_amount := amount;
    IF currency <> sender_account.currency THEN
        SELECT rate INTO rate_to_sender_currency
        FROM exchange_rates
        WHERE from_currency = currency 
          AND to_currency = sender_account.currency 
          AND valid_from <= CURRENT_TIMESTAMP
        ORDER BY valid_from DESC 
        LIMIT 1;
        
        IF NOT FOUND THEN 
            RAISE EXCEPTION 'RATE_001: Не найден курс для конвертации в валюту списания.'; 
        END IF;
        debited_amount := amount * rate_to_sender_currency;
    END IF;

    -- Проверяем баланс
    IF sender_account.balance < debited_amount THEN 
        RAISE EXCEPTION 'BAL_001: Недостаточно средств.'; 
    END IF;
    
    -- Расчет суммы зачисления получателю
    rate_to_recipient_currency := 1.0;
    credited_amount := amount;
    IF currency <> recipient_account.currency THEN
        SELECT rate INTO rate_to_recipient_currency
        FROM exchange_rates
        WHERE from_currency = currency 
          AND to_currency = recipient_account.currency 
          AND valid_from <= CURRENT_TIMESTAMP
        ORDER BY valid_from DESC 
        LIMIT 1;
          
        IF NOT FOUND THEN 
            RAISE EXCEPTION 'RATE_003: Отсутствует курс конвертации для зачисления.'; 
        END IF;
        credited_amount := amount * rate_to_recipient_currency;
    END IF;
    
    -- Создание транзакции
    INSERT INTO transactions (
        from_account_id, to_account_id, amount, currency, 
        exchange_rate, amount_kzt, type, status, 
        description, completed_at
    ) VALUES (
        sender_account.account_id, recipient_account.account_id, 
        amount, currency, rate_to_sender_currency, kzt_equivalent, 
        'transfer', 'completed', description, CURRENT_TIMESTAMP
    ) RETURNING transaction_id INTO new_transaction_id;

    -- Изменение балансов
    UPDATE accounts 
    SET balance = balance - debited_amount 
    WHERE account_id = sender_account.account_id;
    
    UPDATE accounts 
    SET balance = balance + credited_amount 
    WHERE account_id = recipient_account.account_id;

    -- Логирование успеха
    INSERT INTO audit_logs (
        table_name, record_id, action, 
        new_values, changed_by, ip_address
    ) VALUES (
        'transactions', new_transaction_id, 'INSERT', 
        jsonb_build_object(
            'status', 'completed', 
            'amount_debited', debited_amount
        ), p_changed_by, p_ip_address
    );

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        INSERT INTO audit_logs (
            table_name, record_id, action, 
            new_values, changed_by, ip_address
        ) VALUES (
            'transfer_errors', COALESCE(new_transaction_id, 0), 
            'FAILED', 
            jsonb_build_object(
                'stage', 'Full Rollback', 
                'error_msg', SQLERRM
            ), p_changed_by, p_ip_address
        );
        
        ROLLBACK; 
        RAISE; 
END;
$$ LANGUAGE plpgsql;


-- Задание 2: Представления
-- 1. Сводка по клиентам
CREATE VIEW customer_balance_summary AS
SELECT 
    c.customer_id,
    c.full_name,
    COUNT(a.account_id) AS account_count,
    SUM(a.balance * COALESCE(er.rate, 1)) AS total_in_kzt,
    c.daily_limit_kzt,
    COALESCE(
        (
            SELECT SUM(t.amount_kzt)
            FROM accounts sub_a
            JOIN transactions t ON sub_a.account_id = t.from_account_id
            WHERE sub_a.customer_id = c.customer_id
              AND t.created_at::DATE = CURRENT_DATE 
              AND t.type = 'transfer'
              AND t.status = 'completed'
        ), 0
    ) AS used_today,
    (
        COALESCE(
            (
                SELECT SUM(t.amount_kzt)
                FROM accounts sub_a
                JOIN transactions t ON sub_a.account_id = t.from_account_id
                WHERE sub_a.customer_id = c.customer_id
                  AND t.created_at::DATE = CURRENT_DATE 
                  AND t.type = 'transfer'
                  AND t.status = 'completed'
            ), 0
        ) * 100.0 / NULLIF(c.daily_limit_kzt, 0)
    ) AS limit_usage_pct,
    RANK() OVER (ORDER BY SUM(a.balance * COALESCE(er.rate, 1)) DESC) AS wealth_rank
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
LEFT JOIN exchange_rates er 
    ON er.from_currency = a.currency 
    AND er.to_currency = 'KZT' 
    AND er.valid_from <= CURRENT_TIMESTAMP
    AND (er.valid_to IS NULL OR er.valid_to >= CURRENT_TIMESTAMP)
WHERE a.is_active = TRUE
GROUP BY c.customer_id, c.full_name, c.daily_limit_kzt;

-- 2. Ежедневный отчет по операциям
CREATE VIEW daily_transaction_report AS
WITH aggregated_data AS (
    SELECT 
        created_at::DATE AS operation_date,
        type,
        COUNT(*) AS transaction_count,
        SUM(amount_kzt) AS daily_sum,
        AVG(amount_kzt) AS average_amount
    FROM transactions
    WHERE status = 'completed'
    GROUP BY 1, 2
)
SELECT 
    operation_date,
    type,
    transaction_count,
    daily_sum,
    average_amount,
    SUM(daily_sum) OVER (
        PARTITION BY type ORDER BY operation_date
    ) AS cumulative_sum,
    (daily_sum - LAG(daily_sum, 1, 0) OVER (
        PARTITION BY type ORDER BY operation_date
    )) * 100.0 / NULLIF(LAG(daily_sum, 1, 0) OVER (
        PARTITION BY type ORDER BY operation_date
    ), 0) AS day_over_day_pct
FROM aggregated_data
ORDER BY operation_date, type;

-- 3. Подозрительная активность
CREATE VIEW suspicious_activity_view WITH (security_barrier = true) AS
WITH analyzed_transactions AS (
    SELECT 
        t.transaction_id,
        t.from_account_id,
        t.amount_kzt,
        t.created_at,
        (t.created_at - LAG(t.created_at, 1) OVER (
            PARTITION BY t.from_account_id ORDER BY t.created_at
        )) AS prev_transaction_interval,
        COUNT(t.transaction_id) OVER (
            PARTITION BY t.from_account_id, DATE_TRUNC('hour', t.created_at)
        ) AS transactions_per_hour
    FROM transactions t
    WHERE t.status = 'completed' AND t.type = 'transfer'
)
SELECT 
    transaction_id,
    from_account_id,
    created_at,
    CASE WHEN amount_kzt > 5000000 THEN 'Large Amount (>5M KZT)' END AS amount_flag,
    CASE WHEN transactions_per_hour > 10 THEN 'High Frequency (>10/hour)' END AS frequency_flag,
    CASE WHEN prev_transaction_interval < INTERVAL '1 minute' THEN 'Fast Sequential Transfers' END AS speed_flag
FROM analyzed_transactions
WHERE amount_kzt > 5000000
   OR transactions_per_hour > 10
   OR prev_transaction_interval < INTERVAL '1 minute';


-- Задание 3: Индексы
-- Для балансов счетов
CREATE INDEX account_balance_idx ON accounts (balance);

-- Быстрый поиск по валюте
CREATE INDEX account_currency_hash_idx ON accounts USING hash (currency);

-- Для полнотекстового поиска по JSON
CREATE INDEX audit_json_idx ON audit_logs USING GIN (new_values);

-- Только активные счета
CREATE INDEX active_accounts_idx ON accounts (account_number) WHERE is_active = TRUE;

-- Составной индекс для статуса операций
CREATE INDEX transaction_status_idx ON transactions (from_account_id, status);

-- Поиск email без учета регистра
CREATE INDEX customer_email_idx ON customers (LOWER(email));

-- Покрывающий индекс для проверки лимитов
CREATE INDEX transaction_limit_check_idx 
ON transactions (from_account_id, created_at) 
INCLUDE (amount_kzt);


-- Задание 4: Пакетная обработка зарплат
CREATE OR REPLACE PROCEDURE process_salary_batch(
    company_account_number VARCHAR,
    payments_data JSONB,
    p_changed_by INT DEFAULT 1,
    p_ip_address INET DEFAULT '192.168.1.5'
)
AS $$
DECLARE
    company_data RECORD;
    total_payment_sum NUMERIC(12, 2) := 0.00;
    payment_item JSONB;
    employee_iin VARCHAR(12);
    payment_amount NUMERIC(12, 2);
    payment_desc VARCHAR(300);
    success_counter INT := 0;
    error_counter INT := 0;
    error_log JSONB := '[]'::JSONB;
    target_acc_id INT;
    target_curr VARCHAR(3);
    debit_sum NUMERIC(12, 2);
    credit_sum NUMERIC(12, 2);
    conv_rate NUMERIC(10, 6);
    trx_id INT;
    error_msg VARCHAR(300);
    balance_changes JSONB := '{}'::JSONB;
    advisory_lock_id BIGINT;
BEGIN
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    
    advisory_lock_id := ('x' || SUBSTR(MD5(company_account_number), 1, 15))::BIT(64)::BIGINT;

    -- Блокировка для предотвращения параллельной обработки
    IF NOT pg_try_advisory_lock(advisory_lock_id) THEN
        RAISE EXCEPTION 'BATCH_001: Обнаружена параллельная обработка пакета.';
    END IF;
    
    -- Информация о счете компании
    SELECT a.account_id, a.currency, a.balance, c.customer_id
    INTO company_data
    FROM accounts a 
    JOIN customers c ON a.customer_id = c.customer_id
    WHERE a.account_number = company_account_number 
      AND a.is_active = TRUE
    FOR UPDATE;
    
    IF NOT FOUND THEN
        PERFORM pg_advisory_unlock(advisory_lock_id);
        RAISE EXCEPTION 'ACC_001: Счет компании не найден.';
    END IF;
    
    -- Общая сумма выплат
    SELECT COALESCE(SUM((elem->>'amount')::NUMERIC), 0.00)
    INTO total_payment_sum
    FROM jsonb_array_elements(payments_data) AS elem;
    
    -- Достаточно ли средств?
    IF company_data.balance < total_payment_sum THEN
        PERFORM pg_advisory_unlock(advisory_lock_id);
        RAISE EXCEPTION 'BAL_001: Недостаточно средств для выплаты %.', total_payment_sum;
    END IF;
    
    -- Инициализация изменений баланса
    balance_changes := jsonb_set(
        balance_changes, 
        ARRAY[company_data.account_id::TEXT], 
        (-total_payment_sum)::JSONB, 
        TRUE
    );
    
    -- Цикл обработки платежей
    FOR payment_item IN SELECT * FROM jsonb_array_elements(payments_data)
    LOOP
        employee_iin := payment_item->>'iin';
        payment_amount := (payment_item->>'amount')::NUMERIC;
        payment_desc := COALESCE(payment_item->>'description', 'Зарплата');
        error_msg := NULL;
        trx_id := NULL;
        
        EXECUTE 'SAVEPOINT payment_' || success_counter + error_counter;

        BEGIN
            -- Счет сотрудника
            SELECT a.account_id, a.currency
            INTO target_acc_id, target_curr
            FROM accounts a 
            JOIN customers c ON a.customer_id = c.customer_id
            WHERE c.iin = employee_iin 
              AND a.is_active = TRUE
            FOR UPDATE NOWAIT; 
            
            IF NOT FOUND THEN
                error_msg := 'ACC_002: Не найден счет сотрудника с ИИН: ' || employee_iin;
                RAISE EXCEPTION '%', error_msg;
            END IF;

            -- Конвертация валюты
            debit_sum := payment_amount;
            credit_sum := payment_amount;
            conv_rate := 1.0;

            IF company_data.currency <> target_curr THEN
                SELECT rate INTO conv_rate
                FROM exchange_rates
                WHERE from_currency = company_data.currency 
                  AND to_currency = target_curr
                  AND valid_from <= CURRENT_TIMESTAMP 
                  AND (valid_to IS NULL OR valid_to > CURRENT_TIMESTAMP)
                ORDER BY valid_from DESC 
                LIMIT 1;
                
                IF NOT FOUND THEN
                    error_msg := 'RATE_001: Отсутствует курс ' || 
                                company_data.currency || ' → ' || target_curr;
                    RAISE EXCEPTION '%', error_msg;
                END IF;
                credit_sum := payment_amount * conv_rate;
            END IF;
            
            -- Запись транзакции
            INSERT INTO transactions (
                from_account_id, to_account_id, amount, currency, 
                exchange_rate, amount_kzt, type, status, description
            ) VALUES (
                company_data.account_id, target_acc_id, 
                payment_amount, company_data.currency, 
                conv_rate, 
                payment_amount * (
                    SELECT rate 
                    FROM exchange_rates 
                    WHERE from_currency = company_data.currency 
                      AND to_currency = 'KZT' 
                    ORDER BY valid_from DESC 
                    LIMIT 1
                ),
                'transfer', 'pending', payment_desc
            ) RETURNING transaction_id INTO trx_id;
            
            -- Накопление изменений баланса
            balance_changes := jsonb_set(
                balance_changes, 
                ARRAY[target_acc_id::TEXT], 
                credit_sum::JSONB, 
                TRUE
            );

            success_counter := success_counter + 1;
            
            EXECUTE 'RELEASE SAVEPOINT payment_' || success_counter + error_counter - 1;

        EXCEPTION
            WHEN OTHERS THEN
                EXECUTE 'ROLLBACK TO payment_' || success_counter + error_counter;
                
                error_msg := COALESCE(error_msg, SQLERRM);
                
                INSERT INTO audit_logs (
                    table_name, record_id, action, 
                    new_values, changed_by, ip_address
                ) VALUES (
                    'batch_errors', COALESCE(trx_id, 0), 'FAILED', 
                    jsonb_build_object(
                        'iin', employee_iin, 
                        'amount', payment_amount, 
                        'error', error_msg
                    ), p_changed_by, p_ip_address
                );

                error_log := jsonb_insert(
                    error_log, 
                    '{' || error_counter || '}', 
                    jsonb_build_object(
                        'iin', employee_iin, 
                        'amount', payment_amount, 
                        'error', error_msg
                    ), 
                    TRUE
                );
                error_counter := error_counter + 1;
                
                IF trx_id IS NOT NULL THEN
                    UPDATE transactions 
                    SET status = 'failed', 
                        completed_at = CURRENT_TIMESTAMP 
                    WHERE transaction_id = trx_id;
                END IF;
        END;
    END LOOP;

    IF success_counter > 0 THEN
        -- Массовое обновление балансов
        UPDATE accounts AS a
        SET balance = balance + (updates.value::TEXT::NUMERIC)
        FROM jsonb_each_text(balance_changes) AS updates(key, value)
        WHERE a.account_id = updates.key::INT;
        
        -- Завершение успешных транзакций
        UPDATE transactions
        SET status = 'completed', 
            completed_at = CURRENT_TIMESTAMP
        WHERE from_account_id = company_data.account_id
          AND status = 'pending';
    END IF;

    PERFORM pg_advisory_unlock(advisory_lock_id);
    COMMIT;
    
    RAISE NOTICE 'Обработано: успешно — %, с ошибками — %', 
                 success_counter, error_counter;
    RAISE NOTICE 'Ошибки: %', error_log;

EXCEPTION
    WHEN OTHERS THEN
        PERFORM pg_advisory_unlock(advisory_lock_id);
        ROLLBACK; 
        RAISE EXCEPTION 'BATCH_003: Критическая ошибка: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;



-- Тестовые запросы для EXPLAIN ANALYZE 
-- 1. Проверка дневного лимита для другого счета
EXPLAIN ANALYZE 
SELECT COALESCE(SUM(amount_kzt), 0.00) 
FROM transactions 
WHERE from_account_id = 2 
  AND status = 'completed' 
  AND type = 'transfer' 
  AND created_at::DATE = CURRENT_DATE;
-- Aggregate  (cost=1.25..1.26 rows=1 width=32) (actual time=0.015..0.018 rows=1 loops=1)
--    ->  Seq Scan on transactions  (cost=0.00..1.25 rows=1 width=16) (actual time=0.007..0.009 rows=1 loops=1)
--          Filter: ((from_account_id = 2) AND ((status)::text = 'completed'::text) AND ((type)::text = 'transfer'::text) AND ((created_at)::date = CURRENT_DATE))
--          Rows Removed by Filter: 9
--  Planning Time: 0.228 ms
--  Execution Time: 0.045 ms
-- (6 rows)



-- 2. Поиск ошибок в аудит-логах с другим условием
EXPLAIN ANALYZE 
SELECT * 
FROM audit_logs 
WHERE new_values @> '{"status": "completed"}' 
LIMIT 1;
-- Limit  (cost=0.00..6.31 rows=1 width=352) (actual time=0.004..0.006 rows=0 loops=1)
--    ->  Seq Scan on audit_logs  (cost=0.00..12.62 rows=2 width=352) (actual time=0.002..0.002 rows=0 loops=1)
--          Filter: (new_values @> '{"status": "completed"}'::jsonb)
--  Planning Time: 0.105 ms
--  Execution Time: 0.014 ms
-- (5 rows)



-- 3. Поиск активного счета по другому номеру
EXPLAIN ANALYZE 
SELECT account_id 
FROM accounts 
WHERE account_number = 'KZ345678901234567890' 
  AND is_active = TRUE;
--    Seq Scan on accounts  (cost=0.00..1.12 rows=1 width=4) (actual time=0.005..0.007 rows=1 loops=1)
--    Filter: (is_active AND ((account_number)::text = 'KZ345678901234567890'::text))
--    Rows Removed by Filter: 9
--  Planning Time: 0.126 ms
--  Execution Time: 0.015 ms
-- (5 rows)



-- 4. Поиск клиента по email 
EXPLAIN ANALYZE 
SELECT customer_id 
FROM customers 
WHERE LOWER(email) = 'olga.vasileva@company.com';
--  Seq Scan on customers  (cost=0.00..1.15 rows=1 width=4) (actual time=0.010..0.014 rows=1 loops=1)
--    Filter: (lower((email)::text) = 'olga.vasileva@company.com'::text)
--    Rows Removed by Filter: 9
--  Planning Time: 0.082 ms
--  Execution Time: 0.023 ms
-- (5 rows)



-- 5. Поиск транзакций для другого счета
EXPLAIN ANALYZE 
SELECT transaction_id 
FROM transactions 
WHERE from_account_id = 3 
  AND status = 'completed';
--    Seq Scan on transactions  (cost=0.00..1.15 rows=1 width=4) (actual time=0.006..0.006 rows=0 loops=1)
--    Filter: ((from_account_id = 3) AND ((status)::text = 'completed'::text))
--    Rows Removed by Filter: 10
--  Planning Time: 0.032 ms
--  Execution Time: 0.016 ms
-- (5 rows)



-- 6. Дополнительный запрос для проверки составного индекса
EXPLAIN ANALYZE 
SELECT transaction_id, status 
FROM transactions 
WHERE from_account_id = 5 
  AND status IN ('completed', 'failed');
--  Seq Scan on transactions  (cost=0.00..1.15 rows=1 width=62) (actual time=0.006..0.008 rows=2 loops=1)
--    Filter: (((status)::text = ANY ('{completed,failed}'::text[])) AND (from_account_id = 5))
--    Rows Removed by Filter: 8
--  Planning Time: 0.064 ms
--  Execution Time: 0.018 ms
-- (5 rows)



-- 7. Проверка индекса по валюте
EXPLAIN ANALYZE 
SELECT account_id, balance 
FROM accounts 
WHERE currency = 'USD';
--  Seq Scan on accounts  (cost=0.00..1.12 rows=1 width=20) (actual time=0.006..0.009 rows=2 loops=1)
--    Filter: ((currency)::text = 'USD'::text)
--    Rows Removed by Filter: 8
--  Planning Time: 0.035 ms
--  Execution Time: 0.019 ms
-- (5 rows)



-- 8. Проверка partial индекса
EXPLAIN ANALYZE 
SELECT account_number 
FROM accounts 
WHERE is_active = TRUE 
  AND account_number LIKE 'KZ345%';
--  Seq Scan on accounts  (cost=0.00..1.12 rows=1 width=58) (actual time=0.005..0.007 rows=1 loops=1)
--    Filter: (is_active AND ((account_number)::text ~~ 'KZ345%'::text))
--    Rows Removed by Filter: 9
--  Planning Time: 0.083 ms
--  Execution Time: 0.016 ms
-- (5 rows)


-- Тестовые сценарии для процедуры process_transfer:

/*
1.1 Базовый перевод в тенге
    Вызов: CALL process_transfer('KZ123456789012345678', 'KZ345678901234567890', 10000.00, 'KZT', 'Тестовый перевод', 1, '192.168.1.5');
    Цель: Проверка стандартной операции
    Ожидаемый результат: Успех

1.2 Проверка недостаточного баланса
    Баланс счета KZ123456789012345678: 280,000 KZT
    Вызов: CALL process_transfer('KZ123456789012345678', 'KZ345678901234567890', 300000.00, 'KZT', 'Проверка баланса', 1, '192.168.1.5');
    Цель: Проверка ошибки при недостатке средств
    Ожидаемый результат: Ошибка "BAL_001: Недостаточно средств."

1.3 Перевод с конвертацией валюты
    Вызов: CALL process_transfer('KZ234567890123456789', 'KZ123456789012345678', 100.00, 'USD', 'Конвертация валюты', 1, '192.168.1.5');
    Цель: Проверка конвертации USD → KZT
    Ожидаемый результат: Успех с конвертацией

1.4 Перевод на неактивный счет
    Счет KZ890123456789012345 не активен (is_active = FALSE)
    Вызов: CALL process_transfer('KZ123456789012345678', 'KZ890123456789012345', 5000.00, 'KZT', 'На неактивный счет', 1, '192.168.1.5');
    Цель: Проверка валидации активности
    Ожидаемый результат: Ошибка "ACC_002: Счет получателя не существует или не активен."

1.5 Проверка дневного лимита
    Перед тестом: добавить транзакции на 740,000 KZT для счета 1
    Вызов: CALL process_transfer('KZ123456789012345678', 'KZ345678901234567890', 20000.00, 'KZT', 'Превышение лимита', 1, '192.168.1.5');
    Цель: Проверка контроля лимитов
    Ожидаемый результат: Ошибка "LIMIT_001: Превышен дневной лимит."
*/


--Докментация и объяснение
/*
Задача 1: Перевод денег
Логика: Защищенный перевод между счетами
Надежность: Используется максимальный уровень изоляции транзакций, чтобы не было конфликтов при одновременных операциях
Блокировка: Счета блокируются перед операцией, чтобы никто другой не мог их изменить во время перевода
Контроль: Проверяются все условия - активность счетов, статус клиента, достаточно ли денег, не превышен ли дневной лимит
Конвертация: Автоматический расчет курсов валют для списания и зачисления на разные валютные счета

Задача 2: Отчеты и аналитика
Логика: Готовые отчеты для анализа
Клиенты: Сводка по всем клиентам с балансами, количеством счетов и использованием лимитов
Транзакции: Ежедневная статистика по операциям с динамикой роста
Мониторинг: Автоматическое выявление подозрительных операций (большие суммы, частые переводы)

Задача 3: Ускорение работы
Логика: Индексы для быстрого поиска
Для балансов: Обычные индексы для сортировки и поиска по сумме
Для JSON: Специальные индексы для работы с данными в формате JSON
Частичные: Индексы только для активных счетов (меньше размер - быстрее поиск)
Составные: Индексы по нескольким полям для сложных запросов

Задача 4: Массовые выплаты
Логика: Обработка тысяч платежей за раз
Защита от дублей: Блокировка, чтобы одна компания не запускала выплаты дважды одновременно
Устойчивость: Если один платеж не прошел - остальные продолжают обрабатываться
Скорость: Все обновления балансов делаются одним запросом вместо тысяч отдельных
Надежность: Даже при сбое система корректно освобождает все блокировки
*/

