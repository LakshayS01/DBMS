 -- USE CarDealershipDB;
-- 1. Create Car master table
-- CREATE TABLE Car (
--     CarModel      VARCHAR(100) PRIMARY KEY,
--     Brand         VARCHAR(50),
--     StandardPrice DECIMAL(10,2)
-- );
-- -- 2. Insert some models
-- INSERT INTO Car VALUES
-- ('Honda City',  'Honda', 1200000),
-- ('Toyota Corolla','Toyota',1300000),
-- ('Hyundai Creta','Hyundai',1500000),
-- ('Kia Seltos',  'Kia',   1600000),
-- ('Maruti Baleno','Maruti',900000),
-- ('Jeep Compass', 'Jeep', 2000000);

-- -- 3. Add referential integrity to SaleCar_3NF
-- ALTER TABLE SaleCar_3NF
-- ADD CONSTRAINT fk_salecar_car
-- FOREIGN KEY (CarModel) REFERENCES Car(CarModel);
-- SELECT * FROM Car;


-- SELECT * FROM dealer;
-- --  Add new column to Dealer
-- ALTER TABLE Dealer
-- ADD City VARCHAR(50);
--  -- Example of dropping an obsolete table
-- DROP TABLE IF EXISTS Test_Dealer_Backup;
-- SELECT * FROM dealer;


-- -- Insert new customer
-- INSERT INTO Customer VALUES ('C004','Rohan Patel');
-- -- Update
-- UPDATE Customer SET CustomerName='Lakshay Kumar' WHERE CustomerID='C002';
-- -- Delete
-- DELETE FROM Customer WHERE CustomerID='C004';
-- -- OUTPUT
-- SELECT * FROM Customer;


-- SELECT SaleID, CustomerID, DealerID, PaymentMethod
-- FROM Sale_3NF
-- WHERE PaymentMethod = 'Loan'
-- OR PaymentMethod = 'Credit Card';


-- SELECT s.SaleID, c.CustomerName, d.DealerName, s.PaymentMethod
-- FROM Sale_3NF s
-- JOIN Customer c ON s.CustomerID = c.CustomerID
-- JOIN Dealer   d ON s.DealerID   = d.DealerID
-- WHERE d.DealerName = 'AutoWorld'
-- AND s.PaymentMethod <> 'Cash';


-- SELECT s.SaleID,
--        c.CustomerName,
--        d.DealerName,
--        s.PaymentMethod,
--        sc.CarModel
-- FROM Sale_3NF s
-- JOIN Customer     c  ON s.CustomerID = c.CustomerID
-- JOIN Dealer       d  ON s.DealerID   = d.DealerID
-- JOIN SaleCar_3NF  sc ON s.SaleID     = sc.SaleID
-- ORDER BY s.SaleID, sc.CarModel;


-- 1. Customers with at least one sale (IN)
-- SELECT CustomerID, CustomerName
-- FROM Customer
-- WHERE CustomerID IN (
--     SELECT DISTINCT CustomerID
--     FROM Sale_3NF
-- );

-- 2. Customers with no sale (NOT EXISTS)
-- SELECT c.CustomerID, c.CustomerName
-- FROM Customer c
-- WHERE NOT EXISTS (
--     SELECT 1
--     FROM Sale_3NF s
--     WHERE s.CustomerID = c.CustomerID
-- );

-- 3. Dealers with >= 3 distinct models sold (correlated + HAVING)
-- SELECT d.DealerID, d.DealerName
-- FROM Dealer d
-- WHERE EXISTS (
--     SELECT 1
--     FROM Sale_3NF s
--     JOIN SaleCar_3NF sc ON s.SaleID = sc.SaleID
--     WHERE s.DealerID = d.DealerID
--     GROUP BY s.DealerID
--     HAVING COUNT(DISTINCT sc.CarModel) >= 3
-- );


-- DROP VIEW IF EXISTS vw_SaleSummary;
-- -- View for public reporting
-- CREATE VIEW vw_SaleSummary AS
-- SELECT s.SaleID,
--        c.CustomerName,
--        d.DealerName,
--        s.PaymentMethod,
--        sc.CarModel
-- FROM Sale_3NF s
-- JOIN Customer    c  ON s.CustomerID = c.CustomerID
-- JOIN Dealer      d  ON s.DealerID   = d.DealerID
-- JOIN SaleCar_3NF sc ON s.SaleID     = sc.SaleID;

