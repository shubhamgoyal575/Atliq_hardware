-- Month
-- Product Name
-- Variant 
-- Sold Quantity
-- Gross Price per Item
-- Gross price Total


SELECT 
	s.date,s.product_code,
    p.product,p.variant,g.gross_price,s.sold_quantity,
    g.gross_price*s.sold_quantity as Total
	FROM fact_sales_monthly s 
		JOIN dim_product p 
		ON s.product_code=p.product_code
        JOIN fact_gross_price g
        ON s.product_code=g.product_code
        AND g.fiscal_year=get_fiscal_year(s.date)
	
	WHERE customer_code = 90002002
	AND get_fiscal_year(date)=2021
    ORDER BY date 
;


SELECT
	s.date,
    ROUND(SUM(s.sold_quantity*g.gross_price),2) AS gross_price_total
	FROM fact_sales_monthly s
	JOIN fact_gross_price g 
	ON s.product_code=g.product_code
	AND g.fiscal_year=get_fiscal_year(s.date)
WHERE customer_code=90002002
GROUP BY date 
ORDER BY date;


SELECT
	get_fiscal_year(s.date) AS FY,
    ROUND(SUM(s.sold_quantity*g.gross_price),2) AS gross_price_total
	FROM fact_sales_monthly s
	JOIN fact_gross_price g 
	ON s.product_code=g.product_code
	AND g.fiscal_year=get_fiscal_year(s.date)
WHERE customer_code=90002002
GROUP BY FY
ORDER BY FY;



SELECT 
	get_fiscal_year(s.date) AS fy,
	c.market,
	SUM(s.sold_quantity) AS total_sold_qty
	FROM fact_sales_monthly s
	JOIN dim_customer c
	ON s.customer_code=c.customer_code
WHERE 
	market="india"
GROUP BY c.market,fy;



SELECT
	s.date,s.product_code,s.sold_quantity,g.gross_price,
    ROUND(SUM(s.sold_quantity*g.gross_price),2) AS gross_price_total,	
    pre.pre_invoice_discount_pct
FROM fact_sales_monthly s
	JOIN fact_gross_price g 
		ON s.product_code=g.product_code
		AND g.fiscal_year=get_fiscal_year(s.date)
    JOIN fact_pre_invoice_deductions pre
		ON pre.customer_code=s.customer_code
		AND get_fiscal_year(s.date)=pre.fiscal_year
WHERE 
	get_fiscal_year(s.date)=2021;
    
    
    
SELECT
	s.date, s.product_code, 
    p.product,p.variant,
    s.sold_quantity,
    g.gross_price,
    ROUND(s.sold_quantity*g.gross_price,2) AS gross_price_total,	
    pre.pre_invoice_discount_pct
FROM fact_sales_monthly s
	JOIN dim_product P 
    ON p.product_code=s.product_code
    JOIN fact_gross_price g 
		ON s.product_code=g.product_code
		AND g.fiscal_year=get_fiscal_year(s.date)
    JOIN fact_pre_invoice_deductions pre
		ON pre.customer_code=s.customer_code
		AND get_fiscal_year(s.date)=pre.fiscal_year
WHERE 
	get_fiscal_year(s.date)=2021;



WITH cte1 AS (SELECT
		s.date, s.product_code, 
		p.product,p.variant,
		s.sold_quantity,
		g.gross_price,
		ROUND(s.sold_quantity*g.gross_price,2) AS gross_price_total,	
		pre.pre_invoice_discount_pct
	FROM fact_sales_monthly s
		JOIN dim_product P 
			ON p.product_code=s.product_code
		JOIN fact_gross_price g 
			ON s.product_code=g.product_code
			AND g.fiscal_year=s.fiscal_year
		JOIN fact_pre_invoice_deductions pre
			ON pre.customer_code=s.customer_code
			AND s.fiscal_year=pre.fiscal_year)
            
            
            
            SELECT * ,
				ROUND((gross_price_total-gross_price_total*pre_invoice_discount_pct),2) AS net_invoice_sales
			FROM cte1;
            
		
        

SELECT* ,
	ROUND((1-pre_invoice_discount_pct)*gross_price_total,2) AS net_invoice_sales,
    (discounts_pct+other_deductions_pct) AS post_invoice_deduction
FROM pre_invoice_sales_deduction pre
	JOIN fact_post_invoice_deductions pos 
		ON 	pre.customer_code=pos.customer_code
        AND pre.product_code=pos.product_code
        AND pre.date=pos.date