/* 1. SQL question
Table: B-party (Name, Is_Attended, Date)
Sample data:
Tomas, Y, 12/01/2016
Kelly, Y, 12/02/2016
Jessica, Y, 12/02/2016
Kelly, N, 12/04/2016

This is a table for birthday party registration. 
Name is the name of the guests invited, Is_attended is the guest's reply to the invitation, 
and Date is the date that the guest replies.

In the above sample, Kelly registered for the party on 12/02/2016 but later change her mind
 and deregistered on 12/04/2016.

Now the registration period is closed. Please write a SQL query to provide the number of 
people who are going to attend the party and the number of people who are not going to attend the party. 

Expected output:

Is_attended, Number
Y, 2
N, 1

2. How to improve performance for report

3. Advantages and disadvantages of using index. Index in OLTP vs OLAP

*/

--1. answer
DROP TABLE B_party
GO

CREATE TABLE B_party
(
customerid int IDENTITY(1,1),
Name varchar(30),
Is_Attended char(1) DEFAULT 'Y' NOT NULL,
[Date] date
)
GO

INSERT INTO B_party VALUES ('Tomas','Y','12/01/2016');
INSERT INTO B_party VALUES ('Kelly','Y','12/02/2016');
INSERT INTO B_party VALUES ('Jessica','Y','12/02/2016');
INSERT INTO B_party VALUES ('Kelly','N','12/04/2016');

--Find duplicate rows
SELECT Name,COUNT(*) AS mydupes
FROM B_party
GROUP BY Name
HAVING COUNT(*)>1

--Put none duplicate rows into party
SELECT MAX(customerid) customerid, Name
INTO party
FROM B_party
GROUP BY Name

--Get the attended number
SELECT b.Is_Attended,COUNT(*) Number
FROM party p INNER JOIN B_party b
ON p.customerid=b.customerid
GROUP BY b.Is_Attended
ORDER BY b.Is_Attended DESC

--1. another answer
--Use Common Table Expression
WITH party_CTE (CustomerID,Name)
AS
(
SELECT MAX(customerid) CustomerID,Name
FROM B_party
GROUP BY Name
)
SELECT b.Is_Attended,COUNT(*) Number
FROM party_CTE p INNER JOIN B_party b
ON p.customerid=b.customerid
GROUP BY b.Is_Attended
ORDER BY b.Is_Attended DESC
GO


--We work with large datasets, and are always performance conscious since 
extended processing times will impact our time to market. Keep this in mind 
as you answer the following questions: 

There is a table defined as:
CREATE TABLE [Positions](
            [load_id]           [int]                  NOT NULL, 
            [acct_cd]         [varchar](20)   NOT NULL,
            [acct_num]      [varchar](255)             NULL,
            [sec_id]            [varchar](50)   NOT NULL,
            [long_sht_cd]   [varchar](3)     NOT NULL,
            [sedol]              [varchar](15)   NULL,
            [isin]                 [varchar](15)   NULL,
            [cusip]              [varchar](9)     NULL,
            [sec_type]       [varchar](8)     NULL,
            [sec_name]     [varchar](100) NULL,
            [currency_cd] [varchar](3)     NULL,
            [total_holding] [decimal](18, 4) NULL,
            [mkt_price]      [float]               NULL,
            [datetime_stamp] [datetime]   NULL,
CONSTRAINT [pk_Positions] PRIMARY KEY CLUSTERED (       
[load_id] ASC, 
            [acct_cd] ASC, 
            [sec_id] ASC,
            [long_sht_cd] ASC )
)

/*This table holds account positions data that are appended to multiple times 
a day 
There are currently some 24 million rows in the table. Every time we append 
additional positions we add approximately 32,000 entries to this table, and 
all 32,000 entries will have the same load_id. The load_id is incremented by
one each time we load a batch of 32,000 entries (i.e. the first 32K entries
have load_id=1, the next 32K has load_id=2, etc...). The datetime_stamp 
field shows the time at which the entries were loaded and is the same for 
all 32K entries in a single load.   


How would you efficiently retrieve the first set of positions for the 
current day given the above table definition? 

Example:
Today, positions were loaded into this table at 8am, 10am and 3pm.  At 5pm 
today we want to know what positions were loaded at 8am since that is the 
first load that occurred today.  Note that for any given day, there can be 
different number of loads and the times that the loads occur will vary.
*/

