-- Staging original data prior to normalization
CREATE TABLE staging_orders (
    invoice_no VARCHAR,
    stock_code VARCHAR,
    description TEXT,
    quantity INT,
    invoice_date TIMESTAMP,
    unit_price NUMERIC,
    customer_id VARCHAR,
    country VARCHAR
);

-- use below to insert data.csv into staging_orders table
/*
\copy staging_orders(invoice_no, stock_code, description, quantity, invoice_date, unit_price, customer_id, country) FROM 'C:\Users\E1cal\OneDrive\Documents\SQL_Not
es\PostgreSQL_Files\E-commerce_Data\archive\data.csv' CSV HEADER;
*/