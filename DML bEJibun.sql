USE bEJibun

--1.
SELECT ItemName, ItemPrice, [Item Total] = SUM (ptd.Quantity) 
FROM Item it JOIN PurchaseTransactionDetail ptd ON it.ItemID = ptd.ItemID JOIN PurchaseTransaction pt ON pt.PurchaseTransactionID = ptd.PurchaseTransactionID
WHERE pt.ArrivalDate IS NULL AND ptd.Quantity>100
GROUP BY it.ItemName, It.ItemPrice, ptd.Quantity
ORDER BY [Item Total] Desc

--2.
SELECT VendorName, [Domain Name] = SUBSTRING (VendorEmail, CHARINDEX ('@', VendorEmail, 0)+1, LEN(VendorEmail)), 
[Average Purchased Item] = AVG (ptd.Quantity)
FROM Vendor v JOIN PurchaseTransaction pt ON v.VendorID = pt.VendorID JOIN PurchaseTransactionDetail ptd ON pt.PurchaseTransactionID = ptd.PurchaseTransactionID
WHERE v.VendorAddress = 'Food Street' AND SUBSTRING (VendorEmail, CHARINDEX ('@', VendorEmail, 0)+1, LEN(VendorEmail)) NOT LIKE 'gmail.com'
GROUP BY v.VendorName, v.VendorEmail, pt.VendorID

--3.
SELECT [Month] = DATENAME(MONTH, st.SalesDate), [Minimum Quantity Sold] = MIN(std.Quantity), [Maximum Quantity Sold] = MAX(std.Quantity)
FROM SalesTransaction st 
JOIN SalesTransactionDetail std ON st.SalesTransactionID = std.SalesTransactionID 
JOIN Item it ON std.ItemID = it.ItemID
JOIN ItemType ity ON it.ItemTypeID = ity.ItemTypeID
WHERE YEAR(SalesDate) = '2019' AND ity.ItemTypeName NOT LIKE 'Food' AND ity.ItemTypeName NOT LIKE 'Drink'
GROUP BY DATENAME(MONTH, st.SalesDate), std.SalesTransactionID

--4.
SELECT [Staff Number] = REPLACE(s.StaffID, 'ST', 'Staff'), s.StaffName, 
[Staff Salary] = CONCAT('Rp. ', s.StaffSalary), [Sales Transaction] = COUNT(*), 
[Average Sales Quantity] = AVG(std.Quantity)
FROM Staff s
JOIN SalesTransaction st ON s.StaffID = st.StaffID
JOIN SalesTransactionDetail std ON st.SalesTransactionID = std.SalesTransactionID
JOIN Customer c ON st.CustomerID = c.CustomerID
WHERE DATENAME(MONTH, st.SalesDate) LIKE 'February' AND c.CustomerGender NOT LIKE s.StaffGender
GROUP BY s.StaffID, s.StaffName, s.StaffSalary

--5.
SELECT [Customer Initial] = CONCAT(LEFT(c.CustomerName, 1), RIGHT(c.CustomerName,1)), 
[Transaction Date] = CONVERT(VARCHAR, st.SalesDate, 107), [Quantity] = SUM(Quantity)
FROM  ( SELECT AVG(a.itemquantity) as avgitemquantity FROM
		(
			SELECT SUM(Quantity) as itemquantity
			FROM SalesTransaction st
			JOIN SalesTransactionDetail std ON st.SalesTransactionID = std.SalesTransactionID
			GROUP BY st.SalesTransactionID
		) as a) b, SalesTransaction st
JOIN SalesTransactionDetail std ON st.SalesTransactionID = std.SalesTransactionID
JOIN Customer c ON st.CustomerID = c.CustomerID
WHERE c.CustomerGender = 'Female'
GROUP BY CustomerName, SalesDate, b.avgitemquantity
HAVING SUM(Quantity) > b.avgitemquantity

--6.
SELECT [ID] = LOWER(v.VendorID), v.VendorName, [Phone Number] = STUFF(v.VendorPhone, 1, 1, '+62')
FROM (
       SELECT MIN(Quantity) as itemquantity
       FROM PurchaseTransaction pt
       JOIN PurchaseTransactionDetail ptd ON pt.PurchaseTransactionID = ptd.PurchaseTransactionID   
) b, PurchaseTransaction pt
JOIN Vendor v ON pt.VendorID = v.VendorID
JOIN PurchaseTransactionDetail ptd ON pt.PurchaseTransactionID = ptd.PurchaseTransactionID
WHERE CONVERT(INT, SUBSTRING(ptd.ItemID, 3, 5))%2 != 0
GROUP BY v.VendorID, v.VendorName, v.VendorPhone, b.itemquantity
HAVING SUM(Quantity) > b.itemquantity

