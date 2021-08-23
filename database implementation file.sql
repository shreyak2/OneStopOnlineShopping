Select *
from INFORMATION_SCHEMA.TABLES
SELECT DATA_TYPE,COLUMN_NAME
from INFORMATION_SCHEMA. COLUMNS 



CREATE TABLE Seller (
   Seller_ID INT Identity NOT NULL Primary Key ,
   Seller_Name  VARCHAR(60),
   Seller_Location VARCHAR(250)
)
Select * from dbo.Seller
Select * from dbo.ShoppingCartItem;


--ORDER--
   Drop Table dbo.[order];

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
   PickUp  VARCHAR(20)
);

INSERT INTO [dbo].[Order]
           ([Customer_ID]
           ,[Discount_ID]
		   ,[Territory_ID],[Status]
           ,[TotalPrice]
           ,[Tax]
           ,[Shipping_Charges])
           
     VALUES
	        
		   (6,35,1,'In Progress',100,2,6),
		   (7,36,4,'In Progress',100,2,6),
           (8,37,2,'Delayed',170,1.9,7),
		   (9,39,3,'In Progress',200,4.6,10),
		   (10,40,5,'Delivered',160,2,5),
		   (11,41,6,'In Progress',170,2.5,4),
		   (12,42,7,'Delayed',600,3.5,5),
		   (13,43,8,'In Progress',500,4.5,3),
		   (14,44,1,'Delivered',550,4.5,3),
		   (15,45,2,'Delivered',300,5,4)



USE [Team11]
GO
select * from Customer;
select * from Discount;
select * from Territory;
SELECT * FROM [order];


GO

Select * from [Order];
Select * from Product;


--OrderItem--
CREATE TABLE OrderItem (
   OrderItem_ID INT IDENTITY NOT NULL PRIMARY KEY,
   Order_ID INT NOT NULL REFERENCES dbo.[Order](Order_ID),
   Product_ID INT NOT NULL REFERENCES dbo.Product(Product_ID),
   Quantity INT NOT NULL,
   Price Money NOT NULL
 );

 ALTER TABLE Orderitem ADD TotalPrice AS Quantity*Price;
 Select * from OrderItem;
 Alter Table OrderItem
 Drop Column TotalPrice ;


 Select * from OrderItem
 INSERT INTO [dbo].[OrderItem]
           ([Order_ID]
           ,[Product_ID]
		   ,[Quantity],[Price])
VALUES(6,8,5,209.9),
      (9,5,1,129.00),
	  (11,2,2,560),
	  (4,5,5,645),
	  (3,12,2,33.98),
      (7,11,1,35.00),
       (3,11,1,35.00),
	   (5,3,2,1758),
	   (10,4,7,49)

		  

 USE [Team11]
GO

Select * from Product;
Select * from [Order];

	
 --shoppingcartItem--
 CREATE TABLE  ShoppingCartItem (
   CartItem_ID INT IDENTITY NOT NULL PRIMARY KEY,
   Cart_ID INT NOT NULL REFERENCES dbo.ShoppingCart(Cart_ID),
   Product_ID INT NOT NULL REFERENCES dbo.Product(Product_ID),
   Quantity  INT NOT NULL,
   Price MONEY NOT NULL,
   Timestamp_added DATETIME DEFAULT CURRENT_TIMESTAMP
);

Select * from ShoppingCart;
Select * from Product;

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


--create view of prod whose inventory quantity is less than 30 and price more than 30 and brand in [hamleys,lg,petsmart]

select * from Product
select * from brand
select * from Discount
select * from [Order]
select * from OrderItem


--func to get discount--
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
 Select dbo.discount_on_brands(10,2,Cast('50' as decimal(10,2)));
 go
 Select * FRom Brand;
 SElect* from Product;
 SElect* from Customer;
 SElect* from Discount;
 Select * from [Order];
 select * from OrderItem;
 go
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
 Select * 
 from BrandDiscount
 