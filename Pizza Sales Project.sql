CREATE DATABASE PIZZA_HUT;
USE PIZZA_HUT;

CREATE TABLE ORDERS
(ORDER_ID INT NOT NULL,
ORDER_DATE DATE NOT NULL,
ORDER_TIME TIME NOT NULL,
PRIMARY KEY (ORDER_ID));

CREATE TABLE ORDER_DETAILS
(ORDER_DETAILS_ID INT NOT NULL,
ORDER_ID INT NOT NULL,
PIZZA_ID TEXT NOT NULL,
QUANTITY INT  NOT NULL,
PRIMARY KEY (ORDER_DETAILS_ID));

SELECT * FROM ORDER_DETAILS;
SELECT * FROM ORDERS;
SELECT * FROM PIZZA_TYPES;
SELECT * FROM PIZZAS;
---------------------------------------------------------------------------------------------------------------------------

-- Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS Total_orders
FROM
    orders;

-------------------------------------------------------------------------------------------------------------------------
-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(o.quantity * p.price), 2) AS Total_revenue
FROM
    order_details o
        JOIN
    pizzas p ON o.pizza_id = p.pizza_id;

--------------------------------------------------------------------------------------------------------------------------
-- Identify the highest-priced pizza.

SELECT 
    pt.name
FROM
    pizza_types pt
        JOIN
    pizzas AS p ON p.pizza_type_id = pt.pizza_type_id
WHERE
    p.price = (SELECT 
            MAX(price)
        FROM
            pizzas);

----------------------------------------------------------------------------------------------------------------------------
-- Identify the most common pizza size ordered.

SELECT 
    p.size, COUNT(o.order_details_id) AS ordered
FROM
    order_details AS o
        JOIN
    pizzas AS p ON o.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY ordered DESC
LIMIT 1;

------------------------------------------------------------------------------------------------------------------------------

-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pt.name, SUM(o.quantity) AS total_quantity
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS o ON o.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;

--------------------------------------------------------------------------------------------------------------------------------
-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pt.category, sum(od.quantity) AS TOTAL
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY pt.category;

----------------------------------------------------------------------------------------------------------------------------------
-- Determine the distribution of orders by hour of the day.

SELECT 
    COUNT(order_id) AS order_count, HOUR(order_time) AS hour
FROM
    orders
GROUP BY hour;
-----------------------------------------------------------------------------------------------------------------------------------

-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name) AS Total
FROM
    pizza_types AS pt
GROUP BY category;
--------------------------------------------------------------------------------------------------------------------------------------

-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity_ordered), 2) as avg_order
FROM
    (SELECT 
        o.order_date, SUM(od.quantity) AS quantity_ordered
    FROM
        order_details AS od
    JOIN orders AS o ON od.order_id = o.order_id
    GROUP BY order_date) AS new;
    
----------------------------------------------------------------------------------------------------------------------------------

-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pt.name, SUM(od.quantity * p.price) AS revenue
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;
------------------------------------------------------------------------------------------------------------------------------------------
-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pt.category, round((SUM(od.quantity * p.price)/(SELECT 
    ROUND(SUM(o.quantity * p.price), 2) AS Total_revenue
FROM
    order_details o
        JOIN
    pizzas p ON o.pizza_id = p.pizza_id)*100),2) AS revenue
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY revenue DESC;

--------------------------------------------------------------------------------------------------------------------------------------
-- Analyze the cumulative revenue generated over time.

SELECT  ORDER_DATE, SUM(REVENUE) OVER (ORDER BY ORDER_DATE) AS CUM_REVENUE FROM
(SELECT O.ORDER_DATE, SUM(OD.QUANTITY*P.PRICE) AS REVENUE
FROM ORDER_DETAILS AS OD
JOIN PIZZAS AS P
ON OD.PIZZA_ID=P.PIZZA_ID
JOIN ORDERS AS O
ON O.ORDER_ID=OD.ORDER_ID
GROUP BY ORDER_DATE) AS SALES ;

------------------------------------------------------------------------------------------------------------------------------------
-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name, revenue from
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types. category, pizza_types. name,
sum((order_details. quantity)*pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id =pizzas.pizza_type_id
join order_details
on order_details.pizza_id
= pizzas.pizza_id
group by pizza_types. category, pizza_types. name) as a) as b
where rn <=3;




 




