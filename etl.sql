WITH normalized_data AS (
    SELECT 
        region,
        CASE 
            WHEN country IN ('US', 'United States', 'USA') THEN 'United States'
            ELSE country
        END AS country_normalized
    FROM  ecommerce_raw
    WHERE region IS NOT NULL
),

 DimGeography AS (
    SELECT TOP 20 
        ROW_NUMBER() OVER(ORDER BY country_normalized) AS geography_key,
        region,
        country_normalized

    FROM  normalized_data
    GROUP BY 
        region,
        country_normalized ),


FactSales AS (
        SELECT order_id,
            COALESCE(
            TRY_CAST(TRY_CONVERT(DATETIME,order_date,101) AS DATE),
                TRY_CAST(TRY_CONVERT(DATETIME,order_date,103) AS DATE),
                TRY_CAST(TRY_CONVERT(DATETIME,order_date,105) AS DATE),
                TRY_CAST(TRY_CONVERT(DATETIME,order_date,120) AS DATE)
            )AS order_date,
            COALESCE(
            TRY_CAST(TRY_CONVERT(DATETIME,ship_date,101) AS DATE),
                TRY_CAST(TRY_CONVERT(DATETIME,ship_date,103) AS DATE),
                TRY_CAST(TRY_CONVERT(DATETIME,ship_date,105) AS DATE),
                TRY_CAST(TRY_CONVERT(DATETIME,ship_date,120) AS DATE)
            )AS ship_date,
            COALESCE(
            TRY_CAST(TRY_CONVERT(DATETIME,delivery_date,101) AS DATE),
                TRY_CAST(TRY_CONVERT(DATETIME,delivery_date,103) AS DATE),
                TRY_CAST(TRY_CONVERT(DATETIME,delivery_date,105) AS DATE),
                TRY_CAST(TRY_CONVERT(DATETIME,delivery_date,120) AS DATE)
            )AS delivery_date,
            customer_id,
            sales_channel,
            geography_key


        FROM ecommerce_raw
        LEFT JOIN DimGeography on ecommerce_raw.region = DimGeography.region
),


unique_cust AS (
    SELECT customer_id,customer_name,customer_email,customer_segment,
        ROW_NUMBER() over(PARTITION BY customer_id ORDER BY customer_id) as num_cust
    from ecommerce_raw),

DimCustomer AS(
    SELECT customer_id,customer_name,customer_email,customer_segment
    from unique_cust
    where num_cust = 1),


unique_products as (
    SELECT product_id, product_name, 
        COALESCE(subcategory,
            CASE
    
           
                WHEN lower(product_name) like '%cutlery%' THEN 'Cutlery'
                WHEN lower(product_name) like '%desk%' THEN 'Desks'
                WHEN lower(product_name) like '%shelves%' THEN 'Shelves'
                WHEN lower(product_name) like '%boxes%' THEN 'Boxes'
                WHEN lower(product_name) like '%baskets%' THEN 'Baskets'
                WHEN lower(product_name) like '%patio%' THEN 'Patio'
                WHEN lower(product_name) like '%lighting%' THEN 'Lighting'
                WHEN lower(product_name) like '%bedding%' THEN 'Bedding'
                WHEN lower(product_name) like '%decor%' THEN 'Decor'
                WHEN lower(product_name) like '%cookware%' THEN 'Cookware'
                WHEN lower(product_name) like '%utensils%' THEN 'Utensils'
                WHEN lower(product_name) like '%chairs%' THEN 'Chairs'
                WHEN lower(product_name) like '%chairs%' THEN 'Chairs'
                WHEN lower(product_name) like '%gardening%' THEN 'Gardening'
                WHEN lower(product_name) like '%accessories%' THEN 'Accessories'
            ELSE NULL
        END ) AS subcategory,
        REPLACE(category,'Storage & Organization','Storage') AS category ,
        ROW_NUMBER() over(partition by product_id order by product_id) as num_fila 

    from ecommerce_raw),


DimProduct AS (
    SELECT  product_id, product_name,subcategory, category
    from unique_products
    WHERE num_fila = 1)







SELECT top 20 * 
FROM DimCustomer;