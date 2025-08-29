
CREATE TABLE `so_product_with_translation` AS 
SELECT
  soitem.SalesOrder,
  soitem.SalesOrderItem,
  product.product,
  product.ProductDescription,
  ai_query('databricks-meta-llama-3-3-70b-instruct', concat('translate this to English. Return only a natural english translation with no additional text: ',product.ProductDescription) ) as translated_desc
FROM demo_sales_order_share.salesorder.salesorderitem soitem
INNER JOIN demo_product_share.product.productdescription product
  ON soitem.product = product.product limit 50;