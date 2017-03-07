/* 
My query is as follows, and contains a subquery within it:

 select count(distinct dNum)
 from myDB.dbo.AQ
 where A_ID in 
  (SELECT DISTINCT TOP (0.1) PERCENT A_ID, 
            COUNT(DISTINCT dNum) AS ud 
 FROM         myDB.dbo.AQ
 WHERE     M > 1 and B = 0 
 GROUP BY A_ID ORDER BY ud DESC)
The error I am receiving is ...

Only one expression can be specified in the select list when the subquery is not
introduced with EXISTS.`
When I run the sub-query alone, it returns just fine, so I am assuming there is some issue with the main query?


answer

You can't return two (or multiple) columns in your subquery to do the comparison in the WHERE A_ID IN (subquery) clause - which column is it supposed to compare A_ID to? Your subquery must only return the one column needed for the comparison to the column on the other side of the IN. So the query needs to be of the form:

SELECT * From ThisTable WHERE ThisColumn IN (SELECT ThatColumn FROM ThatTable)
You also want to add sorting so you can select just from the top rows, but you don't need to return the COUNT as a column in order to do your sort; sorting in the ORDER clause is independent of the columns returned by the query.

Try something like this:

select count(distinct dNum) 
from myDB.dbo.AQ 
where A_ID in
    (SELECT DISTINCT TOP (0.1) PERCENT A_ID
    FROM myDB.dbo.AQ 
    WHERE M > 1 and B = 0
    GROUP BY A_ID 
    ORDER BY COUNT(DISTINCT dNum) DESC)
*/


/*identify rows with not null values in sql

How to retrieve all rows having value in a status column (not null) group by ID column.

Id      Name    Status
1394    Test 1  Y
1394    Test 2  null    
1394    Test 3  null    
1395    Test 4  Y
1395    Test 5  Y
I wrote like select * from table where status = 'Y'. 
It brings me 3 records, how to add condition to bring in only last 2? 
the 1394 ID have other 2 records, which status is null.

option1
select * from mytable
where status = 'Y'
and id not in (select id from mytable where status is null)

option 2 不太懂
select id
from t
group by id
having min(status = 'Y' then 1 else 0 end) = 1
*/
--where right(replace( convert(char(10), getDate(), 102), '.', ''), 4) = right(dob, 4) 
--如果dob是string类型的话用上述语句转换成CHAR之后用right选后四位（yyyymmdd）就可以找出同月同日了（mmdd）


/*一道面试题，第一个table employee,第二个table department. 现在要用sql找出每一
个department里工资最高的人。答案在后面可我看不懂那个e1.name as employee是啥
意思？e2又是从哪冒出来的? 谢谢啦

employee
+----+-------+--------+--------------+
| Id | Name  | Salary | DepartmentId |
+----+-------+--------+--------------+
| 1  | Joe   | 70000  | 1            |
| 2  | Henry | 80000  | 2            |
| 3  | Sam   | 60000  | 2            |
| 4  | Max   | 90000  | 1            |
+----+-------+--------+--------------+

department
+----+----------+
| Id | Name     |
+----+----------+
| 1  | IT       |
| 2  | Sales    |
+----+----------+


select Department.Name as Department, e1.Name as Employee, Salary
from Employee e1, Department
where e1.DepartmentId = Department.Id 
and
Salary >= ALL (select Salary from Employee e2 where e2.DepartmentId = e1.
DepartmentId);

my answer
with abc as (select custid, rank() over (partition by custid order by freight)as a
from sales.orders)
select * from abc
where a=1
*/
select * from sales.orders

print convert(char(10), getDate(), 102)
print getdate()