-- DML Simulation with Purchases and Sales
USE bEJibun

-- Suatu hari, seorang vendor yang datang Nakirium Street bernama Subaru Oozora mengantar re-stocking barang untuk toko bEJibun.
-- Disana, sedang menjalankan shiftnya, Subaru bertemu Elpis, salah satu staff di toko tersebut.
-- Subaru menyampaikan bagaimana ia membawa makanan (Food), berupa Siesta Ciken Naged sebanyak 3 kotak.
-- Dimana per kotaknya terdapat 40 bungkus.
-- 5 kotak minuman (Drink), berupa Ultramen Milk.
-- Dimana per kotaknya terdapat 12 buah.
-- Terakhir ia mengeluarkan stock roti (Bread), terdapat 10 kotak disitu.
-- Dimana per plastiknya terdapat 10 plastik.
-- Stock makanan tersebut telah dipesan oleh toko pada akhir tahun 2020 (27 Desember 2020).
-- Dan sampai di hari itu pada awal tahun 2021 (3 Januari 2021).
INSERT INTO PurchaseTransaction VALUES('PH025', 'ST002', 'VE005', '12-27-2020','01-03-2021')
INSERT INTO PurchaseTransactionDetail VALUES('PH025','IT002','120')
INSERT INTO PurchaseTransactionDetail VALUES('PH025','IT006','60')
INSERT INTO PurchaseTransactionDetail VALUES('PH025','IT009','100')
SELECT  [Purchase Date] = pt.PurchaseDate, [Arrival Date] = pt.ArrivalDate,
[Vendor Name] = v.VendorName, [Staff Name] = s.StaffName,
[Vendor Dropped Items] = i.ItemName, [Dropped Quantity] = ptd.Quantity
FROM Staff s JOIN PurchaseTransaction pt
ON s.StaffID = pt.StaffID JOIN Vendor v
ON pt.VendorID = v.VendorID JOIN PurchaseTransactionDetail ptd
ON pt.PurchaseTransactionID = ptd.PurchaseTransactionID JOIN Item i
ON ptd.ItemID = i.ItemID
WHERE pt.ArrivalDate = '01-03-2021'

-- 2 hari setelah kedatangan stock, datanglah pelanggan bernama Peter Mazuryk yang ingin membeli makanan untuk temannya.
-- Disaat yang sama ia membutuhkan roti dan susu untuk menu sarapan sehari-harinya.
-- Maka dari situ ia mengambil barang-barang yang dibutuhkannya diatas kuantitas minimal toko.
-- Saat membawanya ke kasir, ia bertemu Eshbon sebagai pelayannya di hari itu.
INSERT INTO SalesTransaction VALUES('SA025', 'ST001', 'CU005', '01-05-2021')
INSERT INTO SalesTransactionDetail VALUES ('SA025', 'IT002', '5')
INSERT INTO SalesTransactionDetail VALUES ('SA025', 'IT006', '15')
INSERT INTO SalesTransactionDetail VALUES ('SA025', 'IT009', '15')
SELECT  [Sales Date] = st.SalesDate, [Customer Name] = c.CustomerName,
[Staff Name] = s.StaffName, [Customer Bought Items] = i.ItemName,
[Bought Item Quantity] = std.Quantity
FROM Staff s JOIN SalesTransaction st
ON s.StaffID = st.StaffID JOIN Customer c
ON st.CustomerID = c.CustomerID JOIN SalesTransactionDetail std
ON st.SalesTransactionID = std.SalesTransactionID JOIN Item i
ON std.ItemID = i.ItemID
WHERE st.SalesDate = '01-05-2021'