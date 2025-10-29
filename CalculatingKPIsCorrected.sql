-- Once all tables are created, use this script to calc churn rate, AOV, APF, ACL, and CLV.
WITH cutoff_date AS ( -- period over which churn is determined in months and the cut-off date
	SELECT
		FLOOR(EXTRACT(DAY FROM (MAX(invoice_date)-MIN(invoice_date)))/2/30.5) AS churn_interval,
		MIN(invoice_date)+FLOOR(EXTRACT(DAY FROM (MAX(invoice_date)-MIN(invoice_date)))/2)*INTERVAL '1 day' AS middle_date
	FROM orders
	),
starting_customers AS ( -- having determined an interval to use as a cutoff find starting customers
	SELECT customer_id
	FROM orders
	GROUP BY customer_id
	HAVING MIN(invoice_date) < (SELECT middle_date FROM cutoff_date)
	),
churned_customers AS ( -- find customers that no longer have purchases after the cutoff
	SELECT customer_id
	FROM orders
	GROUP BY customer_id
	HAVING MAX(invoice_date) < (SELECT middle_date FROM cutoff_date)
	),
calc_churn_rate AS ( -- calculate churn and account for several months long period
	SELECT 
		(COUNT(churned_customers.customer_id)::FLOAT)/(COUNT(starting_customers.customer_id)::FLOAT)/
		(SELECT churn_interval FROM cutoff_date)*100 AS churn_rate
	FROM churned_customers
	FULL OUTER JOIN starting_customers ON starting_customers.customer_id = churned_customers.customer_id
	),
company_AOV AS ( -- Average Order Value
	SELECT ROUND(SUM(quantity*unit_price)/COUNT(invoice_date),2) AS AOV
	FROM orders
	WHERE quantity > 0 
	),
company_APF AS ( -- Average Purchase Frequency
	SELECT COUNT(invoice_no)/COUNT(DISTINCT customer_id)::numeric AS APF
	FROM orders
	WHERE quantity > 0
	),
company_ACL AS ( -- Average Customer Lifetime
	SELECT ROUND((1/(SELECT churn_rate/100 FROM calc_churn_rate))::numeric, 2) AS ACL
	FROM calc_churn_rate
	)
-- KPIs. 
SELECT
	(SELECT AOV FROM company_AOV) AS AOV,
	(SELECT APF FROM company_APF) AS APF,
	(SELECT ACL FROM company_ACL) AS ACL,
	ROUND((SELECT AOV FROM company_AOV)*
		(SELECT APF FROM company_APF)*
		(SELECT ACL FROM company_ACL),2) AS CLV
FROM customers
GROUP BY 1;

