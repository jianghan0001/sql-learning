--how database structured  database-file group- data file- extent(8 pages)- page
-- disc I/O is always the key performance metric for a database system
--triping 分流 parallel 并行的概念， data store at mutiple disc and parallel cumputing 
--hardware 1.SSD, azure 2. RAID system(how data strored) RAID 0 use mutiple drive(striple speed also risk of lossing data), RAID 5(1 last drive do checksum to make up for the down drive)
--RAID 1 (make a mirror, store data 2 copy for 1 set of data)
--RAID 1 0 ( mirror then stripe) 2 mirror with 2 drive
--cost benefit-trade off(花钱办事), high performance also resiliency, trade off


dbcc ind('adventrueworks2016', 'person.address',1) --show details(pageId.....) for database adventrueworks2016-person.address
dbcc traceon('3604')--need to be turn on first
go
dbcc page('adventrueworks2016',1,10630,3) --detail for pageid=10630

--logic I/O(from cache, memory), physical I/O(lower better), buffer cache hit ratio(persent, higher better)
--single file vs multiple files(legacy file vs current file) striple cross multiple files
--memory faster than disc, 
--cache wormer monthly report, the end of month move data into cache in memory, faster for report on the begginning of the month,
-- auto-grow turn on and auto-shrink turn off
--tempdb(heavily used)-seperate disc， auto grow, enough capacity,         
use shrinktest
exec sp_spaceused             
--execute sequence for sql query 1.from 2.on 3.join 4.where 5.group by 6.with(cube/rollup) 7.having 8.select 9.distinct 10.order by 11.top    
--filter the data as much as possible as early as possible to get better performance          
--1 parsing--check syntax 2 binding--locate object 3 query optimization 4 query execution 
--execution plan(estimate, actual, live query statistics)
--seek vs scan        
--join 1. nested loop(value1 from table 1 to match table 2(small table, low number of rows) value) 2. merge join(2 sorted table) 3.hash match join
--分步sort 先找第一个字母m然后match第二个字母n        
--parallel processing  
--estimate execution plan may have suggestion for improvement  
--sp_recompile 'object'  remove cache plans                                                                      