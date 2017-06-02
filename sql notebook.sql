update emp
          set sal = sal*2.25
          where deptno = 30

update emp
          set sal = sal*2.25
          where empno in ( select empno from emp_1 )

insert into dept (deptno, dname, loc)
values (10,'Apple','Boston')

--How to create a new table having the same structure as some other table?
create table new_table
as
select *
from old_table

--How to delete duplicate records from the table?

--Suppose we have a table t1(id integer, name varchar(10))

select * from t1;

id	name
1	aaa
2	bbb
3	bbb
4	ccc
5	ccc
6	ddd
delete from t1
where id not in ( select min(id)
				from t1
				group by name )

--view
create view abc as

--second highest

SELECT MAX(SALARY) 
FROM EMPLOYEE 
WHERE SALARY NOT IN (SELECT MAX(SALARY) FROM EMPLOYEE)

--We can see that it's best to use EXISTS because it always behaves as the user would think it does
--JOIN vs IN vs EXISTS - the logical difference

CREATE TABLE t1 (id INT, title VARCHAR(20), someIntCol INT)
GO
CREATE TABLE t2 (id INT, t1Id INT, someData VARCHAR(20))
GO

INSERT INTO t1
SELECT 1, 'title 1', 5 UNION ALL
SELECT 2, 'title 2', 5 UNION ALL
SELECT 3, 'title 3', 5 UNION ALL
SELECT 4, 'title 4', 5 UNION ALL
SELECT null, 'title 5', 5 UNION ALL
SELECT null, 'title 6', 5

INSERT INTO t2
SELECT 1, 1, 'data 1' UNION ALL
SELECT 2, 1, 'data 2' UNION ALL
SELECT 3, 2, 'data 3' UNION ALL
SELECT 4, 3, 'data 4' UNION ALL
SELECT 5, 3, 'data 5' UNION ALL
SELECT 6, 3, 'data 6' UNION ALL
SELECT 7, 4, 'data 7' UNION ALL
SELECT 8, null, 'data 8' UNION ALL
SELECT 9, 6, 'data 9' UNION ALL
SELECT 10, 6, 'data 10' UNION ALL
SELECT 11, 8, 'data 11'

select * from t1
select * from t2
select t1.* from 
	t1 join t2
	on t1.id=t1id
select * from t1
where t1.id in (select t1id from t2)

select * from t1
where exists (select 1 from t2 where t1.id=t1id)

select * from t1 left join t2 
			on t1.id=t1id
			where t2.id is null
select * from t1
where not exists( select 1 from t2 where t1.id=t1id)

DROP TABLE t2
DROP TABLE t1

SELECT REPLACE('abcdefghicde','cde','xxx');
GO
--abxxxfghixxx
Select Replace ('The sea is blue.', 'blue','green') From dual
--The sea is green.

/*The SQL TOP clause is used to specify the number of records returned by the query. 
With TOP you can specify to retrieve the first N records or the first X percent of records.
The TOP expression can be used in SELECT, INSERT, UPDATE, and DELETE statements.*/

--select into
SELECT *
INTO Employees_Backup
FROM Employees

--We can also use the IN clause to copy the table into another database:
SELECT *
INTO Employees_Backup IN 'My_Backup.mdb'
FROM Employees
--under where condition
SELECT LastName,Firstname,Ecode
INTO Employees_Backup
FROM Employees
WHERE City='London'


--CREATE TABLE statement:

CREATE TABLE Employees
(
Emp_Id int,
LastName varchar(100),
FirstName varchar(100),
Address varchar(200),
City varchar(255)
)


--Some other example of create table in a different way:

1.
CREATE TABLE Employees_Duplicate
AS (SELECT *
FROM Employees
WHERE id > 500);

--This will create a new table called Employees_Duplicate that will include all columns from the Employees table and all rows fetched by the select statement.

2.
CREATE TABLE Employees
AS (SELECT * FROM customers WHERE 1=2);

--This will create a new table called Employees that include all columns from the customers table, but no data from the customers table.

3.
CREATE TABLE Employees_New
AS (SELECT Employees.id, Employees.address, customers.cust_type
FROM Employees, customers
WHERE Employees.id = customers.id
AND Employees.id > 500);

--This would create a new table called Employees_New based on columns from both the Employees and customers tables.

