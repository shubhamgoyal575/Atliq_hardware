# AtliQ Hardware Sales Analysis
## Project Overview
AtliQ Hardware, a consumer electronics company, aims to enhance its business intelligence by generating comprehensive reports using SQL. This project focuses on creating reports for top customers, market products, forecast accuracy, and monthly gross sales. Additionally, views will be created for post and pre-invoice sales, as well as net sales.

## Objectives
-Generate SQL reports for top customers, market products, forecast accuracy, and monthly gross sales.
-Create SQL views for post and pre-invoice sales and net sales.
-Provide actionable insights based on the generated reports.

## Tools and Technologies
-Data Analysis: SQL
-Database: MySQL or any SQL-compatible database

## Project Structure
### 1. SQL Reports
-**Top N Country**

CREATE DEFINER=`root`@`localhost` PROCEDURE `top_n_countries_by_sales`(
	in_fiscal_year INT,
    in_top_n INT
)
BEGIN
	SELECT 
		market,
		ROUND(SUM(net_sale)/1000000,2) AS net_sale
	from net_sales
	WHERE fiscal_year=in_fiscal_year
	GROUP BY market
	ORDER BY net_sale DESC
	LIMIT in_top_n;
END

-**Top N Market Products**
sql
CREATE DEFINER=`root`@`localhost` PROCEDURE `top_n_product_by_sales`(
	in_market VARCHAR(20),
    in_fiscal_year INT,
    in_top_n INT
)
BEGIN
	SELECT 
		product,
		ROUND(SUM(net_sale)/1000000,2) AS net_sale
	from net_sales 
	WHERE fiscal_year=in_fiscal_year
			AND market=in_market
    GROUP BY product
	ORDER BY net_sale DESC
	LIMIT in_top_n;
END

-**Forecast Accuracy**
CREATE DEFINER=`root`@`localhost` PROCEDURE `forecast_accuracy`(
		in_fiscal_year int
)
BEGIN
	with forecast_err as (select 
							customer_code,
							sum(sold_quantity) as total_sold_quantity,
							sum(forecast_quantity) as total_forecast_quantity,
							sum(forecast_quantity-sold_quantity) as net_error,
							sum(forecast_quantity-sold_quantity)*100/sum(forecast_quantity) as net_error_pct,
							sum(abs(forecast_quantity-sold_quantity)) as abs_error,
							sum(abs(forecast_quantity-sold_quantity))*100/sum(forecast_quantity) as abs_error_pct
						from fact_actual_est 
						where fiscal_year=in_fiscal_year
						group by customer_code)

	select 
		c.customer,
		c.market,
		f.*,
		if(abs_error_pct>100,0,100-abs_error_pct) as forecast_accuracy
	from forecast_err f
	join dim_customer c 
	using(customer_code)
	order by forecast_accuracy;
END

-**Monthly Gross Sales**
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_monthly_gross_sales_`(
	c_code INT
)
BEGIN
	SELECT
	s.date,
    ROUND(SUM(s.sold_quantity*g.gross_price),2) AS gross_price_total
	FROM fact_sales_monthly s
	JOIN fact_gross_price g 
	ON s.product_code=g.product_code
	AND g.fiscal_year=get_fiscal_year(s.date)
WHERE customer_code=c_code
GROUP BY date 
ORDER BY date;
END

## Set Up Database:
-Import the provided database schema and data into your SQL database.
-Use the SQL scripts in the sql directory to create the necessary procedures and views.

## Generate Reports:

Execute the stored procedures to generate reports for top customers, market products, forecast accuracy, and monthly gross sales.

## Verify Views:
Query the views to ensure they return the correct data for post and pre-invoice sales, as well as net sales.

## Files and Resources
SQL Scripts: SQL scripts for stored procedures and views.
Database Schema: Database schema and sample data for analysis.