-- select * from vw_SaleSummary;
-- -- DCL: grant to application / receptionist user
-- GRANT SELECT ON vw_SaleSummary TO 'reception_user'@'%';

-- -- If needed later, revoke access
-- REVOKE SELECT ON vw_SaleSummary FROM 'reception_user'@'%';



-- -- UNSAFE (for explanation only, do not use)
-- SET @sql = CONCAT('SELECT * FROM Customer WHERE CustomerName = ''', @userInput, '''');

-- -- SAFE: Prepared statement with parameter
-- PREPARE stmt FROM
--     'SELECT CustomerID, CustomerName
--      FROM Customer
--      WHERE CustomerName = ?';

-- SET @p_name = 'Parth Saini';
-- EXECUTE stmt USING @p_name;
-- DEALLOCATE PREPARE stmt;



-- DELIMITER $$

-- CREATE PROCEDURE GetCustomerTotalAndDiscount (
--     IN  p_CustomerID   VARCHAR(10),
--     OUT p_TotalAmount  DECIMAL(12,2),
--     OUT p_Discounted   DECIMAL(12,2)
-- )
-- BEGIN
-- --     -- Sequential: compute total using joins
--     SELECT IFNULL(SUM(c.StandardPrice),0)
--     INTO p_TotalAmount
--     FROM Sale_3NF s
--     JOIN SaleCar_3NF sc ON s.SaleID = sc.SaleID
--     JOIN Car c          ON sc.CarModel = c.CarModel
--     WHERE s.CustomerID = p_CustomerID;

--     -- Conditional: apply discount for Gold customers
--     IF p_TotalAmount >= 3000000 THEN
--         SET p_Discounted = p_TotalAmount * 0.95;  -- 5% off
--     ELSE
--         SET p_Discounted = p_TotalAmount;
--     END IF;
-- END$$

-- DELIMITER ;

-- -- Example call: 
-- CALL GetCustomerTotalAndDiscount('C003', @total, @final);
-- SELECT @total AS TotalBeforeDiscount, @final AS PayableAmount;



-- helper log table
-- CREATE TABLE AuditLog (
--     LogID      INT AUTO_INCREMENT PRIMARY KEY,
--     Message    VARCHAR(200),
--     LogTime    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- );

-- DELIMITER $$

-- CREATE PROCEDURE GenerateAuditLogs()
-- BEGIN
--     DECLARE i INT DEFAULT 101;

--     audit_loop: LOOP
--         IF i > 105 THEN
--             LEAVE audit_loop;
--         END IF;

--         INSERT INTO AuditLog(Message)
--         VALUES (CONCAT('Audit done for SaleID S', i));

--         SET i = i + 1;
--     END LOOP;
-- END$$

-- DELIMITER ;

-- CALL GenerateAuditLogs();
-- SELECT * FROM AuditLog;



-- DROP PROCEDURE IF EXISTS CountModelsForDealer;
-- DELIMITER $$

-- CREATE PROCEDURE CountModelsForDealer (IN p_DealerID VARCHAR(10))
-- BEGIN
--     -- 1. Declare variables, cursor, handler (ALL declares first)
--     DECLARE v_Model VARCHAR(100);
--     DECLARE done INT DEFAULT 0;

--     DECLARE cur CURSOR FOR
--         SELECT sc.CarModel
--         FROM Sale_3NF s
--         JOIN SaleCar_3NF sc ON s.SaleID = sc.SaleID
--         WHERE s.DealerID = p_DealerID;

--     DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

--     -- 2. Now other statements are allowed
--     DROP TEMPORARY TABLE IF EXISTS DealerModelCount;

--     CREATE TEMPORARY TABLE DealerModelCount (
--         CarModel VARCHAR(100) PRIMARY KEY,
--         Cnt      INT
--     );

--     -- 3. Cursor processing
--     OPEN cur;

--     read_loop: LOOP
--         FETCH cur INTO v_Model;
--         IF done = 1 THEN
--             LEAVE read_loop;
--         END IF;

--         INSERT INTO DealerModelCount (CarModel, Cnt)
--         VALUES (v_Model, 1)
--         ON DUPLICATE KEY UPDATE Cnt = Cnt + 1;
--     END LOOP;

--     CLOSE cur;

--     -- 4. Show result
--     SELECT * FROM DealerModelCount;
-- END$$

-- DELIMITER ;

-- -- Run this call separately after the procedure is created
-- CALL CountModelsForDealer('D01');



-- -- Log table
-- CREATE TABLE SaleCarLog (
--     LogID     INT AUTO_INCREMENT PRIMARY KEY,
--     SaleID    VARCHAR(10),
--     CarModel  VARCHAR(100),
--     LogTime   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- );

-- DELIMITER $$

-- CREATE TRIGGER trg_before_SaleCar_insert
-- BEFORE INSERT ON SaleCar_3NF
-- FOR EACH ROW
-- BEGIN
--     -- Prevent insertion of models not in Car master
--     IF NOT EXISTS (SELECT 1 FROM Car WHERE CarModel = NEW.CarModel) THEN
--         SIGNAL SQLSTATE '45000'
--             SET MESSAGE_TEXT = 'Car model not found in Car master.';
--     END IF;
-- END$$

-- DELIMITER $$

-- CREATE TRIGGER trg_after_SaleCar_insert
-- AFTER INSERT ON SaleCar_3NF
-- FOR EACH ROW
-- BEGIN
--     INSERT INTO SaleCarLog(SaleID, CarModel)
--     VALUES (NEW.SaleID, NEW.CarModel);
-- END$$

-- DELIMITER ;

-- INSERT INTO SaleCar_3NF VALUES ('S103','Honda City');
-- SELECT * FROM SaleCarLog;



-- START TRANSACTION;

-- INSERT INTO Sale_3NF (SaleID, CustomerID, DealerID, PaymentMethod)
-- VALUES ('S200','C001','D01','Cash');

-- INSERT INTO SaleCar_3NF (SaleID, CarModel)
-- VALUES ('S200','Honda City');

-- COMMIT;
-- SELECT * FROM Sale_3NF WHERE SaleID='S200';



-- -- Transaction T1 (clerk A)
-- START TRANSACTION;
-- SELECT * FROM Sale_3NF WHERE SaleID = 'S300' FOR UPDATE;  -- locks this row (or key range)

-- -- if not present, insert:
-- INSERT INTO Sale_3NF (SaleID, CustomerID, DealerID, PaymentMethod)
-- VALUES ('S300','C002','D01','Loan');
-- COMMIT;



-- -- Read-only transaction
-- START TRANSACTION;
-- SELECT * FROM vw_SaleSummary;
-- COMMIT;

-- -- Concurrent write transaction
-- START TRANSACTION;
-- INSERT INTO Sale_3NF VALUES ('S400','C003','D01','Credit Card');
-- INSERT INTO SaleCar_3NF VALUES ('S400','Jeep Compass');
-- COMMIT;



-- -- T1: create a new sale
-- START TRANSACTION;
-- INSERT INTO Sale_3NF (SaleID, CustomerID, DealerID, PaymentMethod)
-- VALUES ('S500','C001','D01','Cash');
-- -- (do NOT commit yet)

-- -- T2: log that sale (depends on T1)
-- START TRANSACTION;
-- INSERT INTO AuditLog(Message)
-- VALUES ('Sale S500 created');
-- -- T2 should wait for T1 to commit before committing itself.
-- COMMIT;   -- only safe if T1 has committed successfully

-- -- If T1 rolls back instead, T2 must also rollback its dependent changes.
-- SELECT * FROM AuditLog;



-- START TRANSACTION;
-- INSERT INTO Sale_3NF (SaleID, CustomerID, DealerID, PaymentMethod)
-- VALUES ('S600','C999','D01','Cash');  -- C999 does NOT exist

-- -- This will fail with a foreign key constraint error.
-- ROLLBACK;




-- -- T1: completed transaction
-- START TRANSACTION;
-- INSERT INTO Sale_3NF VALUES ('S700','C002','D02','Loan');
-- COMMIT;

-- -- T2: incomplete at crash time
-- START TRANSACTION;
-- INSERT INTO Sale_3NF VALUES ('S701','C003','D02','Cash');
-- -- system crashes here before COMMIT




-- SELECT d.DealerID,
--        d.DealerName,
--        COUNT(DISTINCT s.CustomerID) AS NoOfCustomers,
--        COUNT(sc.CarModel)           AS TotalCarsSold
-- FROM Dealer d
-- JOIN Sale_3NF    s  ON d.DealerID = s.DealerID
-- JOIN SaleCar_3NF sc ON s.SaleID   = sc.SaleID
-- GROUP BY d.DealerID, d.DealerName
-- HAVING COUNT(DISTINCT sc.CarModel) >= 2;

