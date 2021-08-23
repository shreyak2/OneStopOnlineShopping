---------------------------------------------TEAM 11 DATABASE IMPLEMENTATION -------------------------------------

USE Team11
GO
-------------------------------------------------1.Table Customer ------------------------------------------------

CREATE TABLE Customer (
  Customer_ID INT IDENTITY NOT NULL PRIMARY KEY,
  First_Name VARCHAR(20) NOT NULL,
  Middle_Name VARCHAR(20),
  Last_Name VARCHAR(20) NOT NULL,
  Mobile NVARCHAR(20) NOT NULL,
  EmailID NVARCHAR(50) NOT NULL,
  PasswordHash VARCHAR(128) NOT NULL,
  RegisteredAt DATETIME,
  LastLogin DATETIME,
  Profile VARCHAR(20));

--------------------------------------------------2. Table Address -------------------------------------------------

CREATE TABLE Address (
Address_ID INT IDENTITY NOT NULL PRIMARY KEY,
Customer_ID INT NOT NULL REFERENCES Customer(Customer_ID),
Address_Type varchar(100) NOT NULL,
Street varchar(100) NOT NULL,
City varchar(20) NOT NULL,
State varchar(20) NOT NULL,
Zipcode INT NOT NULL
);

 ------------------------------------------------- 3. Table User_Session ----------------------------------------------

CREATE TABLE [User_Session] (
  [Session_ID] int not null Identity,
  [Customer_ID] int,
  [Login_time] datetime DEFAULT Current_Timestamp NOT NULL,
  PRIMARY KEY ([Session_ID]),
  CONSTRAINT [FK_User_Session.Customer_ID]
  FOREIGN KEY ([Customer_ID])
  REFERENCES [Customer]([Customer_ID])
);

----------------------------------------------------4. Table ShoppingCart ---------------------------------------------

CREATE TABLE ShoppingCart (
  Cart_ID INT IDENTITY NOT NULL PRIMARY KEY,
  Customer_ID INT NOT NULL REFERENCES dbo.Customer(Customer_ID),
); 

 ---------------------------------------------------5. Table ShoppingCartItem ---------------------------------------------

CREATE TABLE  ShoppingCartItem (
   CartItem_ID INT IDENTITY NOT NULL PRIMARY KEY,
   Cart_ID INT NOT NULL REFERENCES dbo.ShoppingCart(Cart_ID),
   Product_ID INT NOT NULL REFERENCES dbo.Product(Product_ID),
   Quantity  INT NOT NULL,
   Timestamp_added DATETIME DEFAULT CURRENT_TIMESTAMP);

----------------------------------------------------6. Table CardDetails--------------------------------------------------

CREATE TABLE [CardDetails] (
  [Card_ID] int Identity,
  [Customer_ID] int,
  [Card_Type] varchar(20),
  [Card_Number] int,
  [CardHolder_Name] varchar(20),
  [Expire_Date] date,
  [CVV] int,
  PRIMARY KEY ([Card_ID]),
  CONSTRAINT [FK_CardDetails.Customer_ID]
  FOREIGN KEY ([Customer_ID])
  REFERENCES [Customer]([Customer_ID])
);


--------------------------------------------------7. Table Transaction ------------------------------------------------

CREATE TABLE [Transactions] (
  [Transaction_ID] INT IDENTITY NOT NULL PRIMARY KEY,
  [Order_ID] INT NOT NULL REFERENCES dbo.[Order](Order_ID),
  [Payment_ID] INT NOT NULL REFERENCES dbo.Payment(Payment_ID),
  [Created_at] DATETIME,
  [Updated_at] DATETIME,
  [Status] VARCHAR(20));



----------------------------------------------------8. Table Payment ----------------------------------------------------

CREATE TABLE Payment (
Payment_ID INT IDENTITY NOT NULL PRIMARY KEY,
Card_ID INT NOT NULL REFERENCES CardDetails(Card_ID),
Amount money NOT NULL,
Timestamp datetime DEFAULT Current_Timestamp NOT NULL			
);


---------------------------------------------------9. Table Invoice ---------------------------------------------------

CREATE TABLE Invoice (
Invoice_ID INT IDENTITY NOT NULL PRIMARY KEY,
Payment_ID INT NOT NULL REFERENCES Payment(Payment_ID),	
Invoice_Date datetime DEFAULT Current_Timestamp NOT NULL,			
Invoice_details varchar(250) NOT NULL
);


---------------------------------------------------10. Table Product ---------------------------------------------------

