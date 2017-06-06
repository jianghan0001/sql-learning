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

--instead of trigger
create trigger tr_productreview_delete
on product.productreview
instead of delete as 
begin
	update pr set pr.discontinued = 1
	from product.productreview as pr
	join deleted as d
	on pr.productReviewID = d.productReviewID
end	