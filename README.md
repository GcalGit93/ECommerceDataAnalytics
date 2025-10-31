---



---



# Kaggle E-Commerce Data Analytics Project



PLEASE SEE: [portfolio post](https://gcalgit93.github.io/gcalgit93/project/2025/10/10/Kaggle-Data-Project.html) for more of a breakdown of the project. 



To recreate the files needed for the dashboards and all analysis,

1. Load the data.csv into postgreSQL using the PSQL client facility into a staging\_orders table (StagingOrders.sql)
2. Create a customers, products, and orders table and insert dat into them from the staging\_orders table, removing null and duplicated rows (CreateEcommerceTables.sql, InsertFromStagingOrdersTable.sql)
3. ~~Calculate customer spending frequency and save them to SpendFrequency.csv (Repeat\_Purchase\_Behavior.sql)~~ (UPDATE-10-30-2025)
4. Save customers, products, and orders table to CSVs using PSQL client facility



For the 10M row datasets:

1. Replicate orders table to reach 10 million rows in an orders10M table (ScalingUpCode.sql)
2. ~~Recalculate customer spend frequency and export to SpendFrequency10M.csv (Repeat\_Purchase\_Behavior.sql)~~ (UPDATE-10-30-2025) 
3. Export orders10M to a csv.
