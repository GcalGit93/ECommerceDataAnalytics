-- Once all 4 tables are created, use this script to calc churn rate, AOV, APF, ACL, and CLV.
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
customer_AOV AS ( -- Average Order Value
	SELECT customer_id, 
		ROUND(SUM(quantity*unit_price)/COUNT(invoice_date),2) AS AOV
	FROM orders
	GROUP BY customer_id
	ORDER BY AOV DESC
	),
customer_APF AS ( -- Average Purchase Frequency
	SELECT customer_id, 
		CASE WHEN num_seconds = 0 THEN NULL
		ELSE ROUND(1/(num_seconds/(30.5*24*60*60)), 2) END AS APF
	FROM spend_frequency
	),
customer_ACL AS ( -- Average Customer Lifetime
	SELECT customer_id,
    ROUND((1/(SELECT churn_rate/100 FROM calc_churn_rate))::numeric, 2) AS ACL
	FROM customers
	)
-- KPIs. MIN() is used to allow aggregation to find time as customer to filter out short-term, high-frequency customers
SELECT customers.customer_id,
	FLOOR(EXTRACT(EPOCH FROM (MAX(invoice_date)-MIN(invoice_date)))/(30.5*24*60*60)) AS time_as_customer,
	MIN(AOV) AS AOV,
	MIN(APF) AS APF,
	MIN(ACL) AS ACL,
	MIN(ROUND(AOV*APF*ACL,2)) AS CLV,
FROM customers
INNER JOIN customer_AOV on customer_AOV.customer_id = customers.customer_ID
INNER JOIN customer_APF on customer_APF.customer_id = customers.customer_ID
INNER JOIN customer_ACL on customer_ACL.customer_id = customers.customer_ID
INNER JOIN orders ON orders.customer_id = customers.customer_id
WHERE customer_APF IS NOT NULL
GROUP BY customers.customer_id
HAVING FLOOR(EXTRACT(EPOCH FROM (MAX(invoice_date)-MIN(invoice_date)))/(30.5*24*60*60)) > 0 -- ~time_as_customer
ORDER BY CLV DESC;
