-- 2-1 
-- Return orders placed on June 2007
-- Tables involved: TSQL2012 database, Sales.Orders table
select orderid,orderdate
from sales.orders
where month(orderdate)=6 and year(orderdate)=2007

--2-2
-- Return orders placed on the last day of the month
-- Tables involved: Sales.Orders table
select orderid, orderdate
from sales.orders
where month(orderdate) <> month(dateadd(d,1,orderdate))

-- 2-3 
-- Return employees with last name containing the letter 'a' twice or more
-- Tables involved: HR.Employees table
select empid, lastname
from HR.Employees
where lastname like '%a%a%'

-- 2-4 
-- Return orders with total value(qty*unitprice) greater than 10000
-- sorted by total value
-- Tables involved: Sales.OrderDetails table
select orderid, sum(qty*unitprice) as totalvalue
from sales.OrderDetails 
group by orderid
having sum(qty*unitprice)>10000
order by totalvalue

-- 2-5 
-- Return the three ship countries with the highest average freight in 2007
-- Tables involved: Sales.Orders table
select top(3) shipcountry, avg(freight) as avgfreight
from sales.orders
where year(orderdate)=2007 -- orderdate>='20070101' and orderdate< '20080101'
group by shipcountry
order by avgfreight desc
-- offset 0 rows first 3 rows only

--2-6 Calculate row numbers for orders
-- based on order date ordering (using order id as tiebreaker)
-- for each customer separately
-- Tables involved: Sales.Orders table

select custid, orderid, orderdate, 
row_number() over ( partition by custid order by orderdate) as Rownum
from sales.orders

--2-7 Figure out and return for each employee the gender based on the title of courtesy
-- Ms., Mrs. - Female, Mr. - Male, Dr. - Unknown
-- Tables involved: HR.Employees table
select * from hr.Employees

select empid, 
case titleofcourtesy
when 'MS.'then 'Female'
when 'Mrs.' then 'Female'
when 'Mr.' then 'Male'
else 'unknow' 
end as gender
from hr.employees

--2-8 (advanced, optional)
-- Return for each customer the customer ID and region
-- sort the rows in the output by region
-- having NULLs sort last (after non-NULL values)
-- Note that the default in T-SQL is that NULL sort first
-- Tables involved: Sales.Customers table

select custid, region
from Sales.Customers
order by 
	case when region is null then 1 else 0 end


--3-1 
-- Write a query that generates 5 copies out of each employee row
-- Tables involved: TSQL2012 database, Employees and Nums tables
select empid, n
from hr.employees 
cross join nums
where n <=5
order by empid

-- 3-1-2  (Optional, Advanced)
-- Write a query that returns a row for each employee and day 
-- in the range June 12, 2009 ?June 16 2009.
-- Tables involved: TSQL2012 database, Employees and Nums tables

select empid, dateadd(d,n,'20090611') as dt
from HR.Employees
	cross join nums
where n <=5
order by empid

--3-2
-- Return US customers, and for each customer the total number of orders 
-- and total quantities.
-- Tables involved: TSQL2012 database, Customers, Orders and OrderDetails tables
select a.custid, count(distinct a.orderid) as countorders, sum(qty) as sumqty
from sales.orders as a 
	join sales.Customers as b
	on a.custid=b.custid
	join sales.OrderDetails as c
	on a.orderid=c.orderid
where b.country ='USA'
group by a.custid

----3- 3
-- Return customers and their orders including customers who placed no orders
-- Tables involved: TSQL2012 database, Customers and Orders tables
select * from 
sales.Customers as a
left join Sales.orders as b
on a.custid=b.custid

--3-4
-- Return customers who placed no orders
-- Tables involved: TSQL2012 database, Customers and Orders tables
select * from 
sales.Customers as a
left join Sales.orders as b
on a.custid=b.custid
where b.orderid is null

--3-5
-- Return customers with orders placed on Feb 12, 2007 along with their orders
-- Tables involved: TSQL2012 database, Customers and Orders tables

select a.custid, orderdate, orderid
from sales.Customers as a 
join sales.orders as b
on a.custid=b.custid
where orderdate = '20070212'