--For sql develper they should think about to creat another table include load_id and time_stamp for the end user
-- instead of putting the time_stamp colunm in the big table to repeat too many times
--option #1.
select * from positions
where load_id = ( select min(load_id)
				from positions
				where convert(date,datetime_stamp)=getdate())

/*我有一个表，其中一部分长这样：
id^company1^company2
1^a^b
2^a^c
3^b^c
4^a^d
5^c^d
6^b^e
7^d^e
8^e^d
9^f^a

我想把company2 == company1的连起来形成chain，比如把第1，3，5，7行连起来形成a
-b-c-d-e的链。
不能是1，3，5，8，company1和company2顺序不能反。
只要最长的chain，比如要a-b-c-d-e，不需要c-d-e。
还有个问题是不知道到底要连多少次，a-b-c-d-e后面可能还有，可能最后是a-b-c-d-e
-f-g。

请问这个能用sql做吗？谢谢。*/

-- answer

with cte_table as (
    select id,company1,company2, 1 AS level, company1+' '+company2 as path
   from your_table
    union all
    select a.id,a.company1,b.company2,a.level+1,a.path+' '+b.company2
    from cte_table a join your_table b  a.company2 = b.company1
    where a.level < 100
)
select top 1 * 
from cte_table
where level <100
order by level desc;

/*adventureworks2012

1.找出10天内下单超过10个的customerid
如果想找出m(10)天内下了超过k(5)次单的顾客，能不能不用sub query实现？
2.找出最近10天内下单超过5个的customerid
*/

--1
use AdventureWorks2012
go

select orderdate from sales.SalesOrderHeader
where customerid=11185


select distinct customerid from 
	(
	select a.customerid, a.salesorderid
	from sales.SalesOrderHeader as a 
	join sales.SalesOrderHeader as b 
	on a.customerid = b.customerid
	and a.orderdate <= b.orderdate
	and a.orderdate >=b.orderdate - 10
	group by a.customerid,a.salesorderid
	having count(*)>=5
	) as result

--2

select customerid 
from sales.SalesOrderHeader
where customerid in (select customerid
					from sales.SalesOrderHeader
					where getdate()-orderdate <=10
					group by CustomerID
					having count(*)>4)





print convert(date,getdate())
print getdate()
print sysdatetime()
select orderdate from sales.salesorderheader
select distinct getdate()-orderdate as a,orderdate,getdate()
from sales.salesorderheader

select distinct getdate()-orderdate as a,
	orderdate,
	convert(date,getdate()) as b,
	convert(date,orderdate) as c,
	convert(date,getdate()) as b - convert(date,orderdate) as c
from sales.salesorderheader



1，介绍你自己
2， 怎样建CUBE group by a,b,c with cube
3，什么样的数据输入FACT TABLE，什么样的进维度 table
4,什么是FACT TABLE, fACTLESS TABLE
Fact Tables are the most import part of Data warehouse.They mainly contains Facts about the business process.
I.e. Sales price of the product which is the part of Sales (business process).
5,介绍你自己做过的ssas 项目
select * from dim_date

/*
4.What is normalization and what are the five normal forms? 
Answer: Normalization is a design procedure for representing data in tabular format. 
The five normal forms are progressive rules to represent the data with minimal redundancy.
5.What are foreign keys? 
Answer: These are attributes of one table that have matching values in a 
primary key in another table, allowing for relationships between tables.
8.What techniques are used to retrieve data from more than one table in a single SQL statement?
Answer: Joins, unions and nested selects are used to retrieve data
10.What is a view and why do we use it?
Answer: A view is a virtual table made up of data from base tables and other views, but not stored separately.
1.What is a subselect? Is it different from a nested select?
Answer: A subselect is a select which works in conjunction with another select. A nested select is a kind 
of subselect where the inner select passes to the where criteria for the outer select.
1.What is referential integrity?
Answer: Referential integrity refers to the consistency that must be maintained between primary and foreign 
keys, for example, every foreign key value must have a corresponding primary key value.
1.Is there any advantage to denormalizing DB2 tables?
Answer: Denormalizing DB2 tables reduces the need for processing 
intensive relational joins and reduces the number of foreign keys
1.If the base table underlying a view is restructured, eg. attributes are added, does 
the application code accessing the view need to be redone?
Answer: No. The table and its view are created anew, but the programs accessing the 
view do not need to be changed if the view and attributes accessed remain the same.
*/
print datediff(year, 0,getdate())
print dateadd(year,datediff(year, 0,getdate()),0)
FirstOfMonth print convert(date,dateadd(month,datediff(Month, 0,getdate()),0))
FirstOfYear print convert(date,dateadd(year,datediff(year, 0,getdate()),0))
select * from sys.all_objects
print datediff(d,'20000101','20300101')

