-- Top Customer By Spend

SELECT
	customers.customer_id,
	SUM(quantity * unit_price) AS total_spent,
	SUM(quantity * unit_price)/COUNT(invoice_date) AS AOV,
	RANK() OVER(ORDER BY SUM(quantity * unit_price) DESC) AS spending_rank
FROM orders
INNER JOIN customers on orders.customer_id = customers.customer_id 
GROUP BY customers.customer_id
LIMIT 10;