--3-6 (Optional, Advanced)
-- Return customers with orders placed on Feb 12, 2007 along with their orders
-- Also return customers who didn't place orders on Feb 12, 2007 
-- Tables involved: TSQL2012 database, Customers and Orders tables
select a.custid, orderdate, orderid
from sales.Customers as a 
left join sales.orders as b
on a.custid=b.custid and orderdate = '20070212'

--3-7 (Optional, Advanced)
-- Return all customers, and for each return a Yes/No value
-- depending on whether the customer placed an order on Feb 12, 2007
-- Tables involved: TSQL2012 database, Customers and Orders tables
select a.custid, orderdate,
iif(orderdate='20070212','Yes','No') as yesorno
from sales.Customers as a 
left join 
sales.orders as b
on a.custid= b.custid and orderdate='20070212'

--4-1 
-- Write a query that returns all orders placed on the last day of
-- activity that can be found in the Orders table
-- Tables involved: TSQL2012 database, Orders table
select orderid, orderdate
from Sales.orders
where orderdate= (select max(orderdate) from sales.orders)

--4-2 (Optional, Advanced)
-- Write a query that returns all orders placed
-- by the customer(s) who placed the highest number of orders
-- * Note: there may be more than one customer
--   with the same number of orders
-- Tables involved: TSQL2012 database, Orders table

select custid, orderid, orderdate
from sales.orders
where custid=
	(select top(1) with ties custid
	from Sales.orders
	group by custid
	order by count(orderid) DESC)


	
with abc as 
(select custid, count(orderid) as countorders
from sales.orders
group by custid)
select  a.custid, orderid, orderdate from sales.orders as a
join abc as b on a.custid=b.custid and b.custid=( select top(1) c.custid from abc as c
												order by c.countorders DESC)

