-- CREATE DATABASE CarDealershipDB;
use CarDealershipDB;
-- CREATE TABLE Sale_UNF (
--     SaleID VARCHAR(10) PRIMARY KEY,
--     CustomerName VARCHAR(100),
--     DealerName VARCHAR(100),
--     CarModels VARCHAR(255),       -- repeating group, e.g. {Honda City, Toyota Corolla}
--     PaymentMethod VARCHAR(50)
-- );

-- -- Example insert
-- INSERT INTO Sale_UNF VALUES
-- ('S101', 'Parth Saini', 'AutoWorld', 'Honda City, Toyota Corolla', 'Cash'),
-- ('S102', 'Lakshay Saini', 'CarHub', 'Hyundai Creta', 'Credit Card'),
-- ('S103', 'Vikram Joshi', 'AutoWorld', 'Kia Seltos, Maruti Baleno, Jeep Compass', 'Loan');

-- SELECT * FROM Sale_UNF;

-- CREATE TABLE Sale_1NF (
--     SaleID VARCHAR(10),
--     CustomerName VARCHAR(100),
--     DealerName VARCHAR(100),
--     CarModel VARCHAR(100),   -- single value only
--     PaymentMethod VARCHAR(50),
--     PRIMARY KEY (SaleID, CarModel)
-- );

-- -- Insert normalized data
-- INSERT INTO Sale_1NF VALUES
-- ('S101', 'Parth Saini', 'AutoWorld', 'Honda City', 'Cash'),
-- ('S101', 'Parth Saini', 'AutoWorld', 'Toyota Corolla', 'Cash'),
-- ('S102', 'Lakshay Saini', 'CarHub', 'Hyundai Creta', 'Credit Card'),
-- ('S103', 'Vikram Joshi', 'AutoWorld', 'Kia Seltos', 'Loan'),
-- ('S103', 'Vikram Joshi', 'AutoWorld', 'Maruti Baleno', 'Loan'),
-- ('S103', 'Vikram Joshi', 'AutoWorld', 'Jeep Compass', 'Loan');

-- SELECT * FROM Sale_1NF;


-- Sale table
-- CREATE TABLE Sale_2NF (
--     SaleID VARCHAR(10) PRIMARY KEY,
--     CustomerName VARCHAR(100),
--     DealerName VARCHAR(100),
--     PaymentMethod VARCHAR(50)
-- );

-- Car details per sale
-- CREATE TABLE SaleCar_2NF (
--     SaleID VARCHAR(10),
--     CarModel VARCHAR(100),
--     PRIMARY KEY (SaleID, CarModel),
--     FOREIGN KEY (SaleID) REFERENCES Sale_2NF(SaleID)
-- );

-- Insert Sale data
-- INSERT INTO Sale_2NF VALUES
-- ('S101', 'Parth Saini', 'AutoWorld', 'Cash'),
-- ('S102', 'Lakshay Saini', 'CarHub', 'Credit Card'),
-- ('S103', 'Vikram Joshi', 'AutoWorld', 'Loan');

-- Insert Car data
-- INSERT INTO SaleCar_2NF VALUES
-- ('S101', 'Honda City'),
-- ('S101', 'Toyota Corolla'),
-- ('S102', 'Hyundai Creta'),
-- ('S103', 'Kia Seltos'),
-- ('S103', 'Maruti Baleno'),
-- ('S103', 'Jeep Compass');

 -- SELECT * FROM Sale_2NF;
--  SELECT * FROM SaleCar_2NF;


-- Customer table
-- CREATE TABLE Customer (
--     CustomerID VARCHAR(10) PRIMARY KEY,
--     CustomerName VARCHAR(100)
-- );

-- -- Dealer table
-- CREATE TABLE Dealer (
--     DealerID VARCHAR(10) PRIMARY KEY,
--     DealerName VARCHAR(100)
-- );

-- -- Sale table (normalized)
-- CREATE TABLE Sale_3NF (
--     SaleID VARCHAR(10) PRIMARY KEY,
--     CustomerID VARCHAR(10),
--     DealerID VARCHAR(10),
--     PaymentMethod VARCHAR(50),
--     FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
--     FOREIGN KEY (DealerID) REFERENCES Dealer(DealerID)
-- );

-- -- SaleCar table
-- CREATE TABLE SaleCar_3NF (
--     SaleID VARCHAR(10),
--     CarModel VARCHAR(100),
--     PRIMARY KEY (SaleID, CarModel),
--     FOREIGN KEY (SaleID) REFERENCES Sale_3NF(SaleID)
-- );

-- -- Insert customers
-- INSERT INTO Customer VALUES
-- ('C001', 'Parth Saini'),
-- ('C002', 'Lakshay Saini'),
-- ('C003', 'Vikram Joshi');

-- -- Insert dealers
-- INSERT INTO Dealer VALUES
-- ('D01', 'AutoWorld'),
-- ('D02', 'CarHub');

-- -- Insert sales
-- INSERT INTO Sale_3NF VALUES
-- ('S101', 'C001', 'D01', 'Cash'),
-- ('S102', 'C002', 'D02', 'Credit Card'),
-- ('S103', 'C003', 'D01', 'Loan');

-- -- Insert car models per sale
-- INSERT INTO SaleCar_3NF VALUES
-- ('S101', 'Honda City'),
-- ('S101', 'Toyota Corolla'),
-- ('S102', 'Hyundai Creta'),
-- ('S103', 'Kia Seltos'),
-- ('S103', 'Maruti Baleno'),
-- ('S103', 'Jeep Compass');

SELECT * FROM Customer;
SELECT * FROM Dealer;
SELECT * FROM Sale_3NF;
SELECT * FROM SaleCar_3NF;
