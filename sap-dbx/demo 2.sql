CREATE OR REPLACE FUNCTION sales_order_item_explorer(so STRING)
RETURNS TABLE (
  SalesOrder STRING,
  SalesOrderItem STRING
)
COMMENT 'Returns sales order items of a given list of sales order id'
RETURN
  SELECT
    SalesOrder,
    SalesOrderItem
  FROM demo_sales_order_share.salesorder.salesorderitem
  WHERE SalesOrder = so;