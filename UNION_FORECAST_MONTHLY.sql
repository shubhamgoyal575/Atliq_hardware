select 
	s.date as date,
    s.customer_code as customer_code,
    s.product_code as product_code,
    s.sold_quantity as sold_quantity,
    f.forecast_quantity as forecast_quantity
from fact_sales_monthly s
left join fact_forecast_monthly f
using(date,customer_code,product_code)

union

select 
	f.date as date,
    f.customer_code as customer_code,
    f.product_code as product_code,
    s.sold_quantity as sold_quantity,
    f.forecast_quantity as forecast_quantity
from fact_forecast_monthly f
right join fact_sales_monthly s
using(date,customer_code,product_code)