/*Alter Table
Alter Table changes (alters) a table definition by altering, adding, or dropping columns and constraints, or by disabling or enabling constraints and triggers.

Example 1 of Alter Table

Adding a new column to an Emp table:

ALTER TABLE Emp ADD phone CHAR(16)
DEFAULT 'unlisted';

Example 2 of Alter Table

Dropping a column from an Emp table:

ALTER TABLE Emp DROP phone;

Example 3 of Alter Table

Changing the datatype of a column in a table:

ALTER TABLE Emp
ALTER COLUMN phone varchar;

Example 4 of Alter Table

Modifying a column:
[if earlier the column "name" is like varchar(20) and we want to change it to varchar(100) then do as follows:]

ALTER TABLE Emp ALTER COLUMN name varchar(100);

Example 5 of Alter Table

Adding a constraint

ALTER TABLE Emp ADD CONSTRAINT con_one UNIQUE (name);

con_one is the name of the constraint.

Example 6 of Alter Table

Constraints can also be dropped

ALTER TABLE Emp DROP CONSTRAINT con_one;

Renaming a column or table is not possible with Alter statement in SQL Server. For that you have to use sp_rename.
*/

SQL COUNT( isnull( column a ,0) ) Is Totally Awesome
---update table base on join function
create table boy 
(boyid int,
bname Varchar(20),
bstatus int)
go
create table girl
(girlid int,
gname varchar(20))
go
create table r
(bid int,
gid int,
startdate date,
enddate date)
go
insert into boy
values 
(1,'lu',0),
(2,'po',0),
(3,'da',0)
go
insert into girl
values
(1,'mei'),
(2,'chou'),
(3,'che')
go
insert into r
values
(1,1,'2008-1-1',null),
(1,3,'2005-2-1','2007-1-1'),
(2,2,'2006-2-1','2007-2-3')
go

update  boy
set bstatus=1
from boy join r
on boy.boyid=r.bid
join girl 
on r.gid=girl.girlid
and girl.gname='che'
go
select * from boy
drop table girl
drop table boy
drop table r
--update with case when
update acount
set banlance =
	( case when ((banlance - 10) < 0)
		then 0
		else banlance-10
		end)
where id = 1 
--update from another table
update abc 
set abc.a=def.e
from abc
join def
on b=e

--delete duplicated records
delete from abc
where id not in
(select max(id) from abc 
	group by column1, column2,column3...)

--check for duplicates
select data, count(data)
from abc
group by data
having count(data)>1
--if only one row of duplicate data
set rowcount 1---就是把第一行越过去  
delete from abc where date='duplicate row'
set rowcount 0--delete后要把这个回复  不影响其他行
--insert distinct date into a new table, drop the old one then rename the new one to old one
SELECT DISTINCT data
INTO    tempTable
FROM    duplicateTable3 
GO
TRUNCATE TABLE duplicateTable3
DROP TABLE duplicateTable3
exec sp_rename 'tempTable', 'duplicateTable3'
--use cte to delete duplicated rows
with abc as 
(select date, row_number() over (partition by date order by date) as a from aaa)
delete from abc
where a >1
--create table with default getdate()
create table abc
(a varchar(20),
b int,
c varchar(20),
d varchar(20),
e datetime default getdate())

select getdate()-10
select datediff(d,getdate(),getdate()+1)
select datediff(mi,getdate(),getdate()+1)
select datediff(hh,getdate(),getdate()+1)
select datediff(wk,getdate(),getdate()+2)
select dateadd(Day, 1, Getdate()) as tomorrow
select dateadd(mm, -2, '07-08-2010')
--In this below example, the date is specified as a number. Notice that SQL Server interprets 0 as January 1, 1900.
SELECT DATEPART(m, 0), DATEPART(d, 0), DATEPART(yy, 0)
--datetime 格式的时间在选取日期是要转换成varchar
Select * from Table_A 
Where Convert(varchar,Dep_date,101)='08/01/2010'
--insert into select
insert into abc (a, b)
select d,e from def
where f<100

insert into abc (a,b)
values ('s',1),
		('w',2)