CREATE TABLE Product (
  Product_ID INT IDENTITY NOT NULL PRIMARY KEY,
  Category_ID INT NOT NULL REFERENCES dbo.Category(Category_ID) ,
  Brand_ID INT NOT NULL REFERENCES dbo.Brand(Brand_ID),
  Seller_ID INT NOT NULL REFERENCES dbo.Seller(Seller_ID),
  Product_Name VARCHAR(20) NOT NULL,
  Quantity INT NOT NULL,
  Price MONEY NOT NULL,
  Product_Summary VARCHAR(100),
  Product_CreatedAt DATETIME,
  Product_UpdatedAt DATETIME
); 


------------------------------------------------------11. Table Seller ---------------------------------------------------

CREATE TABLE Seller (
Seller_ID INT Identity NOT NULL Primary Key ,
Seller_Name  VARCHAR(60),
Seller_Location VARCHAR(250));


-----------------------------------------------------12. Table Brand ---------------------------------------------------

CREATE TABLE Brand (
  Brand_ID INT IDENTITY NOT NULL PRIMARY KEY,
  Brand_Name VARCHAR(20) NOT NULL
);

 ---------------------------------------------------13. Table Category --------------------------------------------------

 CREATE TABLE [Category] (
  [Category_ID] INT IDENTITY NOT NULL PRIMARY KEY,
  [Category_Name] VARCHAR(50) NOT NULL,
  [Category_Desc] VARCHAR(100)
);

-----------------------------------------------------14. Table Review -----------------------------------------------------

CREATE TABLE Review (
Review_ID INT IDENTITY NOT NULL PRIMARY KEY,
Product_ID INT NOT NULL REFERENCES Product(ProductID),
Customer_ID INT NOT NULL REFERENCES Customer(CustomerID),
Posted_at datetime DEFAULT Current_Timestamp NOT NULL,
Modified_at datetime DEFAULT Current_Timestamp NOT NULL,
Rating INT NOT NULL,					
Review_Comment varchar(250) NOT NULL
);


