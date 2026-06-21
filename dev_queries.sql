DROP VIEW IF EXISTS DimGeography
GO
CREATE VIEW DimGeography AS 

WITH normalized_data AS (
    SELECT 
        region,
        CASE 
            WHEN country IN ('US', 'United States', 'USA') THEN 'United States'
            ELSE country
        END AS country_normalized
    FROM  ecommerce_raw
    WHERE region IS NOT NULL
)


    SELECT 
        ROW_NUMBER() OVER(ORDER BY country_normalized) AS geography_key,
        region,
        country_normalized

    FROM  normalized_data
    GROUP BY 
        region,
        country_normalized;
GO


 UPDATE ecommerce_raw
    SET gross_margin_pct =  cast(REPLACE(gross_margin_pct,'%','') AS DECIMAL(10,2)),
    discount_pct =  cast(REPLACE(discount_pct,'%','') AS DECIMAL(10,2))
GO

DROP VIEW IF EXISTS FactSales
GO
CREATE VIEW FactSales AS

   

        
        SELECT DISTINCT top 1000  product_id,order_id,
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
            quantity,
            unit_price,
            unit_cogs,
            CASE 
                WHEN discount_pct > 1 THEN discount_pct / 100
                ELSE discount_pct
                END AS discount_pct,
            gross_revenue,
            net_revenue,
            cogs_total,
            gross_profit,
            CASE 
                WHEN  gross_margin_pct > 1 THEN gross_margin_pct / 100
                ELSE gross_margin_pct
                END AS gross_margin_pct,
            shipping_cost,
            
            CASE 
                WHEN lower(payment_method) IN('visa','mastercard','cc') THEN 'Credit Card'
                    ELSE payment_method
                    END AS payment_method,
            payment_status,
            fulfillment_status,
            order_status,
            notes
            


        FROM ecommerce_raw
        LEFT JOIN DimGeography on ecommerce_raw.region = DimGeography.region


        ;
GO


DROP VIEW IF EXISTS DimCustomer
GO
CREATE VIEW DimCustomer AS 

WITH unique_cust AS (
    SELECT customer_id,customer_name,customer_email,customer_segment,
        ROW_NUMBER() over(PARTITION BY customer_id ORDER BY customer_id) as num_cust
    from ecommerce_raw)


    SELECT customer_id,customer_name,customer_email,customer_segment
    from unique_cust
    where num_cust = 1
GO

DROP VIEW IF EXISTS DimProduct
GO
CREATE VIEW DimProduct AS 

WITH unique_products as (
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
        reorder_point,supplier_id,
        ROW_NUMBER() over(partition by product_id order by product_id) as num_fila 

    from ecommerce_raw)
    

    SELECT  product_id, product_name,subcategory, category,reorder_point,supplier_id
    from unique_products
    WHERE num_fila = 1;
GO


DROP VIEW IF EXISTS FactInventory
GO
CREATE VIEW FactInventory AS 


    SELECT top 1000  product_id, inventory_on_hand, 
        days_in_stock, supplier_lead_time_days,warehouse_id,fulfillment_status
        from ecommerce_raw
GO



DROP VIEW IF EXISTS FactReturns
GO
CREATE VIEW FactReturns AS 

    WITH returns_processed AS (
    SELECT DISTINCT order_id,
        COALESCE(
            TRY_CAST(TRY_CONVERT(DATETIME,return_date,101) AS DATE),
                TRY_CAST(TRY_CONVERT(DATETIME,return_date,103) AS DATE),
                TRY_CAST(TRY_CONVERT(DATETIME,return_date,105) AS DATE),
                TRY_CAST(TRY_CONVERT(DATETIME,return_date,120) AS DATE)
            )AS return_date,
            
        return_reason,refund_amount,
        CASE 
            WHEN return_flag IS NULL THEN 0
            WHEN lower(return_flag) IN ('y','true','yes') THEN 1
            WHEN lower(return_flag) IN ('n','false','no') THEN 0
            ELSE return_flag
            END as return_flag
            
    from ecommerce_raw
)
    select top 1000 order_id,return_date,return_reason,sum(refund_amount) AS refund_amount 


        FROM returns_processed
        WHERE return_flag !=0
        GROUP BY order_id,return_date,return_reason;
GO
        








