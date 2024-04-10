with cte1 as (SELECT 
	c.region, c.customer,
	ROUND(SUM(net_sale)/1000000,2) AS net_sale_mln
from net_sales n
	JOIN dim_customer c
    ON c.customer_code=n.customer_code
WHERE 
	n.fiscal_year=2021
GROUP BY c.region, c.customer)

select * ,
	net_sale_mln*100/sum(net_sale_mln) over(partition by region) as pct
from cte1
ORDER BY net_sale_mln DESC;