--7.
SELECT StaffName, VendorName, pt.PurchaseTransactionID, [Total Purchase Quantity] = SUM(Quantity),
[Ordered Day] = CONCAT(DATEDIFF(day, pt.PurchaseDate, GETDATE()), ' Days ago')
FROM (
    SELECT MAX(itemquantity) as avgitemquantity FROM(
        SELECT SUM(Quantity) as itemquantity
        FROM PurchaseTransaction pt
        JOIN PurchaseTransactionDetail ptd ON pt.PurchaseTransactionID = ptd.PurchaseTransactionID
        WHERE DATEDIFF(day, PurchaseDate, ArrivalDate) < 7
        GROUP BY pt.PurchaseTransactionID
    ) AS a
)b , PurchaseTransaction pt
JOIN PurchaseTransactionDetail ptd ON pt.PurchaseTransactionID = ptd.PurchaseTransactionID
JOIN Vendor v ON pt.VendorID = v.VendorID
JOIN Staff s ON pt.StaffID = s.StaffID
GROUP BY StaffName, VendorName, pt.PurchaseTransactionID, pt.PurchaseDate, b.avgitemquantity
HAVING SUM(Quantity) > b.avgitemquantity

--8.
SELECT TOP 2 [Day] = DATENAME(WEEKDAY, st.SalesDate), [Item Sales Amount] = COUNT(std.Quantity) 
FROM SalesTransaction st JOIN SalesTransactionDetail std on st.SalesTransactionID = std.SalesTransactionID
JOIN Item it ON std.ItemID = it.ItemID, (
	SELECT [Average] = AVG(it.ItemPrice)
	FROM Item it JOIN ItemType ity ON it.ItemTypeID = ity.ItemTypeID
	WHERE ity.ItemTypeName IN ('Electronic', 'Gadgets')
) AS Average
WHERE it.ItemPrice < Average.Average
GROUP BY st.SalesDate, std.SalesTransactionID

--9.
GO
CREATE VIEW [Customer Statistic by Gender] AS
SELECT cu.CustomerGender, 
    [Maximum Sales] = (
	SELECT MAX(itemquantity) 
    FROM(
    SELECT SUM(Quantity) as itemquantity
    FROM SalesTransaction st
    JOIN SalesTransactionDetail std ON st.SalesTransactionID = std.SalesTransactionID
    JOIN Customer c ON st.CustomerID = c.CustomerID
    WHERE std.Quantity BETWEEN 10 AND 50 AND c.CustomerGender = cu.CustomerGender
    GROUP BY st.SalesTransactionID
) as a), 
    [Minimum Sales] = (
	SELECT MIN(itemquantity) FROM(
    SELECT SUM(Quantity) as itemquantity
    FROM SalesTransaction st
    JOIN SalesTransactionDetail std ON st.SalesTransactionID = std.SalesTransactionID
    JOIN Customer c ON st.CustomerID = c.CustomerID
    WHERE std.Quantity BETWEEN 10 AND 50 AND c.CustomerGender = cu.CustomerGender
    GROUP BY st.SalesTransactionID
) as a)
FROM Customer cu
GROUP BY cu.CustomerGender

SELECT * FROM [Customer Statistic by Gender]
DROP VIEW [Customer Statistic by Gender]
    
--10.
GO
CREATE VIEW [Item Type Statistic] AS
SELECT [Item Type] = UPPER(ItemTypeName), [Average Price] = CONVERT(NUMERIC(15,2),AVG(ItemPrice),1), [Number Of Item Variety] = COUNT(i.ItemTypeID)
FROM ItemType it
JOIN Item i on it.ItemTypeID = i.ItemTypeID
WHERE it.ItemTypeName LIKE 'F%' AND i.MinimumQuantity > 5
GROUP BY i.ItemTypeID, ItemTypeName

SELECT * FROM [Item Type Statistic]
DROP VIEW [Item Type Statistic]