/*primary key and foreign key 

Example of Referential Integrity

The SQL statement defining the parent table, DEPARTMENT, is:

CREATE TABLE DEPARTMENT
      (DEPTNO    CHAR(3)     NOT NULL,
       DEPTNAME  VARCHAR(29) NOT NULL,
       MGRNO     CHAR(6),
       ADMRDEPT  CHAR(3)     NOT NULL,
       LOCATION  CHAR(16),
          PRIMARY KEY (DEPTNO))
   IN RESOURCE 

The SQL statement defining the dependent table, EMPLOYEE, is:

CREATE TABLE EMPLOYEE
      (EMPNO     CHAR(6)     NOT NULL PRIMARY KEY check(empno>0),
       FIRSTNME  VARCHAR(12) NOT NULL default ('abc'),
       LASTNAME  VARCHAR(15) NOT NULL,
       WORKDEPT  CHAR(3) foreign key references department( deptno),
       PHONENO   CHAR(4) unique,
       PHOTO     BLOB(10m)   NOT NULL,
          
   IN RESOURCE 

By specifying the DEPTNO column as the primary key of the DEPARTMENT table and WORKDEPT as the foreign key of 
the EMPLOYEE table, you are defining a referential constraint on the WORKDEPT values. This constraint 
enforces referential integrity between the values of the two tables. In this case, any employees that are added to 
the EMPLOYEE table must have a department number that can be found in the DEPARTMENT table. 
*/

/* group by xyz with roll up 做完之后去综合
Item	Color	Quantity
Table	Blue	124
Table	Red	223
Chair	Blue	101
Chair	Red	210
SELECT CASE WHEN (GROUPING(Item) = 1) THEN 'ALL'
            ELSE ISNULL(Item, 'UNKNOWN')
       END AS Item,
       CASE WHEN (GROUPING(Color) = 1) THEN 'ALL'
            ELSE ISNULL(Color, 'UNKNOWN')
       END AS Color,
       SUM(Quantity) AS QtySum
FROM Inventory
GROUP BY Item, Color WITH ROLLUP

Item	Color	QtySum
Chair	Blue	101.00
Chair	Red	210.00
Chair	ALL	311.00
Table	Blue	124.00
Table	Red	223.00
Table	ALL	347.00
ALL		ALL	658.00
*/

--group by cube(a,b,c)  show summary of all the possibility combination of a b c
--STUFF (String_expression1, start_position, length, String_expression2)
--REPLACE ( string_expression , string_pattern , string_replacement )
--SELECT BINARY_CHECKSUM(*) from EMP  查表格更改记录
/*IDENTITY [ ( seed , increment ) ]
CREATE TABLE EMP
(
id_number int IDENTITY(1,1), id_number列 以1开头 每行涨1，插入数据时可忽略这行
nick_name varchar (20)
)
CREATE TABLE EMP
(
id_number int IDENTITY(1,2), 以1开头 每行涨2 例如1
nick_name varchar (20)							3
)												5
*/
--exec sp_columns abc 列出abc表格的所有属性
--exec sp_helptext procedurename 查看procedure source code
/*How to find the creation and modification date of stored procedure?

SELECT name, create_date, modify_date
FROM sys.objects
WHERE type = 'P'
AND name = 'sp_willbechanged'
*/
--To get the session ID, type:
SELECT @@SPID
select datediff(d,getdate(),'20180101')
--case when Because the case expression returns an expression, it may be used anywhere in the 
--SQL DML statement (Select, Insert, Update, Delete) where an expression may be used, including 
--column expressions, Join conditions, Where conditions, Having conditions or int the order by.
SELECT CASE
  WHEN TitleOfCourtesy IN('Mr.','Sr.','Sra.') THEN 'Male'
  WHEN TitleOfCourtesy IN('Mrs.','Ms.','Ms') THEN 'Female'
  ELSE 'N/A'
  END AS TitleOfCourtesy
  , FirstName , LastName
FROM Employees
--update delete insert by when matched http://sql-plsql.blogspot.com/2015/07/example-of-merge-statement.html

select @@IDENTITY
--Import Data into SQL Server Table from xml,csv... http://sql-plsql.blogspot.com/2012/02/import-data-into-sql-server-table.html


exec sp_pkeys @table_name='orderdetails',@table_owner='sales'--找primary key
select binary_checksum(*) from sales.orders
exec sp_fkeys @pktable_name='orders',@pktable_owner ='sales'--找foreign key
exec sp_columns @table_name='orders',@table_owner = 'sales' --每行属性
exec sp_databases--显示database size
exec sp_statistics @table_name='orders',@table_owner = 'sales'--index信息 null ok or not

