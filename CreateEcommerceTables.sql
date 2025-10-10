CREATE TABLE customers (
	customer_id VARCHAR PRIMARY KEY,
	country VARCHAR
);

CREATE TABLE products (
	stock_code VARCHAR PRIMARY KEY,
	description VARCHAR
);

CREATE TABLE orders (
	invoice_no VARCHAR,
	stock_code VARCHAR REFERENCES products(stock_code),
	quantity INT,
	invoice_date TIMESTAMP,
	unit_price NUMERIC,
	customer_id VARCHAR REFERENCES customers(customer_id)
);

CREATE TABLE orders10M (
	invoice_no VARCHAR,
	stock_code VARCHAR REFERENCES products(stock_code),
	quantity INT,
	invoice_date TIMESTAMP,
	unit_price NUMERIC,
	customer_id VARCHAR REFERENCES customers(customer_id)
);

CREATE TABLE spend_frequency (
	customer_id VARCHAR REFERENCES customers(customer_id),
	avg_days_between_orders INTERVAL,
	num_seconds NUMERIC
);