--------------------------------------------------------15. Table Order -------------------------------------------------

 CREATE TABLE [Order] (
   Order_ID INT IDENTITY NOT NULL PRIMARY KEY,
   Customer_ID INT NOT NULL REFERENCES dbo.Customer(Customer_ID) ,
   Discount_ID INT NOT NULL REFERENCES dbo.Discount(Discount_ID),
   Territory_ID INT NOT NULL REFERENCES dbo.Territory(Territory_ID),
   Status VARCHAR(15),
   TotalPrice Money NOT NULL,
   Tax  Money NOT NULL,
   Shipping_Charges Money NOT NULL,
   Created_At  DATETIME DEFAULT CURRENT_TIMESTAMP,
   Updated_At DATETIME DEFAULT CURRENT_TIMESTAMP,
   PickUp  VARCHAR(20);
   Select * from [Order];
   Select * from OrderItem

 -----------------------------------------------------16. Table OrderItem  --------------------------------------------

  CREATE TABLE [OrderItem] (
   OrderItem_ID INT IDENTITY NOT NULL PRIMARY KEY,
   Order_ID INT NOT NULL REFERENCES [dbo].[Order](Order_ID),
   Product_ID INT NOT NULL REFERENCES dbo.Product(Product_ID),
   Quantity INT NOT NULL,
    );

------------------------------------------------------17. Table Territory----------------------------------------------

   CREATE TABLE [Territory] (
  [Territory_ID] INT IDENTITY NOT NULL PRIMARY KEY,
  [Product_ID] INT NOT NULL REFERENCES dbo.Product(Product_ID),
  [Territoy_Name] VARCHAR(50) NOT NULL,
  [Territory_Desc] VARCHAR(100)
);

-------------------------------------------------------18. Table Discount -------------------------------------------

CREATE TABLE [Discount] (
  [Discount_ID] INT IDENTITY NOT NULL PRIMARY KEY,
  [Discount_Name] VARCHAR(50) NOT NULL,
  [Discount_Percentage] NVARCHAR NOT NULL, );

 
 ------------------------------------------------------19. Table ReturnOrderItem ------------------------------------

 CREATE TABLE [ReturnOrderItem] (
  [Return_ID] int not null Identity,
  [OrderItem_ID] int not null REFERENCES OrderItem(OrderItem_ID),
  [Return_Timestamp] datetime DEFAULT Current_Timestamp NOT NULL,
  PRIMARY KEY ([Return_ID])
);

-------------------------------------------------------20. Table Shipment ---------------------------------------------

CREATE TABLE [Shipment] (
  [Shipment_ID] INT IDENTITY NOT NULL PRIMARY KEY,
  [Order_ID]  INT NOT NULL REFERENCES dbo.[Order](Order_ID),
  [Address_ID]  INT NOT NULL REFERENCES dbo.Address(Address_ID),
  [Shipment_Status] VARCHAR(20),
  [Shipped_At] DATETIME,
  [Delivered_At] DATETIME,
  [FastDelivery] DATETIME,);

 
------------------------------------------------- COMPUTED COLUMNS BASED ON A FUNCTION ----------------------------------


/* 1. Computed column function to calculate TotalPrice in OrderItem Table using Price From Product Table and Quantity from Order Table */

create function fn_CalculatePrice (@ProdID int)
returns money
as 
Begin
	Declare @Price money  
	SELECT @Price =  o.Quantity * p.Price
	from OrderItem o
	join Product p
	ON o.Product_ID = p.Product_ID
	WHERE o.Product_ID = @ProdID
	return @Price;
end;

ALTER TABLE OrderItem
ADD TotalPrice AS (dbo.fn_CalculatePrice(Product_ID));

/* 2. Computed column function to calculate TotalPrice in ShoppingCartItem Table using Price From Product Table and Quantity from ShoppingCartItem Table */

create function fn_CalculatePrice_ShoppingCartItem (@ProdID int)
returns money
as 
Begin
	Declare @totalPrice money 
	select @totalPrice = s.Quantity * p.Price
	from ShoppingCartItem s
	join Product p
	ON s.Product_ID = p.Product_ID
	WHERE s.Product_ID = @ProdID
	return @totalPrice;
end;

ALTER TABLE ShoppingCartItem
ADD TotalPrice AS (dbo.fn_CalculatePrice(Product_ID));

/* Function for calculating the amount at which a product will be sold(taking the number of quantity of the product alongside) after the discount is applicable */
Drop function if exists dbo.discount_on_brands
go
Create function discount_on_brands
(@list_price money,
 @quantity int,
 @discount float)
 Returns int
 as
 Begin
  Return @quantity*@list_price* (1-(@discount/100))
 end
 go
 --Select dbo.discount_on_brands(10,2,Cast('50' as decimal(10,2)));--


------------------------------------------------------------------- END COMPUTED COLUMNS BASED ON A FUNCTION -------------------------------------------------


--------------------------------------------------------------------- CREATING VIEWS ---------------------------------------------------------------------

 /* VIEW 1 : View Orders that are above the average price in the whole table  */

Create view [Orders Above Average Price] As
Select o.Order_id,o.Customer_id,o.Territory_id,t.Territoy_name,o.TotalPrice from dbo.[Order] o
join dbo.Territory t 
on t.Territory_ID =o.Territory_ID 
where TotalPrice >(select AVG(TotalPrice) From dbo.[Order]  )
select * from dbo.[Orders Above Average Price] oaap 

/* View2 :View the Top 5 Customers who have placed highest amount of order as per year  */

Create view [Top 5 Customers of the Year] As
select * from(
Select o.Customer_id,year(Created_At )as orderyear,c.First_Name +' '+c.Last_Name as fullname  ,sum(o.TotalPrice) as Total_Worth_Of_Order_Placed,RANK() Over(order by sum(TotalPrice)desc)as Topcustomers  from dbo.[Order] o
join dbo.Customer c 
on c.Customer_ID =o.Customer_ID 
group by o.Customer_ID,c.First_Name ,c.Last_Name,year(Created_At))t1
where Topcustomers<=5

/* VIEW 3 : View the Discounted Price for products of brands on which discount is applicable */
Drop view if exists BrandDiscount
 go
 Create View BrandDiscount
 AS 
 Select b.Brand_Name,p.Product_Name,p.Price,oi.Quantity,d.Discount_Percentage,
 sum(dbo.discount_on_brands(
     oi.Quantity,p.Price,d.Discount_Percentage)) As Discounted_Amt

 from Product p
 join OrderItem oi
 on oi.Product_ID=p.Product_ID
 join [order] o
 on o.Order_ID=oi.Order_ID
 join Discount d
 on o.Discount_ID=d.Discount_ID
 join Brand b
 on b.Brand_ID=p.Brand_ID
 Group by b.Brand_Name,p.Product_Name,p.Price,oi.Quantity,d.Discount_Percentage;
 go


------------------------------------------------------------------------END OF VIEW ---------------------------------------------------------------


------------------------------------------------------------------ ENCRYPTION -------------------------------------------------------------------

/* Encryption 1 - ENCRYPTION FOR Password ON Customer Table*/

CREATE MASTER KEY
ENCRYPTION BY PASSWORD = 'Test_P@sswOrd';

CREATE CERTIFICATE TestCertificate
WITH SUBJECT = 'Team11 Test Certificate',
EXPIRY_DATE = '2026-10-31';

CREATE SYMMETRIC KEY TestSymmetricKey
WITH ALGORITHM = AES_128
ENCRYPTION BY CERTIFICATE TestCertificate;

OPEN SYMMETRIC KEY TestSymmetricKey
DECRYPTION BY CERTIFICATE TestCertificate;


ALTER TABLE Customer DROP COLUMN PasswordHash;
ALTER TABLE Customer ADD PasswordHash VARBINARY(250);


UPDATE Customer
SET PasswordHash = (EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, 'Pass1')))
Where Customer_ID = 6;

