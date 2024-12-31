CREATE DATABASE Project;
USE Project; 

CREATE TABLE CreditCardHolders (
    cardholder_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    address TEXT,
    card_number VARCHAR(16) UNIQUE,
    expiry_date DATE,
    cvv VARCHAR(4),
    bank_name VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Step 2: Create the Transactions Table
CREATE TABLE Transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    card_id INT,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    transaction_type ENUM('Purchase', 'Payment', 'Refund'),
    amount DECIMAL(10, 2),
    merchant_name VARCHAR(100),
    description TEXT,
    FOREIGN KEY (card_id) REFERENCES CreditCardHolders(cardholder_id) ON DELETE CASCADE
);

-- Step 3: Create the LoginRecords Table
CREATE TABLE LoginRecords (
    login_id INT AUTO_INCREMENT PRIMARY KEY,
    cardholder_id INT,
    login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45),
    FOREIGN KEY (cardholder_id) REFERENCES CreditCardHolders(cardholder_id) ON DELETE CASCADE
);

-- Step 4: Insert Sample Data into CreditCardHolders
INSERT INTO CreditCardHolders (name, address, card_number, expiry_date, cvv, bank_name) 
VALUES 
('Suyog Sapkota', 'Kushadevi', '1234567812345678', '2026-12-31', '123', 'Nabil Bank'),
('Saurav Bhujel', 'Budol', '8765432187654321', '2025-06-30', '456', 'Bank of Kathmandu'),
('Mohan Shrestha', 'Khadpu', '1357913579135791', '2024-09-15', '789', 'Global IME');

-- Step 5: Insert Sample Data into Transactions
INSERT INTO Transactions (card_id, transaction_type, amount, merchant_name, description) 
VALUES 
(1, 'Purchase', 150.75, 'Daraz', 'Electronics Purchase'),
(2, 'Payment', 300.00, 'Bank of Kathmandu', 'Credit Card Payment'),
(1, 'Refund', 50.00, 'Oliz', 'Refund for Electronics');

-- Step 6: Insert Sample Data into LoginRecords
INSERT INTO LoginRecords (cardholder_id, login_time, ip_address) 
VALUES 
(1, NOW(), '192.168.1.1'),
(2, NOW(), '192.168.1.2'),
(3, NOW(), '192.168.1.3');

-- to represent the data type
desc CreditCardHolders;
desc Transactions;
desc LoginRegister;

-- Step 7: Query Examples

-- Fetch all cardholder details
SELECT * FROM CreditCardHolders;
Select *from Transactions;
Select *from LoginRecords;

-- Projection on  CreditCardHolders,Transactions and LoginRegisters
Select name, address,cvv
from CreditCardHolders;

Select transaction_id,transaction_date, transaction_type 
from Transactions;

Select login_id, login_time
from LoginRecords;

-- Cartesian Product
SELECT name, NULL AS amount 
FROM CreditCardHolders
UNION
SELECT c.name, t.amount 
FROM Transactions t
JOIN CreditCardHolders c ON t.card_id = c.cardholder_id;

-- Inner Join 
SELECT 
    CreditCardHolders.name AS cardholder_name,
    Transactions.transaction_type,
    Transactions.amount,
    Transactions.merchant_name,
    Transactions.transaction_date,
    LoginRecords.login_time,
    LoginRecords.ip_address
FROM 
    CreditCardHolders
INNER JOIN 
    Transactions ON CreditCardHolders.cardholder_id = Transactions.card_id
INNER JOIN 
    LoginRecords ON CreditCardHolders.cardholder_id = LoginRecords.cardholder_id;
    
-- Left Join 
SELECT 
    CreditCardHolders.name AS cardholder_name,
    Transactions.transaction_type,
    Transactions.amount,
    Transactions.merchant_name,
    Transactions.transaction_date,
    LoginRecords.login_time,
    LoginRecords.ip_address
FROM 
    CreditCardHolders
LEFT JOIN 
    Transactions ON CreditCardHolders.cardholder_id = Transactions.card_id
LEFT JOIN 
    LoginRecords ON CreditCardHolders.cardholder_id = LoginRecords.cardholder_id;

-- Right Join
SELECT 
    CreditCardHolders.name AS cardholder_name,
    Transactions.transaction_type,
    Transactions.amount,
    Transactions.merchant_name,
    Transactions.transaction_date
FROM 
    CreditCardHolders
RIGHT JOIN 
    Transactions ON CreditCardHolders.cardholder_id = Transactions.card_id;






-- Check credit cards expiring within the next 6 months
SELECT name, card_number, expiry_date 
FROM CreditCardHolders 
WHERE expiry_date <= DATE_ADD(CURDATE(), INTERVAL 6 MONTH);

-- Search by credit card number
SELECT * 
FROM CreditCardHolders 
WHERE card_number = '1234567812345678';

-- Fetch all transactions for a specific cardholder
SELECT c.name AS cardholder_name, t.transaction_type, t.amount, t.merchant_name, t.description, t.transaction_date
FROM Transactions t
JOIN CreditCardHolders c ON t.card_id = c.cardholder_id
WHERE c.name = 'Alice Brown';

SELECT 
    CreditCardHolders.name AS cardholder_name,
    Transactions.transaction_type,
    Transactions.amount,
    Transactions.merchant_name,
    Transactions.transaction_date
FROM 
    CreditCardHolders
RIGHT JOIN 
    Transactions ON CreditCardHolders.cardholder_id = Transactions.card_id;

START TRANSACTION;

-- Insert a valid user
INSERT INTO Users (name, email) VALUES ('Alice', 'alice@example.com');

-- Insert a credit card for the user
INSERT INTO CreditCards (user_id, card_number, card_type, expiry_date, balance, credit_limit, cvv) 
VALUES (1, '1234567812345678', 'VISA', '2025-12-31', 500.00, 1000.00, '123');

-- Simulate an error: Invalid foreign key for Transactions
INSERT INTO Transactions (card_id, transaction_date, amount, description) 
VALUES (999, '2024-12-30', 100.00, 'Purchase');

ROLLBACK; -- Revert all changes

Select *  from CreditCardHolders ;
Select *  from Transactions ;
Select *  from LoginRecords ;


DELIMITER $$

CREATE DEFINER = 'root'@'localhost' PROCEDURE `transaction_success`()
BEGIN
    START TRANSACTION;

    -- Update the first record
    UPDATE CreditCardHolders
    SET bank_name = 'Suya Darshan Bank'
    WHERE cvv = 456;

    -- Update the second record
    UPDATE CreditCardHolders
    SET bank_name = 'Global IME'
    WHERE cvv = 123;

    COMMIT;
END$$

DELIMITER ;
DELIMITER $$

SELECT * from CreditCardHolders;
CREATE DEFINER=`root`@`localhost` PROCEDURE `transaction_with_error_handling`()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Transaction failed, rollback executed' AS message;
    END;

    START TRANSACTION;
    UPDATE CreditCardHolders SET bank_name = "Laxmi Sunrise Bank" WHERE name = 'Suyog Sapkota';
    UPDATE CreditCardHolders SET bank_name = "JP Morgan Chase" WHERE name = 'Saurav Bhujel';
    COMMIT;
END;
DELIMITER ;

