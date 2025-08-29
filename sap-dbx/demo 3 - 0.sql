SELECT
  soitem.SalesOrder,
  soitem.SalesOrderItem,
  product.product,
  product.ProductDescription
FROM demo_sales_order_share.salesorder.salesorderitem soitem
INNER JOIN demo_product_share.product.productdescription product
  ON soitem.product = product.product limit 2;