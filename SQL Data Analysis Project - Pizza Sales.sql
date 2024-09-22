create database pizzahut;

create table orders (
Order_id int not null,
Order_date date not null,
Order_time time not null,
primary key(Order_id) );


create table order_details (
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id) );



# Retrieve the total number of orders placed.
select count(order_id) as total_orders from orders;


# Calculate the total revenue generated from pizza sales.
select round(sum(order_details.quantity*pizzas.price),2) as total_revenue 
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id;


# Identify the highest-priced pizza.
select pizza_types.name, pizzas.price 
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc
limit 1;


# Identify the most common pizza size ordered.
select count(order_details.quantity),pizzas.size
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
group by pizzas.size
order by count(order_details.quantity) desc;


# List the top 5 most ordered pizza types along with their quantities.
select pizza_types.name, sum(order_details.quantity)
from pizza_types join pizzas
on  pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details 
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by sum(order_details.quantity) desc
limit 5;


# Join the necessary tables to find the total quantity of each pizza category ordered.
Select pizza_types.category, sum(order_details.quantity)
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join pizza_types
on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.category;


# Determine the distribution of orders by hour of the day.
select count(order_id), hour(order_time)
from orders
group by hour(order_time);

# Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name) 
from pizza_types
group by category

# Group the orders by date and calculate the average number of pizzas ordered per day.
select avg(quantity) from
(select orders.order_date, sum(order_details.quantity) as quantity
from orders join order_details
on orders.order_id = order_details.order_id
group by orders.order_date) as a;


# Determine the top 3 most ordered pizza types based on revenue.
select sum(order_details.quantity*pizzas.price), pizza_types.name
from order_details join pizzas 
on order_details.pizza_id = pizzas.pizza_id
join pizza_types
on pizzas.pizza_type_id = pizza_types.pizza_type_id
group by pizza_types.name


# Calculate the percentage contribution of each pizza type to total revenue.
select pizza_types.category,(sum(order_details.quantity*pizzas.price)/
(select round(sum(order_details.quantity*pizzas.price),2) 
from order_details join pizzas
on pizzas.pizza_id = order_details.pizza_id)*100) as revenue_distr 
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join pizza_types
on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.category


# Analyze the cumulative revenue generated over time.
select order_date,
sum(revenue)  over(order by order_date) as cumm
from
(select orders.order_date, sum(pizzas.price * order_details.quantity) as revenue 
from pizzas join order_details
on pizzas.pizza_id = order_details.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.order_date) AS sales;


# Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name, revenue, category
from
(select category, name, revenue, 
rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.name, pizza_types.category, sum(order_details.quantity*pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where rn <= 3;

































