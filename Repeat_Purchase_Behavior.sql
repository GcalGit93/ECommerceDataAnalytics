WITH customer_orders AS (
	SELECT
		customer_id,
		invoice_date,
		LAG(invoice_date) OVER(PARTITION BY customer_id ORDER BY invoice_date) AS prev_order_date
	FROM orders
	)--,
--order_frequency AS (		
	SELECT 
		customer_id,
		AVG(invoice_date - prev_order_date) AS avg_days_between_orders,
		EXTRACT(EPOCH FROM AVG(invoice_date - prev_order_date)) AS num_seconds
	FROM customer_orders
	WHERE prev_order_date IS NOT NULL
	GROUP BY customer_id
	--HAVING AVG(invoice_date - prev_order_date) > '00:00:00' -- 0 time between multiple transactions seems suspicious
	ORDER BY num_seconds ASC
--	)



--TO 'C:/Users/E1cal/OneDrive/Documents/SQL_Notes/PostgreSQL_Files/E-commerce_Data/spend_frequency.csv' CSV HEADER;

/*
\copy (WITH customer_orders AS (  SELECT          customer_id,            invoice_date,           LAG(invoice_date) OVER
(PARTITION BY customer_id ORDER BY invoice_date) AS prev_order_date     FROM orders10M     )               SELECT  customer_id,    AVG(in
voice_date - prev_order_date) AS avg_days_between_orders,       EXTRACT(EPOCH FROM AVG(invoice_date - prev_order_date)) AS num_seconds
 FROM customer_orders WHERE prev_order_date IS NOT NULL GROUP BY customer_id ORDER BY num_seconds ASC) TO 'C:/Users/E1cal/OneDrive/Documents/SQL_Notes/PostgreSQL_Files/
E-commerce_Data/SpendFrequency10M.csv' CSV HEADER;
*/

	




