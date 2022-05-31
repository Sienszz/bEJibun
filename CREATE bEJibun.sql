CREATE DATABASE bEJibun

DROP DATABASE bEJibun

USE bEJibun

CREATE TABLE [Customer] (
	CustomerID CHAR (5) PRIMARY KEY CHECK (CustomerID LIKE 'CU[0-9][0-9][0-9]'),
	CustomerName VARCHAR (255) NOT NULL,
	CustomerGender VARCHAR (255) CHECK (CustomerGender LIKE 'Male' OR CustomerGender LIKE 'Female') NOT NULL,
	CustomerPhone VARCHAR (255) NOT NULL,
	CustomerDOB DATE CHECK (CustomerDOB BETWEEN '01-01-1990' AND GETDATE()) NOT NULL,
)

CREATE TABLE [Staff] (
	StaffID CHAR (5) PRIMARY KEY CHECK (StaffID LIKE 'ST[0-9][0-9][0-9]'),
	StaffName VARCHAR (255) NOT NULL,
	StaffGender VARCHAR (255) CHECK (StaffGender LIKE 'Male' OR StaffGender LIKE 'Female') NOT NULL,
	StaffPhone VARCHAR (255) NOT NULL,
	StaffSalary NUMERIC (19, 2) CHECK (StaffSalary > 0) NOT NULL,
)

CREATE TABLE [Vendor] (
	VendorID CHAR (5) PRIMARY KEY CHECK (VendorID LIKE 'VE[0-9][0-9][0-9]'),
	VendorName VARCHAR (255) NOT NULL,
	VendorPhone VARCHAR (255) NOT NULL,
	VendorAddress VARCHAR (255) CHECK (VendorAddress LIKE '% Street') NOT NULL,
	VendorEmail VARCHAR (255) CHECK (VendorEmail NOT LIKE '@%' AND VendorEmail NOT LIKE '%@.com%' AND VendorEmail LIKE '%.com') NOT NULL,
)

CREATE TABLE [SalesTransaction] (
	SalesTransactionID CHAR (5) PRIMARY KEY CHECK (SalesTransactionID LIKE 'SA[0-9][0-9][0-9]'),
	StaffID CHAR (5) FOREIGN KEY REFERENCES Staff (StaffID) ON UPDATE CASCADE ON DELETE CASCADE,
	CustomerID CHAR (5) FOREIGN KEY REFERENCES Customer (CustomerID) ON UPDATE CASCADE ON DELETE CASCADE,
	SalesDate DATE NOT NULL,
)

CREATE TABLE [PurchaseTransaction] (
	PurchaseTransactionID CHAR (5) PRIMARY KEY CHECK (PurchaseTransactionID LIKE 'PH[0-9][0-9][0-9]'),
	StaffID CHAR (5) FOREIGN KEY REFERENCES Staff (StaffID) ON UPDATE CASCADE ON DELETE CASCADE,
	VendorID CHAR (5) FOREIGN KEY REFERENCES Vendor (VendorID) ON UPDATE CASCADE ON DELETE CASCADE,
	PurchaseDate DATE NOT NULL,
	ArrivalDate DATE,
)

CREATE TABLE [ItemType] (
	ItemTypeID CHAR (5) PRIMARY KEY CHECK (ItemTypeID LIKE 'IP[0-9][0-9][0-9]'),
	ItemTypeName VARCHAR (255) CHECK (LEN (ItemTypeName) >= 4) NOT NULL,
)

CREATE TABLE [Item] (
	ItemID CHAR (5) PRIMARY KEY CHECK (ItemID LIKE 'IT[0-9][0-9][0-9]'),
	ItemTypeID CHAR (5) FOREIGN KEY REFERENCES ItemType (ItemTypeID) ON UPDATE CASCADE ON DELETE CASCADE,
	ItemName VARCHAR (255) NOT NULL,
	ItemPrice NUMERIC (19, 2) CHECK (ItemPrice > 0) NOT NULL,
	MinimumQuantity INTEGER NOT NULL,
)

CREATE TABLE [SalesTransactionDetail] (
	SalesTransactionID CHAR (5) FOREIGN KEY REFERENCES SalesTransaction (SalesTransactionID) ON UPDATE CASCADE ON DELETE CASCADE,
	ItemID CHAR (5) FOREIGN KEY REFERENCES Item (ItemID) ON UPDATE CASCADE ON DELETE CASCADE,
	Quantity INTEGER NOT NULL,
	PRIMARY KEY (SalesTransactionID, ItemID),
)

CREATE TABLE [PurchaseTransactionDetail] (
	PurchaseTransactionID CHAR (5) FOREIGN KEY REFERENCES PurchaseTransaction (PurchaseTransactionID) ON UPDATE CASCADE ON DELETE CASCADE,
	ItemID CHAR (5) FOREIGN KEY REFERENCES Item (ItemID) ON UPDATE CASCADE ON DELETE CASCADE,
	Quantity INTEGER NOT NULL,
	PRIMARY KEY (PurchaseTransactionID, ItemID),
)