UPDATE Customer
SET PasswordHash = (EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, 'Pass2')))
Where Customer_ID = 7;

UPDATE Customer
SET PasswordHash = (EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, 'Pass3')))
Where Customer_ID = 8;

UPDATE Customer
SET PasswordHash = (EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, 'Pass4')))
Where Customer_ID = 9;

UPDATE Customer
SET PasswordHash = (EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, 'Pass5')))
Where Customer_ID = 10;

UPDATE Customer
SET PasswordHash = (EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, 'Pass6')))
Where Customer_ID = 11;

UPDATE Customer
SET PasswordHash = (EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, 'Pass7')))
Where Customer_ID = 12;

UPDATE Customer
SET PasswordHash = (EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, 'Pass8')))
Where Customer_ID = 13;

UPDATE Customer
SET PasswordHash = (EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, 'Pass9')))
Where Customer_ID = 14;

UPDATE Customer
SET PasswordHash = (EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, 'Pass10')))
Where Customer_ID = 15;


/* DECRYPT */

select convert(varchar, DecryptByKey(CVV))
from Customer;


/* Encryption 2 - ENCRYPTION FOR CVV ON CardDetails Table*/


ALTER TABLE CardDetails
DROP Column CVV;

ALTER TABLE CardDetails
ADD CVV VARBINARY(250);

UPDATE CardDetails
SET CVV = (EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, '660')))
Where Card_ID = 3;

UPDATE CardDetails
SET CVV = (EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, '660')))
Where Card_ID = 4;

UPDATE CardDetails
SET CVV = (EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, '660')))
Where Card_ID = 5;

UPDATE CardDetails
SET CVV = (EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, '660')))
Where Card_ID = 6;

UPDATE CardDetails
SET CVV = (EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, '660')))
Where Card_ID = 7;

UPDATE CardDetails
SET CVV = (EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, '660')))
Where Card_ID = 8;

UPDATE CardDetails
SET CVV = (EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, '660')))
Where Card_ID = 9;

UPDATE CardDetails
SET CVV = (EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, '660')))
Where Card_ID = 10;

UPDATE CardDetails
SET CVV = (EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, '660')))
Where Card_ID = 11;

UPDATE CardDetails
SET CVV = (EncryptByKey(Key_GUID(N'TestSymmetricKey'), convert(varbinary, '660')))
Where Card_ID = 12;


/* DECRYPT */

select convert(varchar, DecryptByKey(CVV))
from CardDetails;


--------------------------------------------------------------- END ENCRYPTION --------------------------------------------------------------

-------------------------------------------------------------------TABLE LEVEL CHECK -----------------------------------------------------------
CREATE FUNCTION ZeroQuantityCheck(@quant int)
RETURNS smallint
AS 
BEGIN
  DECLARE @Count smallint=0;
  IF (@quant >0) SELECT  @Count=1
  RETURN @Count;
END;

 

ALTER TABLE Product ADD CONSTRAINT ZeroQuantity CHECK(dbo.ZeroQuantityCheck(Quantity)>0);

-------------------------------------------------------------------TABLE LEVEL CHECK END -----------------------------------------------------------


-------------------------------------------------------------------TRIGGERS -----------------------------------------------------------

/* TRIGGER 1: Trigger Created to automatically generate Invoice once payment is made */

IF OBJECT_ID ('updateInvoiceOnMakePayment','TR') IS NOT NULL
   DROP TRIGGER updateInvoiceOnMakePayment;
GO
CREATE TRIGGER updateInvoiceOnMakePayment
ON dbo.Payment
AFTER INSERT
AS
BEGIN
	DECLARE @paymentId INT
	DECLARE @paymentAmt money
	SELECT @paymentId=(Payment_Id), @paymentAmt=(amount) FROM INSERTED
	INSERT INTO [dbo].[Invoice]
			   ([Payment_ID]
			   ,[Invoice_Date]
			   ,[Invoice_details])
		 VALUES
		   (@paymentId,
			CURRENT_TIMESTAMP,
			'Total Amount - ' + CAST(@paymentAmt AS VARCHAR(50)))
END


/*TRIGGER 2: Trigger on OrderItem table to update total price in Order table */

CREATE TRIGGER UpdateOrderTotalPrice
ON OrderItem
AFTER INSERT, UPDATE, DELETE
AS BEGIN
	DECLARE @totalSale money = 0;
	DECLARE @orderid int;

	SELECT @orderid = ISNULL (i.Order_ID, d.Order_ID)
	   FROM inserted i FULL JOIN deleted d 
	   ON i.Order_ID = d.Order_ID;

	SELECT @totalSale = SUM(TotalPrice)
	   FROM OrderItem
   	   WHERE Order_ID = @orderid GROUP BY Order_ID;

	UPDATE [dbo].[Order]
		SET TotalPrice = @totalSale
		WHERE Order_ID = @orderid 
