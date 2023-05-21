SELECT
  TO_CHAR(TO_DATE(transactions.transaction_date, 'DD-MM-YYYY'), 'MM-YYYY') AS date, -- перевод даты в ММ-УУУУ формат
  customers.wealth_segment AS wealth_segment, -- сегмент пользователя
  ROUND(SUM(CAST(REPLACE(
    REPLACE(
      REPLACE(transactions.standard_cost, '[$]', ''), -- убрать пробелы и знак доллара
      ',',
      '.'
    ),
    ' ',
    ''
  ) AS float))) AS cost, -- оборот пользователя
  COUNT(DISTINCT(transactions.customer_id)) AS MAU -- подсчет MAU
FROM public.transaction_test_nick AS transactions 
  INNER JOIN public.customers_test_nick AS customers -- объединение таблицы транзакций и клиентов
    ON transactions.customer_id = customers.customer_id
WHERE(
  transactions.standard_cost <> ''
  AND transactions.standard_cost IS NOT NULL) -- отфильтровать нулевые и пустые значения 
  AND transactions.order_status = 'Approved' -- отфильтровать неутвержденные транзакции
  
  AND transactions.customer_id IN (
SELECT
  customer_id
FROM public.transaction_test_nick transactions
GROUP BY customer_id
HAVING MAX(EXTRACT(MONTH FROM to_date(transaction_date, 'DD-MM-YYYY'))) = 12 AND (MAX(EXTRACT(MONTH FROM to_date(transaction_date, 'DD-MM-YYYY'))) - MIN(EXTRACT(MONTH FROM to_date(transaction_date, 'DD-MM-YYYY'))) + 1) = COUNT(DISTINCT((EXTRACT(MONTH FROM to_date(transaction_date, 'DD-MM-YYYY')))))
) -- отсеивать клиентов, которые не совершали покупки в каждом месяце года
GROUP BY date, wealth_segment -- группировка по дате и сегменту
ORDER BY date, wealth_segment -- сортировка по дате и сегменту
