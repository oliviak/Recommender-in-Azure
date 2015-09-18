SELECT o.customerkey
	,o.IncomeGroup
	,o.Region
	,i.Model
	,count(i.Model) as FreqBuy 
from [dbo].[vAssocSeqOrders] o join [dbo].[vAssocSeqLineItems] i 
on o.OrderNumber = i.OrderNumber
group by  
	i.Model,
	o.CustomerKey,
	o.IncomeGroup,
	o.Region
order by FreqBuy desc