/*
Just got phone interview for a BA position and below is a sql question in this interview:

Customer (custid, name, startdate, enddate)
sample data:
1, Sara, '01/01/2015', '01/01/2016'
2, Peter, '01/02/2015', '01/02/2016'
3. Steve, '01/05/2015', '01/05/2015'
...

The startdate is the date that the customer opens the account and the enddate is the date he close the account.
Now the user wants to get the number of active customers each date in 2015. An active customer means on that specific date the customer's account is open.
expected output:

Active_customer (date, number_of_active_customers)
sample data:
'01/01/2015', 1
'01/02/2015', 2
'01/03/2015', 2
...
I asked if there was a dimdate table and the answer is yes. Then I provided the answer as:
select d.date, (select count(custid) from test as t 
where d.date>=t.Start_date and d.date<=end_date)
from dimdate as d
where d.date>='01/01/2015' and d.date<='01/01/2016'

The interviewer told me that the performance of this query would be bad if there's large amount of data. 
So what is the best answer to this question?
Some other questions in this interview:
A report run good in the past, but one day it became very slow. What are the possible problems? What steps 
you will take to find the cause?
If you can't fix the problem and take it to engineer team, how will you reply to the business users while 
they are waiting?
*/
select d.date, count(custid) as nums
from customer as c join dimdate as d
on d.date >= startdate and d.date<enddate
where d.year=2005
group by startdate
order by startdate

--2, Statistics
--3, Looking into it. Keep you all posted. if possible, give ETA

1.	What is view, stored procedure, function (which 3 kinds of functions)?
/*
View 
Creates a virtual table whose contents (columns and rows) are defined by a query.
 Use this statement to create a view of the data in one or more tables in the database.
  For example, a view can be used for the following purposes:
To focus, simplify, and customize the perception each user has of the database.
As a security mechanism by allowing users to access data through the view, without granting the users 
permissions to directly access the underlying base tables.
To provide a backward compatible interface to emulate a table whose schema has changed.

procesure
Creates a Transact-SQL or common language runtime (CLR) stored procedure in SQL Server, 
Azure SQL Database, Azure SQL Data Warehouse and Parallel Data Warehouse. Stored procedures 
are similar to procedures in other programming languages in that they can:
Accept input parameters and return multiple values in the form of output parameters to the 
calling procedure or batch.
Contain programming statements that perform operations in the database, including calling
 other procedures.
Return a status value to a calling procedure or batch to indicate success or failure 
(and the reason for failure).

built in functions, plus three kinds of user defined functions: scalar, 
multi statement table functions and inline table functions

How many kind of indexes do you know about? 
What are the differences between clustered indexes and non-clustered indexes?
Unique - Guarantees unique values for the column(or set of columns) included in the index
Covering - Includes all of the columns that are used in a particular query (or set of queries), 
allowing the database to use only the index and not actually have to look at the table data to retrieve the results
Clustered - This is way in which the actual data is ordered on the disk, which means if a query 
uses the clustered index for looking up the values, it does not have to take 
the additional step of looking up the actual table row for any data not included in the index.

With a clustered index the rows are stored physically on the disk in the same order as the index.
Therefore, there can be only one clustered index.
With a non clustered index there is a second list that has pointers to the physical rows. 
You can have many non clustered indexes, although each new index will increase the time it takes to write new records.
It is generally faster to read from a clustered index if you want to get back all the columns. 
You do not have to go first to the index and then to the table.
Writing to a table with a clustered index can be slower, if there is a need to rearrange the data.

How do you do query tuning?
Performance tuning 
Guess which columns need indexes that don't have them already
Determine where most of the time is going - is it spinning or waiting?
If it's waiting, find out what it's waiting for, and eliminate that if possible.
If it's spinning, find out what it's doing that it doesn't need to do, and eliminate that if possible.

Database development mistakes made by application developers [closed]
http://stackoverflow.com/questions/621884/database-development-mistakes-made-by-application-developers

What are business keys/natural keys
A natural key (also known as business key) is a type of unique key, found in relational model database 
design, that is formed of attributes that already exist in the real world. It is used in business-related columns.

What are self-referencing tables
A self referencing table is a table where the primary key on the table is also defined as a foreign key.

What is difference between star schema and snow flake
Normalization

Difference of truncate/delete?
If you want to quickly delete all of the rows from a table, and you're really sure that you want to do it, 
and you do not have foreign keys against the tables, then a TRUNCATE is probably going to be faster than a DELETE.
Delete is DML, Truncate is DDL

What is Datamart?
A data mart is the access layer of the data warehouse environment that is used to get data out to the users. 

What is difference between star schema and snow flake?

how to improve report performance
https://blogs.msdn.microsoft.com/tudortr/2004/06/28/microsoft-sql-server-reporting-services-measuring-and-improving-performance/
连续出现3次以上in table log
+----+-----+
| Id | Num |
+----+-----+
| 1  |  1  |
| 2  |  1  |
| 3  |  1  |
| 4  |  2  |
| 5  |  1  |
| 6  |  2  |
| 7  |  2  |
+----+-----+
*/
select distinct a.id
from logs as a
join logs as b on b.id-1=a.id
join logs as c on c.id-2=a.id
where a.num=b.num and a.num=c.num

