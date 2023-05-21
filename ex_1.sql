SELECT
  TO_CHAR(TO_DATE(transactions.transaction_date, 'DD-MM-YYYY'), 'MM-YYYY') AS date,
  customers.wealth_segment AS wealth_segment,
  ROUND(SUM(CAST(REPLACE(
    REPLACE(
      REPLACE(transactions.standard_cost, '[$]', ''),
      ',',
      '.'
    ),
    ' ',
    ''
  ) AS float))) AS cost,
  COUNT(DISTINCT(transactions.customer_id)) AS MAU
FROM public.transaction_test_nick AS transactions
  INNER JOIN public.customers_test_nick AS customers
    ON transactions.customer_id = customers.customer_id
WHERE(
  transactions.standard_cost <> ''
  AND transactions.standard_cost IS NOT NULL) 
  AND transactions.order_status = 'Approved' 
  
  AND transactions.customer_id IN (
SELECT
  customer_id
FROM public.transaction_test_nick transactions
GROUP BY 1
HAVING MAX(EXTRACT(MONTH FROM to_date(transaction_date, 'DD-MM-YYYY'))) = 12 AND (MAX(EXTRACT(MONTH FROM to_date(transaction_date, 'DD-MM-YYYY'))) - MIN(EXTRACT(MONTH FROM to_date(transaction_date, 'DD-MM-YYYY'))) + 1) = COUNT(DISTINCT((EXTRACT(MONTH FROM to_date(transaction_date, 'DD-MM-YYYY')))))
)
GROUP BY date, wealth_segment
ORDER BY date, wealth_segment