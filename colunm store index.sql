--colunmstore index works good for aggregation tables (data warehouse)


create nonClustered colunmstore index nccsix_factinternetSales
on factInternetSales
(
customerkey
,salspersonkey
,productkey
)
where customerkey between 100 to 200


--clustered colunmstore index must contain every all colunm, could not be filtered 
create Clustered colunmstore index ccsix_factinternetSales
on factInternetSales

--colunm index good for stable scan aggregation...
--traditional index good for seeking