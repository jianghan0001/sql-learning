[contactFullName] = convert(nvarchar(200), [firstName] + ' ' [lastName]),
[salesPersonAlias] = cast(substring([salesPerson], patIndex(%/%, [salesPerson]) + 1， 256）as nvarchar(200))
--substring(在哪搞，起点，搞多长）
--patindex(%标记%，在哪搞） 给出标记的index位置 楼上指的是从标记出+1开始搞 去掉‘/’
--cast([column] as type)
--convert(type, [column])
--null --> unavaliable not applicable unknown corrupt not defined
-- case when then else end, iif(t3.[size] is null, 'one size', t3.[size]) (条件，是的话，不是的话)
-- isnull(where, change to) 
 
declare @startDate date
declare @endDate date
select @startDate = '01-01-' + convert(nvarchar(100), year(min(orderdate)))
	from salesorderheader
select @endDate = '12-31-'+ convert(nvarchar(100), year(max(orderdate)))
	from salesOrderHeader


declare @dateInprocess date = @startDate

while @dateInprocess <= @endDate
	begin
	insert into dimDate
	values(
		convert(nvarchar(100) , @dateInprocess, 112) --[calendarDateKey],
		dateName(weekday, @dateInprocess) + ', ' + convert(nvarchar(50), @dateInprocess),
		set @dateInprocess = dateadd(d, 1 , @dateInprocess)
	end

create procedure pETLProcedureTemplate
as
begin
declare @RC int  = 0
	begin try
		begin transaction
		select 3/0
		commit transaction
		set @RC = 100
	end try
	begin catch
	rollback tran
	set @RC = -100
	end catch
	return @RC
end


























	