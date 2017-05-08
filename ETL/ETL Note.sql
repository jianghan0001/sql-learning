/*supported type SSIS: https://aka.ms/edx-dat217x-ssis
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

--Merge
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