/*
normalization 消灭重复redundancy数据，保证数据的依赖性make sense
normalization for relational database, data warehouse use denormalization
	没有normalization的问题
		update anomaly 更新异常
		insertion anomaly 插入异常
		deletion anomaly 删除异常
	first normal form --> no repeating or duplicate fields, each cell contains only a single value,each record is unique
	2nd normal form--> no partial dependency of any column on PK要完全依赖,解决方法拆分
	3rd normal form--> no transitive dependency 不存在A->B->C 
OLAP online analytical processing 理解成data warehouse,需要的是一个信息已经整合或已经聚合的分析系统，
	关注aggregate，数据仓库 denormalization
OLTP online transaction processing 关注的是每一个transaction 树形数据库 广泛应用normalization
data warehouse include 
	1.data come from like oralcal, sql server,3 party,excel,access database(all of them are OLTP...)
	2 ETL(data integrate to ODS( operational data store))将不同来源的trasaction 整合到ODS，要分析必须整合好分析
	3.data mart 数据集市 以一个subject（主题）来driven的一块数据 财务，hr,市场， subset of data warehouse
	4.cube 为了让报表提取聚合的值，而不是临时去算，而提前准备好的聚合的值
	5.一个一个data mart 组合成 data warehouse 广义上讲是从ETL到report 
fact table:data for analysis could usually fact that happened事实发生过的,drive business question的table
measure  salesprice 度量值 是能够被聚合的，例sum avg 
demision 给measure，一个值一个空间或者说一个维度 如 store, customer
mutidimension 1999年的上海的苹果的价格--3维 
star schema(99%是读的功能）（OLAP）data warehouse like-->a central table contains fact data and multiple tables 
				radiate out from it,
				connected by the prinary and foreign keys of the datebase.往外出 只出一个表 多余1为snowflake
snowflake schema（OLTP）--> represents a dimensional model which is also composed of a central fact table and a set of 
					constituent dimension tables which are further normalized into sub-dimension tables
slowly changing dimension(SCD): 销售干半年从dep1换到dep2 如何update，发生频率很低
	0.preservation 
	1.overwrite
	2.version number, effective date
	3.additional column to keep original and current
	4.history tables


index
CREATE INDEX IX_VendorID ON dbo.ProductVendor (VendorID DESC, Name ASC, Address DESC)
CREATE INDEX IX_FF ON dbo.FactFinance ( FinanceKey, DateKey, OrganizationKey DESC)  
WITH ( DROP_EXISTING = ON )
CREATE UNIQUE INDEX AK_UnitMeasure_Name   
    ON Production.UnitMeasure(Name)
CREATE UNIQUE INDEX AK_Index ON #Test (C2)  
    WITH (IGNORE_DUP_KEY = ON)
*/

SELECT BusinessEntityID, TerritoryID   
   ,DATEPART(yy,ModifiedDate) AS SalesYear  
   ,CONVERT(varchar(20),SalesYTD,1) AS  SalesYTD  
   ,CONVERT(varchar(20),AVG(SalesYTD) OVER (PARTITION BY TerritoryID   
                                            ORDER BY DATEPART(yy,ModifiedDate)   
                                           ),1) AS MovingAvg  
   ,CONVERT(varchar(20),SUM(SalesYTD) OVER (PARTITION BY TerritoryID   
                                            ORDER BY DATEPART(yy,ModifiedDate)   
                                            ),1) AS CumulativeTotal  
FROM Sales.SalesPerson  
WHERE TerritoryID IS NULL OR TerritoryID < 5  
ORDER BY TerritoryID,SalesYear;


select distinct 
empid, year(orderdate),sum(freight) over (partition by empid order by year(orderdate))--每个empid 逐年 freight的总和 2007包括2006，2008包括2007和2006
from sales.orders

select  distinct
empid, year(orderdate),sum(freight) over (order by year(orderdate))--每个empid 逐年 freight的总和 2007包括2006，2008包括2007和2006
from sales.orders