--emp salary . manager salary
select a.name from
employees as a join employees as b
on a.managerid=b.id
where a.salary > b.salary
--DOB is a string 
print convert(char(10), getDate(), 102)
print replace( convert(char(10), getDate(), 102), '.', '')
print right(replace( convert(char(10), getDate(), 102), '.', ''), 4)

--check duplicates
select email
from person 
group by email
having count(email)>1


Department Highest Salary
with abc as
( select departmentid, row_number() over (partition by departmentid order by salary desc ) as a)
select department, employee, salary from abc join department on departmentid =department.id and a=1

select * from sales.orders
use tsql2012
go
with abc as (select empid, freight,row_number() over (partition by empid order by freight desc) as rownumber
from sales.orders)
select lastname,freight from hr.Employees join abc on abc.empid=hr.Employees.empid
where rownumber =1


/*employee table
id   name   department   manager_id
101  John     A             null
102   Dan     A             101
103   ...     ...           ...

找出手下有至少10人的manager。 小印说用join
*/
select * from hr.Employees
use tsql2012
go
select a.lastname
from hr.Employees as a
join HR.Employees as c
on a.empid= c.mgrid
group by a.lastname
having count(*) >2

with abc as 
(
select empid, mgrid,lastname
from hr.Employees
where empid=2
union all

select b.empid, b.mgrid, b.lastname
from abc as a join hr.Employees as b
on a.empid = b.mgrid

)
select * from abc
/*
Given two tables 
1. Candidate: Id , Name 
2. Vote: Id, CandidateId(this is the id being voted) 
Give query to give the name of the winning candidate
*/
create table candidate
(id int,
name varchar(10)
)
go
create table vote
(id int,
candidateid int)
go

insert into candidate (id,name)
values(1,'a'),
	(2,'b'),
	(3,'c'),
	(4,'d')
go
insert into vote
values
	(1,1),
	(1,2),
	(2,2),
	(2,3),
	(3,2),
	(3,4),
	(4,1),
	(4,4),
	(5,1),
	(5,3),
	(6,1),
	(1,1)