END

---------------------------------------------------------------- END OF TRIGGER ------------------------------------------------------------------



-----------------------------------------------------------------INSERT SCRIPTS ------------------------------------------------------------------------




---------------------------------------------------------------1. INSERT INTO Table Customer ---------------------------------------------------------

INSERT INTO [dbo].[Customer]  ([First_Name] ,[Middle_Name] ,[Last_Name] ,[Mobile] ,[EmailID] ,[PasswordHash] ,[RegisteredAt],[LastLogin],[Profile]) VALUES 
('Austin','Hilda','Steele','617-321-3489','austin.steele@gmail.com','pbFwXWE99vobT6g+vPWFy93NtUU/orrIWafF01hccfM=','2003-02-08 00:00:00.000','2021-05-20 00:00:00.000','non-admin'),
('Jason','Wade','Cain','617-342-5489','jason.cain@gmail.com','u5kbN5n84NRE1h/a+ktdRrXucjgrmfF6wZC4g82rjHM=','2009-03-02 00:00:00.000','2021-06-20 00:00:00.000','non-admin'),
('Cecilia','Floyd','Garner','617-421-9989','cecilia.garner@gmail.com','fCvCTy3RwzA2LNhhhYUbT7erkb9Au5wyM2q7ReHroV0=','2006-10-08 00:00:00.000','2021-07-20 00:00:00.000','non-admin'),
('Dale','Ellen','Barker','859-321-3489','dale.barker@gmail.com','oaeJoTn5hbyNfemp2qzIpGTP5uNle8NRPki9Ur3Znl8=','2007-02-08 00:00:00.000','2021-02-20 00:00:00.000','non-admin'),
('Calvin','Angel','Bailey','859-999-3489','calvin.bailey@gmail.com','+Six1+I1JOOR+oosTOz1L7jf/t79CUdo05d5uv+scXE=','2010-02-08 00:00:00.000','2021-03-10 00:00:00.000','non-admin'),
('Pete','Margie','Morris','617-871-0489','pete.morris@gmail.com','wI5v4SNv5Mg5ea0Ufy1xy966PrXWCBp8gLIhC1QTqWw=','2001-02-08 00:00:00.000','2021-04-20 00:00:00.000','non-admin'),
('Anne','Alton','Cox','617-121-2489','anne.cox@gmail.com','/f3DO3lkCqiT9QfG85CP6cEVy9nWhhvLdWBYXn9g+/U=','2008-02-08 00:00:00.000','2021-02-21 00:00:00.000','non-admin'),
('Sandy','Ethel','George','617-543-9283','sandy.george@gmail.com','kiPpDLLHhN838Tjgq16FYttne2u7jphUoA3rU++BsI4=','2005-02-08 00:00:00.000','2021-06-12 00:00:00.000','non-admin'),
('Otis','Alfredo','Webster','617-098-5474','otis.webster@gmail.com','JxsQqrqKYNwQJk5A4jZ8PTYjVQLbf7Qr4B2ToWhOuG0=','2002-02-08 00:00:00.000','2021-01-20 00:00:00.000','non-admin'),
('Marcus','Anne','Guzman','617-098-6543','marcus.guzman@gmail.com','egjnsimMaxOidXBXFQ33QOSGTATTRb1Uzd2P8RY7O4g=','2009-02-08 00:00:00.000','2021-04-10 00:00:00.000','non-admin');


------------------------------------------------------------------2. INSERT INTO TABLE Address -----------------------------------------------------------

INSERT INTO Team11.dbo.Address(Customer_ID, Address_Type, Street, City, State, Zipcode) VALUES
('6', 'Shipping', '7748  Mulberry Street', 'Nashville', 'Tennessee', '39986')
('7', 'Both', '91 Winchester Road', 'Des Plaines', 'Illinois', '56631'),
('8', 'Billing', '174 Hacks Cross', 'Memphis', 'Tennessee', '38125'),
('9', 'Shipping', '104 Maples Street', 'Savannah', 'Georgia', '46210'),
('10', 'Shipping', '66 Poplar Avenue', 'Boulder', 'Colorado' , '69557'),
('11', 'Both', '101 Park Street', 'Naples', 'Florida', '77210'),
('12', 'Billing', '49 Raymond Avenue', 'Orlando', 'Florida', '78446'),
('13', 'Shipping', '66 Lakeshore Road', 'Dallas', 'Texas', '66342'),
('14', 'Shipping', '101 Dorchester Road', 'Arlington', 'Texas', '99453'),
('15', 'Both', '333 WaterTown' , 'Boston', 'Massachusetts', '66341')

