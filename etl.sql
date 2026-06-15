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
)



SELECT top 15 * 
FROM FactSales;