with abc as 
(select custid, count(orderid) as countorders
from sales.orders
group by custid)
select  a.custid, orderid, orderdate from sales.orders as a
join abc as b on a.custid=b.custid and b.custid=( select c.custid from abc as c
												order by c.countorders DESC
												offset 0 rows fetch first 1 rows onl
--4-3
-- Write a query that returns employees
-- who did not place orders on or after May 1st, 2008
-- Tables involved: TSQL2012 database, Employees and Orders tables
select empid
from hr.Employees
where empid not in (select empid from sales.orders
					where orderdate >='20080501')

-- 4-4
-- Write a query that returns
-- countries where there are customers but not employees
-- Tables involved: TSQL2012 database, Customers and Employees tables
select * from Sales.Customers
select * from hr.Employees
select distinct country 
from sales.Customers
where country not in ( select country from hr.Employees)



-- 4-5
-- Write a query that returns for each customer
-- all orders placed on the customer's last day of activity
-- Tables involved: TSQL2012 database, Orders table

select custid, orderdate
from sales.orders as a 
where orderdate= (select max(orderdate)
					from sales.orders as b
					where a.custid=b.custid)
order by custid

--4-6
---Write a query that returns customers
-- who placed orders in 2007 but not in 2008
-- Tables involved: TSQL2012 database, Customers and Orders tables
select custid, companyname
from sales.Customers as a 
where a.custid in (select b.custid from sales.orders as b
				where year(orderdate)='2007')and 
	  a.custid not in 
				(select c.custid from sales.orders as c where year(orderdate)='2008')

--4-7 (Optional, Advanced)
-- Write a query that returns customers
-- who ordered product 12
-- Tables involved: TSQL2012 database,
-- Customers, Orders and OrderDetails tables

select companyname, a.custid
from sales.Customers as a 
where a.custid in(select b.custid from	
				sales.orders as b
				where b.orderid in (select c.orderid
									from sales.OrderDetails as c 
									where productid=12)) 

-- 4-8 (Optional, Advanced)
-- Write a query that calculates a running total qty
-- for each customer and month using subqueries
-- Tables involved: TSQL2012 database, Sales.CustOrders view
select a.custid, a.ordermonth, a.qty,(select sum(b.qty) from sales.custorders as b
                                      where b.custid=a.custid and
									  b.ordermonth <=a.ordermonth)  as runqty
from sales.Custorders as a
order by a.custid, a.ordermonth








--5-1
-- Write a query that returns the maximum order date for each employee
-- Tables involved: TSQL2012 database, Sales.Orders table

select empid, max(orderdate) as maxorderdate
from sales.orders
group by empid

--5-1-2
-- Encapsulate the query from exercise 1-1 in a derived table
-- Write a join query between the derived table and the Sales.Orders
-- table to return the Sales.Orders with the maximum order date for 
-- each employee
-- Tables involved: Sales.Orders

select a.empid, orderid, orderdate,custid
from sales.orders as a 
	join (select empid, max(orderdate) as maxorderdate
	from sales.orders
	group by empid) as b
	on a.empid= b.empid and a.orderdate = maxorderdate

--5-2-1
-- Write a query that calculates a row number for each order
-- based on orderdate, orderid ordering
-- Tables involved: Sales.Orders

select custid, orderdate, orderid,
	row_number() over(order by orderdate, orderid) as rownum
from sales.orders

-- 5-2-2
-- Write a query that returns rows with row numbers 11 through 20
-- based on the row number definition in exercise 2-1
-- Use a CTE to encapsulate the code from exercise 2-1
-- Tables involved: Sales.Orders
with abc as 
(select custid, orderdate, orderid,
	row_number() over(order by orderdate, orderid) as rownum
from sales.orders)
select * from abc
where rownum between 11 and 20
--option #2 
--order by rownum
--offset 10 rows fetch next 10 rows only

--5-3 (Optional, Advanced)
-- Write a solution using a recursive CTE that returns the 
-- management chain leading to Zoya Dolgopyatova (employee ID 9)
-- Tables involved: HR.Employees
with abc as
(select empid, mgrid, firstname, lastname
	from hr.Employees
	where empid=9
union all
select b.empid, b.mgrid, b.firstname, b.lastname
	from abc as a join
	HR.Employees as b
	on a.mgrid=b.empid)

select * from abc

--5-4-1
-- Create a view that returns the total qty
-- for each employee and year
-- Tables involved: Sales.Orders and Sales.OrderDetails

create view abc 
as 
select empid, year(orderdate) as orderyear, sum(qty) as totalqty
from sales.orders as a
join sales.OrderDetails as b
on a.orderid=b.orderid
group by empid, year(orderdate)


if object_id ('abc') is not null
drop view abc 

-- 5-4-2 (Optional, Advanced)
-- Write a query against Sales.VEmpOrders
-- that returns the running qty for each employee and year using subqueries
-- Tables involved: TSQL2012 database, Sales.VEmpOrders view
-- join not working 
--when orderyear in a = 2006 then in b orderyear =2006
--when orderyear in a = 2007 then in b orderyear = 2006 and 2007 because of "<="

select empid, orderyear, totalqty,
	( select sum(totalqty)
	from abc as a
	where  a.empid= b.empid and a.orderyear<=b.orderyear)  as runningtotal  
from abc as b 
order by empid, orderyear

--5-5-1
-- Create an inline function that accepts as inputs
-- a supplier id (@supid AS INT), 
-- and a requested number of products (@n AS INT)
-- The function should return @n products with the highest unit prices
-- that are supplied by the given supplier id
-- Tables involved: Production.Products
select * from Production.Products
create function abc (@supid int, @n int) 
returns table
as 
return 
select top(@n) productid, productname, unitprice
from Production.Products
where supplierid=@supid
order by unitprice desc

IF OBJECT_ID('abc') IS NOT NULL
  DROP function abc;

-- 5-5-2
-- Using the CROSS APPLY operator
-- and the function you created in exercise 5-1,
-- return, for each supplier, the two most expensive products

SELECT S.supplierid, S.companyname, P.productid, P.productname, P.unitprice
FROM Production.Suppliers AS S
  CROSS APPLY abc(S.supplierid, 2) AS P;

--6-1 
--Write a query that generates a virtual auxiliary table of 10 numbers
-- in the range 1 through 10
-- Tables involved: no table

select 1 as n
union all select 2
union all select 3
union all select 4
union all select 5
union all select 6
union all select 7
union all select 8
union all select 9
union all select 10

--6-2
-- Write a query that returns customer and employee pairs 
-- that had order activity in January 2008 but not in February 2008
-- Tables involved: TSQL2012 database, Orders table

select custid, empid 
from sales.orders as a 
where exists (select b.orderid from sales.orders as b
						where a.custid=b.custid and a.empid=b.empid and 
						month(b.orderdate)=1 and year(b.orderdate)=2008)
		and not exists (select c.orderid from sales.orders as c
						where a.custid=c.custid and a.empid=c.empid and 
						month(c.orderdate)=2 and year(c.orderdate)=2008)
order by custid


select custid, empid 
from sales.orders
where (month(orderdate)=1 and year(orderdate)=2008)

except

select distinct custid, empid 
from sales.orders
where month(orderdate)=2 and year(orderdate)=2008
order by custid

-- 6-3
-- Write a query that returns customer and employee pairs 
-- that had order activity in both January 2008 and February 2008
-- Tables involved: TSQL2012 database, Orders table

select custid, empid 
from sales.orders
where (month(orderdate)=1 and year(orderdate)=2008)

intersect

select distinct custid, empid 
from sales.orders
where month(orderdate)=2 and year(orderdate)=2008
order by custid

--6-4
-- Write a query that returns customer and employee pairs 
-- that had order activity in both January 2008 and February 2008
-- but not in 2007
-- Tables involved: TSQL2012 database, Orders table

(select custid, empid 
from sales.orders
where (month(orderdate)=1 and year(orderdate)=2008)

intersect

select distinct custid, empid 
from sales.orders
where month(orderdate)=2 and year(orderdate)=2008)

except
select distinct custid, empid 
from sales.orders
where year(orderdate)=2007
order by custid

--6-5
-- You are given the following query:
SELECT country, region, city
FROM HR.Employees

UNION ALL

SELECT country, region, city
FROM Production.Suppliers;

-- You are asked to add logic to the query 
-- such that it would guarantee that the rows from Employees
-- would be returned in the output before the rows from Suppliers,
-- and within each segment, the rows should be sorted
-- by country, region, city
-- Tables involved: TSQL2012 database, Employees and Suppliers tables

select country, region, city
from (select 1 as sorting,country, region, city
	from hr.Employees
union all
select 2 ,country, region, city
	from Production.Suppliers) as a
order by sorting,country

SELECT val, ROW_NUMBER() OVER(ORDER BY val) AS rownum
FROM Sales.OrderValues
GROUP BY val;
-- group by function after row_number could remove the duplicated rows

--running sum with over clause
select * from sales.orders
select distinct empid, year(orderdate) as ordermonth, --convert(varchar(20),freight) as freight,
	avg(freight) over(partition by empid order by year(orderdate)) as avgyear,
	sum(freight) over(partition by empid order by year(orderdate)) as sumyear
from sales.orders
where empid in (1,2,3)

create table orders
(
orderid int not null,
orderdate date not null,
empid int not null,
custid varchar(5) not null,
qty int not null,
constraint pk_orders primary key (orderid)
)
insert into dbo.orders (orderid, orderdate, empid,custid,qty)
values 
(30001, '20070802', 3, 'A', 10),
(10001, '20071224', 2, 'A', 12),
(10005, '20071224', 1, 'B', 20),
(40001, '20080109', 2, 'A', 40),
(10006, '20080118', 1, 'C', 14),
(20001, '20080212', 2, 'B', 12),
(40005, '20090212', 3, 'A', 10),
(20002, '20090216', 1, 'C', 20),
(30003, '20090418', 2, 'B', 15),
(30004, '20070418', 3, 'C', 22),
(30007, '20090907', 3, 'D', 30);

print getdate()


--second highest
--opt#1
select * from sales.EmpOrders
with abc as
(select empid,ordermonth, val,DENSE_RANK() over (order by val desc) as rr
from sales.EmpOrders)
select * from abc
where rr=2
--Opt#2
select a.val
from sales.EmpOrders as a
where 2=(select count(*) from
		sales.EmpOrders as b 
		where a.val<=b.val)
--every emp's highest val
with abc as
(select empid,ordermonth, val,DENSE_RANK() over (partition by empid order by val desc) as rr
from sales.EmpOrders)
select * from abc
where rr=2

--who never order
--1
select a.custid
from sales.Customers as a
left join sales.orders as b
on a.custid=b.custid
where b.custid is null
--2
select a.custid
from sales.Customers as a
where not exists (select 1 from	
				sales.orders as b
				where a.custid=b.custid)
--3
select a.custid
from sales.Customers as a
where a.custid not in
	(select b.custid from sales.orders as b)


/*department highest salary
The Employee table holds all employees. Every employee has an Id, a salary, and there is also a column for the department Id.

+----+-------+--------+--------------+
| Id | Name  | Salary | DepartmentId |
+----+-------+--------+--------------+
| 1  | Joe   | 70000  | 1            |
| 2  | Henry | 80000  | 2            |
| 3  | Sam   | 60000  | 2            |
| 4  | Max   | 90000  | 1            |
+----+-------+--------+--------------+
The Department table holds all departments of the company.

+----+----------+
| Id | Name     |
+----+----------+
| 1  | IT       |
| 2  | Sales    |
+----+----------+
*/
SELECT D.Name AS Department ,E.Name AS Employee ,E.Salary 
FROM
	Employee E,
	(SELECT DepartmentId,max(Salary) as max FROM Employee GROUP BY DepartmentId) T,
	Department D
WHERE E.DepartmentId = T.DepartmentId 
  AND E.Salary = T.max
  AND E.DepartmentId = D.id

SELECT D.Name,A.Name,A.Salary 
FROM 
	Employee A,
	Department D   
WHERE A.DepartmentId = D.Id 
  AND NOT EXISTS 
  (SELECT 1 FROM Employee B WHERE B.Salary > A.Salary AND A.DepartmentId = B.DepartmentId) 

SELECT D.Name AS Department ,E.Name AS Employee ,E.Salary 
from 
	Employee E,
	Department D 
WHERE E.DepartmentId = D.id 
  AND (DepartmentId,Salary) in 
  (SELECT DepartmentId,max(Salary) as max FROM Employee GROUP BY DepartmentId)

--top3 salary
/*The Employee table holds all employees. Every employee has an Id, and there is also a column for the department Id.

+----+-------+--------+--------------+
| Id | Name  | Salary | DepartmentId |
+----+-------+--------+--------------+
| 1  | Joe   | 70000  | 1            |
| 2  | Henry | 80000  | 2            |
| 3  | Sam   | 60000  | 2            |
| 4  | Max   | 90000  | 1            |
| 5  | Janet | 69000  | 1            |
| 6  | Randy | 85000  | 1            |
+----+-------+--------+--------------+
The Department table holds all departments of the company.

+----+----------+
| Id | Name     |
+----+----------+
| 1  | IT       |
| 2  | Sales    |
+----+----------+
Write a SQL query to find employees who earn the top three salaries in each of the department. 
For the above tables, your SQL query should return the following rows.*/
select d.Name Department, e1.Name Employee, e1.Salary
from Employee e1 
join Department d
on e1.DepartmentId = d.Id
where 3 > (select count(distinct(e2.Salary)) 
                  from Employee e2 
                  where e2.Salary > e1.Salary 
                  and e1.DepartmentId = e2.DepartmentId
                  );

--delete duplicate
/*
Write a SQL query to delete all duplicate email entries in a table named Person, keeping only unique emails based on its smallest Id.

+----+------------------+
| Id | Email            |
+----+------------------+
| 1  | john@example.com |
| 2  | bob@example.com  |
| 3  | john@example.com |
+----+------------------+
Id is the primary key column for this table.
For example, after running your query, the above Person table should have the following rows:

+----+------------------+
| Id | Email            |
+----+------------------+
| 1  | john@example.com |
| 2  | bob@example.com  |
+----+------------------+
*/
DELETE p1
FROM Person p1, Person p2
WHERE p1.Email = p2.Email AND
p1.Id > p2.Id

select datediff(d,getdate(),orderdate) as a
from sales.orders
where orderid=(select min(orderid) from sales.orders)

select request_at as 'Day',(select count(*) from a join b on
where banned='No' and client_id = users_id and driver_id=user_id
where request_at between '2013-10-01' and '2013-10-03'
group by request_at

select 
t.Request_at Day, 
round(sum(case when t.Status like 'cancelled_%' then 1 else 0 end)/count(*),2) Rate
from Trips t 
inner join Users u 
on t.Client_Id = u.Users_Id and u.Banned='No'
where t.Request_at between '2013-10-01' and '2013-10-03'
group by t.Request_at