---------------------------------------------------------------3. INSERT INTO TABLE User_Session ----------------------------------------------------


INSERT INTO User_Session
(Customer_ID, Login_time)
VALUES(6, (getdate())),
(7, (getdate()-2)),
(8, (getdate()-'06:11:07')),
(9, (getdate()-'08:11:30')),
(10, (getdate())),
(11, (getdate())),
(12, (getdate())),
(13, (getdate())),
(14, (getdate())),
(15, (getdate())),
(16, (getdate()));


--------------------------------------------------------------4. INSERT INTO Table ShoppingCart --------------------------------------------------


Insert into dbo.ShoppingCartItem(Cart_ID, Product_ID,Quantity,Price)
Values (1,2,3,840),
       (2,3,2,1758),
	   (5,7,10,300),
	   (4,7,6,180),
	   (9,10,100,1400),
	   (8,5,5,645),
	   (3,12,20,339.8),
	   (3,8,1,41.98),
	   (7,4,5,35),
	   (10,6,1,496)


--------------------------------------------------------------5. INSERT INTO Table ShoppingCartItem --------------------------------------------------

INSERT INTO dbo.ShoppingCartItem(Cart_ID, Product_ID,Quantity,Price)
VALUES (1,2,3,840),
       (2,3,2,1758),
	   (5,7,10,300),
	   (4,7,6,180),
	   (9,10,100,1400),
	   (8,5,5,645),
	   (3,12,20,339.8),
	   (3,8,1,41.98),
	   (7,4,5,35),
	   (10,6,1,496)


--------------------------------------------------------------6. INSERT INTO Table CardDetail --------------------------------------------------

INSERT INTO CardDetails
(Customer_ID, Card_Type, Card_Number, CardHolder_Name, Expire_Date, CVV) VALUES
(6, 'Visa', 425589, 'Austin Hilda', '2022-01-02', 123),
(7, 'Master', 485689, 'Jason Wade', '2022-01-02', 456),
(8, 'Visa', 425589, 'Cecilia Floyd', '2024-01-03', 888),
(9, 'Master', 485689, 'Dale Ellen', '2023-09-01', 696),
(10, 'Visa', 4587256, 'calvin Angel', '2025-05-02', 001),
(11, 'Master', 457812, 'Pete Margie', '2029-04-02', 554),
(12, 'Visa', 788524, 'Anne Cox', '2028-02-03', 998),
(13, 'Master', 88889, 'Sandy George', '2022-01-01', 553),
(14, 'Visa', 774582, 'Otis Webster', '2024-01-07', 668),
(15, 'Master', 6458231, 'Marcus Guzman', '2022-12-12', 660)


--------------------------------------------------------------7. INSERT INTO Table Transaction --------------------------------------------------

INSERT INTO [dbo].[Transactions]([Order_ID],[Payment_ID],[Created_at],[Updated_at],[Status])
VALUES(1,1,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,'In Progress'),
(2,2,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,'In Progress'),
(3,3,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,'Delayed'),
(4,4,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,'In Progress'),
(5,5,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,'Delivered'),
(6,6,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,'In Progress'),
(7,7,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,'Delayed'),
(8,8,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,'In Progress'),
(9,9,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,'Delivered'),
(10,10,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,'Delivered')


--------------------------------------------------------------8. INSERT INTO Table Payment --------------------------------------------------

INSERT INTO Payment (Card_ID, Amount) Values
(3,100),
(4,100),
(5,135),
(6,200),
(7,160),
(8,209),
(9,600),
(10,500),
(11,500),
(12,550);

--------------------------------------------------------------9. INSERT INTO Table Invoice --------------------------------------------------

INSERT INTO Invoice(Payment_ID) Values
(1),
(2),
(3),
(4),
(5),
(6),
(7),
(8),
(9),
(10);

--------------------------------------------------------------10. INSERT INTO Table Product --------------------------------------------------

INSERT INTO [dbo].[Product] ([Category_ID], [Brand_ID] ,[Seller_ID] ,[Product_Name] ,[Quantity],[Price],[Product_Summary],[Product_CreatedAt],[Product_UpdatedAt]) VALUES
(8,1,3,'Training Shoes',90,280,'Durable leather overlays for stability & that locks in your midfoot',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP), 
(3,24,1,'iPhone 12',30,879,'It has a 6.1-inch display',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP),
(1,11,4,'HD Matte Lipcolor',208,7,'Velvety Lightweight Matte Liquid Lipstick',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP),
(7,13,8,'Camping Tent',78,129,'Compact design, easy transportation and waterproof',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP),
(3,21,2,'Smart NanoCell TV',12,496,'Real 4K NanoCell Display, 43 inches',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP),
(9,16,8,'Teddy Bear',25,30,'Soft toy',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP),
(10,26,4,'Dog Food',21,41.98,'Healthy Dog Food, 24 lb',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP),
(2,20,2,'Mathematics',31,14,'Packed with drills and skill-building exercises, 4th Edition',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP),
(8,1,10,'Sportswear',18,35,'Combines style and comfort with soft, smooth fabric',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP),
(1,12,6,'Mascara',34,16.99,'Rich mascara lays down smoothly for dramatic length and sky-high lift,0.27 ounce',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP);