select * from vote
--check for duplicates
select id,candidateid 
from vote 
group by id, candidateid
having count(*)>1
--remove duplicate with cte, partition by 是要以id and candidate同时分组 才能找出id and candidate同时重复的
with abc as 
( select id,candidateid, row_number() over(partition by id,candidateid order by candidateid) as rownumber
from vote)
delete from abc 
where rownumber > 1 
--find the winner
select top(1) name 
from candidate join vote
on candidateid=candidate.id
group by name
order by count(*) desc

drop table vote
drop table candidate
/*
初学 SAS SQL, 请教大家，如果我有2个table， 分别如下
TABLE 1;
ID X1 X2 X3 X4 X5 X6
1  23 56 32 11 22 32
2  33 11 87 53 23 45
3  33 11 87 53 23 45
9  30 21 60 33 44 44


TABLE 2:
ID X1 X2 X3 X4 X5 X6
1  11 51 33 11 22 32
2  32 21 80 53 23 45
3  39 11 87 53 23 40
6  34 24 67 33 43 42
7  30 20 62 33 44 54
*/

create table C as
select (A.X1 - B.X1) as Dif_X1,
       (A.X2 - B.X2) as Dif_X2,
       (A.X3 - B.X3) as Dif_X3,
       (A.X4 - B.X4) as Dif_X4,
       (A.X5 - B.X5) as Dif_X5
    from A 
    left join B 
    on A.ID = B.ID;

/*一个很Nice的老美电话面试，气氛不错。
1.基本知识关于relational database.
Student table contains (Student ID, Student Name)
Class table contains(Class ID,Class name)
How can you join those tables?
这两个tables are dimension tables, you need a fact transaction table to join
those two tables.比如fact table has Student ID, Class Id, startdate, 等
columns. 
2.问如果要加grade,最好加到哪个table? 
应该是transaction table.
3.如果加foreign key for Student ID and Class ID,怎么加？
我第一次答错了，后来想应该加到transaction table.
4.What is fact table and what is dimension table
a Fact table consists of the measurements, metrics or facts of a business process. It is located at the center
 of a star schema or a snowflake schema surrounded by dimension tables. Where multiple fact tables are used, these
 are arranged as a fact constellation schema. A fact table typically has two types of columns: those that contain
 facts and those that are a foreign key to dimension tables. The primary key of a fact table is usually a composite
 key that is made up of all of its foreign keys. Fact tables contain the content of the data warehouse and store
 different types of measures like additive, non additive, and semi additive measures.
 A dimension table is one of the set of companion tables to a fact table
 The fact table contains business facts (or measures), and foreign keys which refer to primary keys 
 in the dimension tables
5.Inner join and outer join,举例子要
INNER JOIN: returns rows when there is a match in both tables.
LEFT JOIN: returns all rows from the left table, even if there are no matches in the right table.
RIGHT JOIN: returns all rows from the right table, even if there are no matches in the left table.
FULL JOIN: returns rows when there is a match in one of the tables.
6.What is Normalization? 这个要给概念，你们自己查。Normalization有至少四个
LEVEL,最好知道前两个。
normalization 消灭重复redundancy数据，保证数据的依赖性make sense
normalization for relational database, data warehouse use denormalization
	没有normalization的问题
		update anomaly 更新异常
		insertion anomaly 插入异常
		deletion anomaly 删除异常
	first normal form --> no repeating or duplicate fields, each cell contains only a single 
						value,each record is unique
	2nd normal form--> no partial dependency of any column on PK要完全依赖,解决方法拆分
	3rd normal form--> no transitive dependency 不存在A->B->C 
后来开始问OLAP和OLTP的区别，问是否在Transaction环境工作过。我胡乱说了一通。
OLAP online analytical processing 理解成data warehouse,需要的是一个信息已经整合或已经聚合的分析系统，
	关注aggregate，数据仓库 denormalization
OLTP online transaction processing 关注的是每一个transaction 树形数据库 广泛应用normalization
data warehouse include 
7.what is slow changing dimension? what is SCD1 and SCD2. (他说一种是把老信
息全部删掉，copy new information over, 另一种是只把新加上的信息加到老信息上
去）
slowly changing dimension(SCD): 销售干半年从dep1换到dep2 如何update，发生频率很低
	0.preservation 
	1.overwrite
	2.version number, effective date
	3.additional column to keep original and current
	4.history tables
8.what is MDX? what is the purpose of MDX?
9.How to use cross join in MDX? 我没有回答出来,虽然我看过。
10.What is MOLAP,ROLAP,HOLAP?
Multidimensional,relational,hybrid
11.How to tune SQL query?
sql profilier then sql tuning advisor ,add non-cluster index
12.What is cluster and non cluster index?
cluster index on primary key
13.SSIS的问题，what is connection manager? 
14.Did you used data flow in SSIS?

后来还有一些其他问题：
15.有没有遇到过request got changed 的情况
16.有没有遇到过request 很模糊的情况
1. A table schema with tables like employee, department, employee_to_
department, project, employee_to_project

1) Select employee from departments where max salary of the department is 
40k
2) Select employee assigned to projects
3) Select employee which have the max salary in a given department
4) Select employee with second highest salary

2. Table has two data entries every day for number of apples and oranges 
sold. write a query to get the difference between the apples… 
*/


