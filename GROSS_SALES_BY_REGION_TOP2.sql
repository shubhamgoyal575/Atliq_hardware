with cte1 as (SELECT 
	n.market,c.region,
	ROUND(SUM(gross_price_total)/1000000,2) AS gross_sale_mln
from net_sales n
	JOIN dim_customer c
    ON c.customer_code=n.customer_code
WHERE 
	n.fiscal_year=2021
GROUP BY n.market,c.region),

cte2 as (select * ,
		dense_rank() over(partition by region order by gross_sale_mln desc) as rnk
	from cte1)

select * from cte2
where rnk<=2;


