/*
comma separated values(CSV)
extensible markup language(XML)
javascript object notation(JSON)
all three are just text in various formats
supported type SSIS: https://aka.ms/edx-dat217x-ssis
FTP file transfer protocol
install FTP on machine with Microsoft IIS
DimDates 日期表格
power BI, corrupt data, forecasting, data stale issue, 
predicting, forecasting algorithms, prototype 样板， broadcast广播，

incremental load you insert, update or delete data in destination 
tables that have changed in the source table on a row by row basis

flush and fill is the opposite of incremental loading, it completely refreshes the data, 
by first removing all of the existing data in a destination table and then
refilling that table with the source's current data
*/
--flush and fill
create procedure pFlushAndFillDimCustomers
as
	delete from dimcustomers
	insert into dimcustomers(customer_id, customerName, customerEmail)
		select customerId, customerName, customerEmail
		from customers
go

--incremental load
with changedCustomers
as
(select customerID, customerName, customerEmail from customers--只要其中有一项不同就能被列出来进行update
except 
select customer_ID, customerName, customerEmail from dimcustomers)
update dimcustomers
set customerName = (select customerName from changedCustomers 
					where changedCustomers.customerID = dimcustomers.customer_id),
	customerEmail = (select customerEmail from changedCustomers
					where changedCustomers.customerID = dimcustomers.customer_id)
where customer_id in (select customerId from changedcustomers)

--Merge works for Slowly changing dimention type 1--replace
merge into dimcustomers as T
	using customers as S
	on T.customerID = S.customerID
	when not matched 
		then
			insert 
				values(S.customerID, S.customerName, S.customerEmail)
	when matched
	and S.customerName != T.customerName
	or S.customerEmail != T.customerEmail
		then
			update
				set
					T.customerName= S.customerName ,
					T.customerEmail= S.customerEmail
	when not matched by source
		then
			delete;

-- type 3 add a column show previous values
alter table dimcustomers
	add column previousValue nvarchar(100)
go

merge into dimcustomers as T
	using customers as S
	on T.customerID = S.customerID
	when not matched 
		then
			insert 
				values(S.customerID, S.customerName, S.customerEmail, null--此处变化)
	when matched
	and S.customerName != T.customerName
	or S.customerEmail != T.customerEmail
		then
			update
				set
					T.customerName= S.customerName ,
					T.customerEmail= S.customerEmail，
					T.previousValue = T.customerName --add here
	when not matched by source
		then
			delete;
			
-- type 2 

alter table dimcustomers--加个起始日期
	add changeStartDate datetime null,
		changeEndDate datetime null,
		iscurrent char(1) null check(iscurrent in ('y', 'n'))
		

merge into dimcustomers as T
	using customers as S
	on T.customerID = S.customerID
	when not matched 
		then
			insert 
				values(S.customerID, 
				S.customerName, 
				S.customerEmail,
				getdate(),--changed
				null,--changed
				'y')--changed 
	when matched --under merge under matched insert is not allowed so the changed values need to insert later
	and S.customerName != T.customerName
	or S.customerEmail != T.customerEmail
		then
			update
				set
					T.iscurrent = 'n'
	when not matched by source
		then
		update set 
		changeEndDate = getdate(),
		T.iscurrent = 'n';

Insert into DimCustomers
		( CustomerId
		, CustomerName
		, CustomerEmail
		, ChangeStartDate
		, ChangeEndDate
		, IsCurrent)
		Select CustomerId, CustomerName, CustomerEmail, GetDate(), Null, 'y' from Customers 
		Except 
		Select CustomerId, CustomerName, CustomerEmail, GetDate(), Null, 'y' from DimCustomers

--different between delete and truncate, truncate will reset the primary key identity to the 
--beginning but when there is a foreign key on it truncate is not allowed,
--delete will not reset the primary key whenever you insert it will generate a new number
--truncate is faster

