select empid
from employee
where departid in (select departid, max(salary)
					from employee 
					group by departid
					having max(salary)=40000)
use TSQL2012
go




/*
Sr. BI developer (SSAS tabular model development and dashboard development)

SQL related:

2.	How many kind of indexes do you know about? 
-->clustered Index non-clustered, column index, special index
What are the differences between clustered indexes and non-clustered indexes? 
-->Performance tuning 
3.	How do you do query tuning?
-->Performance tuning

SSAS tabular model related:
4.	How many types of cube processing modes do you know about or how do you process the cube?
SSAS Cube
5.	What are the main challenges you have faced when developing SSAS tabular models with SQL SERVER 2012?
-->1) In this specific version, what is the challenge part?
2) Difficult parts
3) new features in higher version

6.	How often do you refresh the cubes?
-->depend on business

7.	What is your specific role in the project? 
-->Project 301--LIfe cycle
How do you work with developers?

8.	What kind of dax filter functions have you used?
SSAS Tabluar 

9.	Do you have experience developing tabular models from OLTP databases?
SSAS / Project

10.	How many end users use the model you developed?
--> depends on your business

Sr. BI developer (multidimensional cube development, SSIS and data warehousing focused)
1.	What is 2nf in relational data modeling?
DFP--DB101
2.	What are business keys/natural keys?
DFP
3.	What are the orders to load tables into a data warehouse?
SSIS
4.	What are self-referencing tables?
DFP
5.	What are the differences between clustered indexes and non-clustered indexes?
Dup question 
6.	What is user-defined hierarchies and ragged hierarchies?
SSAS
7.	What are bridge tables?
SSAS/Project
8.	How do you write recursive CTEs? 
DFP
What are the key words between the first select and the second select (Union all)?
Union/Union all
if CTE related, then the first select is virtually a table for the 2nd select
9.	Describe SSIS package configuration, and deployment.
ETL-SSIS
10.	What are the purposes of staging tables?
ETL
11.	Where do your source data come from?
CSV, SQL Server, Access, Oracle

12.	What would you do after deploying the SSIS packages?
Support

13.	What are the new features of SSIS 2012?(Project deployment and package deployment)
ETL-SSIS
14.	How do you create measures in SSAS tabular models?
SSAS
15.	How do you control security in SSRS?
Reporting--SSRS
16.	What is a temporary table? What are table variables?
SQL Development
*/