--------------------------------------------------------------11. INSERT INTO Table Seller --------------------------------------------------

INSERT [dbo].[Seller] ([Seller_ID], [Seller_Name], [Seller_Location]) Values
(1, N'Nice Twice Quality Goods', N'New York'),
(2, N'C & CTrading Co.', N'New Jersey'),
(3, N'Medikus', N'New Hampshire'),
(4, N'Wonderio', N'Florida'),
(5, N'save ME deals', N'Boston'),
(6, N'Customer Trust', N'Texas'),
(7, N'xssential', N'California'),
(8, N'Cloud-Kart INC.', N'Iowa'),
(9, N'AmericanOTC', N'Arizona'),
(10, N'SAMZ ONLINE INC.', N'Ohio');


--------------------------------------------------------------12.INSERT INTO Table Brand --------------------------------------------------


INSERT INTO [dbo].[Brand]([Brand_Name])VALUES
('Revlon'),
('Lakme'),
('Quechua'),
('Corelle'),
('Crayola'),
('Hamleys'),
('Penguin'),
('Henry Holt'),
('Pearson'),
('McGraw-Hill'),
('LG'),
('Sony'),
('Phillips'),
('Apple'),
('Samsung'),
('PetSmart'),
('Petco');

--------------------------------------------------------------13. INSERT INTO Table Category --------------------------------------------------

INSERT [dbo].[Category] ([Category_ID], [Category_Name], [Category_Desc]) 
VALUES (1, N'Beauty', N'All brands of Beauty Products Available')
VALUES (2, N'Books', N'All Genres of Books Available')
VALUES (3, N'Electronics', N'All Types of Electronics Available')
VALUES (4, N'Health and Personal Care', N'All brands of Beauty Products Available')
VALUES (5, N'Cell phones and Accessories', N'All brands of Cell Phones Available')
VALUES (6, N'Home and Garden', N'Shop all your Home and Gardern Items')
VALUES (7, N'Outdoors', N'All Outdoor Item Available at your convenience')
VALUES (8, N'Sports', N'All brands of Sports Products Available')
VALUES (9, N'Toys and Games', N'Select all your favorite Toys and Games here')
VALUES (10, N'Pet Supplies', N'All brands of Pet Supplies Available')





--------------------------------------------------------------14. INSERT INTO Table Review --------------------------------------------------


INSERT INTO Review (Product_ID, Customer_ID, Rating, Review_Comment) VALUES
(2,6,5,'Very comfortable to wear, goes with all the outfit'),
(3,7,5,'Very fast, good battery back up and great camera'),
(4,8,3,'feels very dry, shade is different from what is shown in image'),
(5,9,3,'Material is not that good'),
(6,10,5,'Display is awesome and TV is quite sleak'),
(7,11,5,'Material is very very soft, cutest Teddy Bear'),
(8,12,5,'My dog loves it'),
(10,13,2,'Some of the pages are torn, condition is not good'),
(11,14,4,'Smooth Fabric as mentioned, size goes a little bit large than usual'),
(12,15,2,'Not smooth, dried up and not water-proof');



--------------------------------------------------------------15. INSERT INTO Table Order --------------------------------------------------
INSERT INTO [dbo].[Order]
          ([Customer_ID] ,[Discount_ID]  ,[Territory_ID],[Status]  ,[TotalPrice] ,[Tax] ,[Shipping_Charges])
 VALUES         (6,35,1,'In Progress',100,2,6),
                (7,36,4,'In Progress',100,2,6),
                (8,37,2,'Delayed',170,1.9,7),
                (9,39,3,'In Progress',200,4.6,10),
                (10,40,5,'Delivered',160,2,5),
                (11,41,6,'In Progress',170,2.5,4),
                (12,42,7,'Delayed',600,3.5,5),
                (13,43,8,'In Progress',500,4.5,3),
                (14,44,1,'Delivered',550,4.5,3),
                (15,45,2,'Delivered',300,5,4)
 
INSERT INTO [dbo].[Order]
          ([Customer_ID] ,[Discount_ID]  ,[Territory_ID],[Status]  ,[TotalPrice] ,[Tax] ,[Shipping_Charges])
 VALUES         (7,40,10,'In Progress',400,3,5)
                
              

