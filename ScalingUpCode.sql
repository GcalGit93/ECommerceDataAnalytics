-- code for testing scalability of dashboards. Just loops and adds new purchases randomly for each non-churned customer.

DO $$
BEGIN
   FOR i IN 1..5 LOOP  -- repeat 5 times
      INSERT INTO orders10M (invoice_no, customer_id, stock_code, invoice_date, quantity, unit_price)
      SELECT 
          (invoice_no::INT + (SELECT MAX(invoice_no::INT) FROM orders10M WHERE invoice_no ~ '^[0-9]+$'))::VARCHAR,
          customer_id,
          stock_code,
          invoice_date + (INTERVAL '1 day' * (random() * 365)::int),
		  quantity + (random() * 3)::int,        -- vary quantity by up to +3
		  unit_price
      FROM orders10M
	  WHERE invoice_no ~ '^[0-9]+$' AND customer_id NOT IN ( -- replicating invoice_no with only numbers to avoid errors with alphanumeric invoices. Not adding to churned customers as to maintain churn rate as a check
	  									SELECT customer_id FROM orders GROUP BY customer_id
										HAVING MAX(invoice_date) < (SELECT (MIN(invoice_date) + EXTRACT(DAY FROM (MAX(invoice_date)-MIN(invoice_date))/2) * INTERVAL '1 day')
										FROM orders));
   END LOOP;
END $$;

SELECT COUNT(*) FROM orders10M;