/*
1) What is the difference between inner and outer join? Explain with example.

	- Inner join returns rows when there is at least one match in both tables
	- Outer join will return matching rows from both tables as well as any unmatched rows from one or both the tables 
	
2) What is the difference between JOIN and UNION?

	- SQL JOIN allows us to “lookup” records on other table based on the given conditions between two tables. 
	- UNION operation allows us to add 2 similar data sets to create resulting data set that contains all the data from the source data sets. Union does not require any condition for joining.
	
3) What is the difference between UNION and UNION ALL?	
	- UNION operation returns only the unique records from the resulting data set  
	- UNION ALL will return all the rows, even if one or more rows are duplicated to each other.

4) What is the difference between WHERE clause and HAVING clause?
	- WHERE clause can only be applied on a static non-aggregated column 
	- we will need to use HAVING for aggregated columns.
	
5) What is the difference among UNION, MINUS and INTERSECT?
	- UNION combines the results from 2 tables and eliminates duplicate records from the result set.
	- MINUS operator when used between 2 tables, gives us all the rows from the first table except the rows which are present in the second table.
	- INTERSECT operator returns us only the matching or common rows between 2 result sets.
	
6) How can we transpose a table using SQL (changing rows to column or vice-versa) ?
	- The usual way to do it in SQL is to use CASE statement or DECODE statement
	
7) How to generate row number in SQL Without ROWNUM
	- SELECT name, sal, (SELECT COUNT(*)  FROM EMPLOYEE i WHERE o.name >= i.name) row_num
		FROM EMPLOYEE o 
		order by row_num
	
8) How to select first 5 records from a table?
	sql server -> SELECT TOP 5 * FROM EMP;
	Oracle -> SELECT * FROM EMP WHERE ROWNUM <= 5;
	Generic -> SELECT  name  FROM EMPLOYEE o
			   WHERE (SELECT count(*) FROM EMPLOYEE i WHERE i.name < o.name) < 5
			   
======================= SQL server questions ==========================================
9) What are DMVs? - 
	Dynamic Management Views (DMVs), are functions that give you information on the state of the server. DMVs, for the most part, are used to monitor the health of a server. They really just give you a snapshot of what’s going on inside the server. They let you monitor the health of a server instance, troubleshoot major problems and tune the server to increase performance			   

10) Define a temp table 
	In a nutshell, a temp table is a temporary storage structure. What does that mean? Basically, you can use a temp table to store data temporarily so you can manipulate and change it before it reaches its destination format.	
	
11) What’s the difference between a local  temp table and a global temp table? 
	Local tables are accessible to a current user connected to the server. These tables disappear once the user has disconnected from the server. Global temp tables, on the other hand, are available to all users regardless of the connection. These tables stay active until all the global connections are closed.
	
12) Describe the difference between truncate and delete 
	Delete command removes the rows from a table based on the condition that we provide with a WHERE clause. 
	Truncate will actually remove all the rows from a table and there will be no data in the table after we run the truncate command.
	
13) What is a view?
	A view is simply a virtual table that is made up of elements of multiple physical or “real” tables. Views are most commonly used to join multiple tables together, or control access to any tables existing in background server processes.	
	
14) What is the default port number for SQL Server? -
	Basically, when SQL Server is enabled the server instant listens to the TCP port 1433.	It can be changed from the Network Utility TCP/IP properties.

15) What are the difference between clustered and a non-clustered index?
	A clustered index is a special type of index that reorders the way records in the table are physically stored. Therefore table can have only one clustered index. The leaf nodes of a clustered index contain the data pages.
	
	A non clustered index is a special type of index in which the logical order of the index does not match the physical stored order of the rows on disk. The leaf node of a non clustered index does not consist of the data pages. Instead, the leaf nodes contain index rows.
	
16) What is PRIMARY KEY?
	A PRIMARY KEY constraint is a unique identifier for a row within a database table. Every table should have a primary key constraint to uniquely identify each row and only one primary key constraint can be created for each table. The primary key constraints are used to enforce entity integrity.
	
17) What is FOREIGN KEY?

	A FOREIGN KEY constraint prevents any actions that would destroy links between tables with the corresponding data values. A foreign key in one table points to a primary key in another table. Foreign keys prevent actions that would leave rows with foreign key values when there are no primary keys with that value. The foreign key constraints are used to enforce referential integrity.
	
	16) What's the difference between a primary key and a unique key?
	Both primary key and unique key enforces uniqueness of the column on which they are defined. 
	But by default primary key creates a clustered index on the column, where are unique creates a non-clustered index by default. 
	Another major difference is that, primary key doesn't allow NULLs, but unique key allows one NULL only.	

18) What are the advantages of using Stored Procedures?
	Stored procedure can reduced network traffic and latency, boosting application performance.
	Stored procedure execution plans can be reused, staying cached in SQL Server's memory, reducing server overhead.
	Stored procedures help promote code reuse.
	Stored procedures can encapsulate logic. You can change stored procedure code without affecting clients.
	Stored procedures provide better security to your data.	

*/