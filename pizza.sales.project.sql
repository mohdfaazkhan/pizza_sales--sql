SELECT * FROM pizzahut;
 create table orderss (
 order_id int not null,
 order_date date not null,
 order_time time not null,
 primary key(order_id));
 
 select * from pizzas;
 select * from pizza_types;
 select * from orders;
 select * from order_details;
 
 
 drop table orders
 -- Retrieve the total number of orders placed.
 select count(order_id) from orders; 
   
-- Calculate the total revenue generated from pizza sales.
  
select round(sum(pizzas.price * order_details.quantity),2)as revenue
from order_details 
join pizzas
on pizzas.pizza_id=order_details.pizza_id

-- Identify the highest-priced pizza.--

select pizza_types.name, pizzas.price
from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price
desc limit 1;

select * from pizza_types where pizza_type_id in (select pizza_type_id from pizzas);

select pt.*, p.*
from pizza_types pt
join pizzas p
on pt.pizza_type_id = p.pizza_type_id
order by p.price
desc limit 1 offset 2 ;


SELECT price
FROM pizzas
ORDER BY price DESC LIMIT 1;

SELECT price, name 
FROM (SELECT p.price, pt.name, 
ROW_NUMBER() OVER (ORDER BY p.price DESC) AS rn
FROM pizzas p
JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
) t
WHERE rn = 1;

-- Identify the most common pizza size ordered.--

select pizzas.size, count(order_details.order_details_id) as order_count
from pizzas join order_details 
on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size order by order_count desc limit 1;

select size
from pizzas
group by size limit 1;

-- List the top 5 most ordered pizza types along with their quantities.

select pizza_types.name, sum(order_details.quantity) as quantity
from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name order by quantity desc limit 5;

-- top 5 most recent orders--

SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (ORDER BY order_date DESC) AS rn
    FROM orders
) t
WHERE rn <= 5;

SELECT *
FROM orders
ORDER BY order_date DESC
LIMIT 5;


-- Intermediate:
-- Join the necessary tables to find the total quantity of each pizza category ordered.

select pizza_types.category, sum(order_details.quantity)as quantity
from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by  pizza_types.category order by quantity desc;


-- Determine the distribution of orders by hour of the day.--

select hour(order_time) as hour, count(order_id) as order_count from orders
group by hour(order_time) 

-- Join relevant tables to find the category-wise distribution of pizzas.

select category, count(name) from pizza_types
group by category

-- Group the orders by date and calculate the average number of pizzas ordered per day.

select round(avg(quantity),0)from
(select orders.order_date, sum(order_details.quantity) as quantity
from orders
join order_details
on orders.order_id = order_details.order_id
group by orders.order_date) as order_quantity

-- Determine the top 3 most ordered pizza types based on revenue.
 
select pizza_types.name, sum(order_details.quantity * pizzas.price) as revenue
from pizza_types
join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name order by revenue desc limit 3;


-- Advanced:
-- Calculate the percentage contribution of each pizza type to total revenue.

select pizza_types.name, sum(pizzas.price* order_details.quantity)as revenue,
ROUND(SUM(order_details.quantity * pizzas.price) * 100.0 / SUM(SUM(order_details.quantity * pizzas.price)) OVER (), 2) AS percentage_contribution
from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join
order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name ORDER BY percentage_contribution DESC;

-- Analyze the cumulative revenue generated over time.

select order_date,
sum(revenue)over(order by order_date) as cum_revenue 
from
(select orders.order_date,
sum(order_details.quantity * pizzas.price) as revenue
from orders
join order_details
on orders.order_id = order_details.order_id
join pizzas
on order_details.pizza_id = pizzas.pizza_id
group by orders.order_date) as sales;

SELECT 
o.order_date,
SUM(od.quantity * p.price) AS daily_revenue,
SUM(SUM(od.quantity * p.price)) OVER (ORDER BY o.order_date) AS cumulative_revenue
FROM orders o
JOIN order_details od
ON o.order_id = od.order_id
JOIN pizzas p
ON od.pizza_id = p.pizza_id
GROUP BY o.order_date
ORDER BY o.order_date;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category, name, revenue from 
(select category, name, revenue,
rank()over(partition by category order by revenue desc) as rn
from
(select pizza_types.category,pizza_types.name ,sum(order_details.quantity * pizzas.price) as revenue
from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id= pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where rn<=3;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name, revenue, category from(
select pizza_types.name,sum(order_details.quantity * pizzas.price)as revenue,
pizza_types.category,
ROW_NUMBER() OVER (PARTITION BY pizza_types.category ORDER BY SUM(order_details.quantity * pizzas.price) DESC) as rn
from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name,pizza_types.category) t
where rn <=3;




