CREATE DATABASE ALFAMART_SALES;

DROP TABLE IF EXISTs order_list;
DROP TABLE IF EXISTs customer;

TRUNCATE TABLE order_list;
TRUNCATE TABLE customer;

CREATE TABLE order_list
(
order_id int,
order_date date,
ship_date date, 
category varchar(50),
sales decimal (5),
quantity int,
profit decimal (5)
);

ALTER TABLE order_list RENAME COLUMN category to product;

CREATE TABLE customer
(
customer_id int,
name varchar(50),
country varchar(50),
city varchar(50),
state varchar(50)
);


SELECT * FROM order_list;
SELECT * FROM customer;

/* Total sales/quantity/profit*/

SELECT 
	sum(sales) as total_sales, 
	sum(quantity) as total_units,
    sum(profit) as total_profit
FROM order_list;

/* Total revenue/cost */

SELECT
	(sum(sales))*(sum(quantity)) as total_revenue,
    (sum(sales)*sum(quantity))-(sum(profit)) as total_cost
FROM order_list;

/* Average sales/profit */

SELECT
	avg(sales) as avg_sales,
    avg(profit) as avg_profit
FROM order_list;

/* Profit total_lost*/

SELECT sum(profit) as profit_lost
FROM order_list
WHERE profit like '-%';

/* Total Transactions*/

SELECT count(*) as order_count
FROM order_list;

/* Max amount sold per product*/

SELECT 
	product, 
	max(sales) as max_sold
FROM order_list
GROUP BY product
ORDER BY sales DESC;

/* Yearly performance */

SELECT 
	year(order_date) annual_performance, 
	count(order_id) as order_count, 
    sum(sales) as total_sales
FROM order_list
group by year(order_date);

/* Monthly performance */

SELECT 
	date_format(order_date, '%M') monthly_performance, 
	count(order_id) as order_count, 
    sum(sales) as total_sales
FROM order_list
WHERE year(order_date) = '2014'
group by month(order_date)
ORDER BY order_date;

/* State with the most number of orders */

SELECT state, count(o.order_id) as order_state
FROM order_list o
JOIN customer c on c.customer_id = o.order_id
GROUP BY state
ORDER BY order_state desc;

/* Top products orders per states?*/

SELECT state, product, count(o.order_id) as order_state
FROM order_list o
JOIN customer c on c.customer_id = o.order_id
GROUP BY state, product
ORDER BY state, order_state desc;

/* Customer who order the most numbers of products?*/

SELECT name, count(o.order_id) as order_count
FROM order_list o
JOIN customer c on c.customer_id = o.order_id
GROUP BY name
ORDER BY order_count desc;

/* Units order per order date */

SELECT
	c.name as customers,
	o.order_date,
    quantity,
    sum(o.quantity) over (partition by o.order_date, c.name) as units_per_orderdate
FROM order_list o
JOIN customer c on c.customer_id = o.order_id;

/* duration to ship each products */

SELECT product, order_date, ship_date, DATEDIFF(ship_date, order_date) as ship_duration
FROM order_list;

/* Average duration to ship */

SELECT
	product,
	order_date, 
	ship_date, 
    avg(DATEDIFF(ship_date, order_date)) as avg_ship_duration
FROM order_list
GROUP BY product;

/* Consumer categorized base on */

SELECT distinct(name),
case 
	when x.buckets = 1 then 'Low orders'
    when x.buckets = 2 then 'Average orders'
    when x.buckets = 3 then 'High orders'
    end customer_order_category
from(
	SELECT 
		c.name, 
		NTILE(3) over (order by sales) as buckets
	FROM order_list o
	JOIN customer c on c.customer_id = o.order_id) x;