/* sql performance tuning
index internal
A. Factors that impact the performance
1.logical(normalization) 
2.physical design(table split/file groups/partition/view)
3.Hardware (CPU, RAM, DISK, Cache) 
4.Strategy for querying
B. Reasons to optimize the sql query
1. 80/20 20% bad query use 80% energy(noisy neighbor)
2. find the most expensive one and tune it 
C. Mechanism of query analyzer in SQL
1.TSQL in
2.Interpreting 看语法正确否
3.Optimizing 
4.Debugging
5.Execution
6.Row set out
D. How the optimizer works
1. 3 steps 
	statement optimizer
	Access strategy
	Join strategy
2. 3 aspects that impact the query
	index design
	T-SQL design
	Table design(logical and physical)
E. Stracture of Table: Heap(堆)
	Table without a clustered index
	unordered masses of data(来一条扔进去一条，不用按顺序，所以写数据的话，快，但找起来慢)
	Great fro quickly importing large sets of data
	Not great for most production enviroments
	use Alther table ... Rebuild for "rebuild"
F. Structure of Table:Clustered Index 索引页有序性与数据页的有序性完全一致则称为cluster index
	一张表只能有一个cluster index
	1. 相对应heap，保证进来的数据是physically有序的。 先进来134再进来个2会把34往后挪
		id identity(1,1) primary key 就是一个clustered的index
		index id =1 as cluster index heap index id =0
	2. implemented as a B-Tree data structure-- banlance tree
	3. Logical order must always be maintained
	4. The leaf leer of the index contains all table colunmns
	5. We always implement these as unique
G. non-clustered index(可以有无数个)
	Also a B-tree

demon

set statistics io on 把统计数据打开
sp_help 'Table name' show table detail
index scan vs index seek
select * from sys.schemas where name= 'dbo' 查找schema_id
select * from sys.objects where name= 'customer' and schema_id=1 查找这个表的object_id
select * from sys.index where object_ID=551673013 看这个表达index状况 index_id=0 为head，1=clustered，2=nonclustered
create nonclusered index abc_abc
on dbo.customer(customerid) 创建一个nonclusered index
drop index abc_abc on dbo.customer 
create clustered index abc_abc
on dbo.customer(customerid) 
if there is function left(firstname,2)='Kr' index会失效
create nonclustered index abc_abc
on dbo.customer(column1 asc,column2 desc)
if exists (select 1 from sysindexes where name='abc_abc'
begin
	drop index abc_abc
	on dbo.customer
end
covered index
create index abc_abc
on dbo.customer(customerid) include(column2)
filter index
create index abc_abc
on dbo.customer(customerid)
where condition = aaa
A 3NF table which does not have multiple overlapping candidate keys is said to be in BCNF.
*/
--Write a SQL query to rank scores. If there is a tie between two scores, both should have the same ranking. 
--Note that after a tie, the next ranking number should be the next consecutive integer value. In other words, 
--there should be no "holes" between ranks.
SELECT Scores.Score, COUNT(Ranking.Score) AS RANK
  FROM Scores
     , (
       SELECT DISTINCT Score
         FROM Scores
       ) Ranking
 WHERE Scores.Score <= Ranking.Score
 GROUP BY Scores.Id, Scores.Score
 ORDER BY Scores.Score DESC;


-- parse 用来convert 特殊格式的时间（'June 8th 2016' as date）
-- persisted 在一个表里加个colunm带function的 它是不存储数据的 是每次调用每次现算的，为了提高performance，在后面加个persisted 这样就把数据存储了，调用更快
--before load data, remove constrain/non cluster index could improve performance

--foreign key
create table dbo.customerorder
(
customerorderID int identity(100001,1) primary key,
cutomerid int not null
	foreign key references dbo.customers(customerID),
orderAmount decimal(19,2) not null
)

--add clustered
alter table abc add constraint IX_abc unique clustered (colunm1)
create unique clustered index IX_abc on abc(colunm1 asc)
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [SalesLT].[PrintMediaPlacement] ([PublicationDate],[PlacementCost])
INCLUDE ([MediaOutletID],[PlacementDate],[RelatedProductID])

-- sp_help 'abc'(table, sp, view....)
--sp_helptext'abc'
--revert go 退一步

--trigger 1-insert
create trigger tr_opportunity_insert
on sale.opportunity
after insert as
begin
	set nocount on
	insert into sales.opportunityAudit
		(opportunityID, actionPerformed, actionOccuredAt)
		select i.opportunityID,
			'I',
			sysdatetime()
		from inserted as I
end

--trigger delete
create trigger tr_category_delete
on product.category
after delete as
begin
	set nocount on
	update p set p.discontinued = 1
	from product.product as p
	where exists (select 1 from deleted as d
		where p.categoryID = d.categoryID)
end

--trigger update
create trigger tr_productreview_update
on product.productreview
after update as 
begin
	update pr set pr.modificationdate = sysdatetime()
	from product.productreview as pr
	join
		inserted as I
	on pr.productReviewID = I.productReviewID
end

--trigger like constraint 超过10000的order必须有PO
create trigger tr_salesOrder_insert
on sales.orders
after insert as
begin
	if exists
		(select 1 from inserted as i
		where i.subtotal >10000
		and i.PO is null)
		begin
		print 'orders above 10000 must have PO numbers'
		rollback
		end
end