--------------------------------------------------------------16. INSERT INTO Table OrderItem --------------------------------------------------
 INSERT INTO [dbo].[OrderItem]([Order_ID],[Product_ID],[Quantity])
	VALUES(6,8,5),
		  (9,5,1),
		  (11,2,2),
		  (4,5,5),
		  (3,12,2),
		  (7,11,1),
		  (3,11,1),
		  (5,3,2),
		  (10,4,7)

INSERT INTO [dbo].[OrderItem]([Order_ID],[Product_ID],[Quantity])
	VALUES(17,11,7)
Select * from [Order]
Select * from OrderItem

		  

--------------------------------------------------------------17. INSERT INTO Table Territory --------------------------------------------------

INSERT INTO Territory
(Territoy_Name, Territory_Desc)
VALUES
('Helio', 'South of denver'),
('trio', 'North of denver'),
('Lakewood', 'SouthEast of denver'),
('Bellevue', 'SouthWest of denver'),
('Redmondlake', 'downtown denver'),
('kirkland', 'northwest of denver'),
('centralpark', 'north of colorado'),
('timequare', 'South of colorado'),
('pentagonpark', 'east of colorado'),
('lynwood', 'west of colorado')

--------------------------------------------------------------18. INSERT INTO Table Discount --------------------------------------------------

INSERT [dbo].[Discount] ([Discount_ID], [Discount_Name], [Discount_Percentage]) 
VALUES (35, N'Black Friday', N'50')
VALUES (36, N'Thanksgiving', N'60')
VALUES (37, N'Independence Day', N'15')
VALUES (39, N'Mothers Day', N'10')
VALUES (40, N'Fathers Day', N'10')
VALUES (41, N'Valentines Day', N'30')
VALUES (42, N'Year End', N'40')
VALUES (43, N'Labor Day', N'25')
VALUES (44, N'Juneteenth', N'15')
VALUES (45, N'Memorial Day', N'20')



--------------------------------------------------------------19. INSERT INTO Table ReturnOrderITem --------------------------------------------------

    
INSERT INTO ReturnOrderItem
(OrderItem_ID, Return_Timestamp)
VALUES(10, (getdate()));
INSERT INTO ReturnOrderItem
(OrderItem_ID, Return_Timestamp)
VALUES(11, (getdate())-2);
INSERT INTO ReturnOrderItem
(OrderItem_ID, Return_Timestamp)
VALUES(12, (getdate()-'15:04:07'));
INSERT INTO ReturnOrderItem
(OrderItem_ID, Return_Timestamp)
VALUES(13, (getdate()-'10:04:07'));
INSERT INTO ReturnOrderItem
(OrderItem_ID, Return_Timestamp)
VALUES(14, (getdate()-'12:04:07'));
INSERT INTO ReturnOrderItem
(OrderItem_ID, Return_Timestamp)
VALUES(15, (getdate()-4));
INSERT INTO ReturnOrderItem
(OrderItem_ID, Return_Timestamp)
VALUES(16, (getdate()-5));
INSERT INTO ReturnOrderItem
(OrderItem_ID, Return_Timestamp)
VALUES(17, (getdate()-'2:04:07'));
INSERT INTO ReturnOrderItem
(OrderItem_ID, Return_Timestamp)
VALUES(18, (getdate()-'9:04:07'));
INSERT INTO ReturnOrderItem
(OrderItem_ID, Return_Timestamp)
VALUES(32, (getdate()-'7:04:07'));


--------------------------------------------------------------20. INSERT INTO Table Shipment --------------------------------------------------

INSERT INTO [dbo].[Shipment]([Order_ID],[Address_ID],[Shipment_Status],[Shipped_At],[Delivered_At],[FastDelivery])
VALUES
(1,1,'In Progress',CURRENT_TIMESTAMP,'2021-07-29 15:30:36.930','0'),
(2,2,'Delayed',CURRENT_TIMESTAMP,'2021-07-29 20:30:36.320','0'),
(3,3,'Delayed',CURRENT_TIMESTAMP,'2021-07-30 15:30:36.930','0'),
(4,4,'In Progress',CURRENT_TIMESTAMP,'2021-07-30 18:30:36.930','0'),
(5,5,'In Progress',CURRENT_TIMESTAMP,'2021-07-28 20:30:36.930','1'),
(6,6,'In Progress',CURRENT_TIMESTAMP,'2021-07-29 14:30:36.930','0'),
(7,7,'Delayed',CURRENT_TIMESTAMP,'2021-07-30 13:30:36.930','0'),
(8,8,'In Progress',CURRENT_TIMESTAMP,'2021-07-29 16:30:36.930','0'),
(9,9,'Delivered',CURRENT_TIMESTAMP,'2021-07-29 15:30:36.930','1'),
(10,10,'Delivered',CURRENT_TIMESTAMP,'2021-07-28 13:30:36.930','1')

-----------------------------------------------------------------------END ---------------------------------------------------------------------