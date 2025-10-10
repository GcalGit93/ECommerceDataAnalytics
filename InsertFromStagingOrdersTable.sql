-- this inserts data from the original source and cleans it of duplicates simultaneously
INSERT INTO customers (customer_id, country)
SELECT customer_id, MIN(country) AS country
FROM staging_orders
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ON CONFLICT (customer_id) DO NOTHING;

INSERT INTO products (stock_code, description)
SELECT DISTINCT UPPER(stock_code), MIN(description) AS description
FROM staging_orders
WHERE stock_code IS NOT NULL
GROUP BY stock_code
ON CONFLICT (stock_code) DO NOTHING;

INSERT INTO orders (invoice_no, stock_code, quantity, invoice_date, unit_price, customer_id)
SELECT invoice_no, stock_code, quantity, invoice_date, unit_price, customer_id
FROM staging_orders
WHERE customer_id IS NOT NULL
  AND stock_code IS NOT NULL;

INSERT INTO orders10M (invoice_no, stock_code, quantity, invoice_date, unit_price, customer_id)
SELECT invoice_no, stock_code, quantity, invoice_date, unit_price, customer_id
FROM staging_orders
WHERE customer_id IS NOT NULL
  AND stock_code IS NOT NULL;

-- use below to insert SpendFrequency.csv into spend_frequency table
/*
\copy spend_frequency(customer_id, avg_days_between_orders, num_seconds) FROM 'C:\Users\E1cal\OneDrive\Documents\SQL_Not
es\PostgreSQL_Files\E-commerce_Data\SpendFrequency.csv' CSV HEADER;
*/



