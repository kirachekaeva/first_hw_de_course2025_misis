
-- 1 часть (создание таблиц)

-- users
create table users (
    id integer primary key,
    name varchar(100) not null,
    email varchar(150) not null,
    created_at timestamp
)

-- categories
create table categories (
    id integer primary key,
    name varchar(100)
)

-- products 
create table products (
    id integer primary key,
    name varchar(100),
    price numeric(10, 2),
    category_id integer,
    foreign key (category_id) references categories (id)
)

-- orders
create table orders (
    id integer primary key,
    user_id integer,
    foreign key(user_id) references users (id),
    status varchar(50),
    created_at timestamp
)

-- order_items
create table order_items (
    id integer primary key,
    order_id integer,
    foreign key(order_id) references orders(id),
    product_id integer,
    foreign key(product_id) references products(id),
    quantity integer
)

-- payments 
create table payments (
    id integer primary key,
    order_id integer,
    foreign key(order_id) references orders(id),
    amount numeric(10,2),
    payment_date integer
)

--2 часть (запросы)


--- 1 задание
select
    c.name as category_name,
    round(avg(order_total), 2) as avg_order_amount
from (
    select 
        oi.order_id,
        p.category_id,
        sum(oi.quantity * p.price) as order_total
    from 
        order_items as oi
    join
        products as p on oi.product_id = p.id
    join 
        orders as o on oi.order_id = o.id
    where 
        o.created_at >= '2023-03-01' and o.created_at < '2023-04-01'
    group by
        oi.order_id, p.category_id
) as order_totals
join 
    categories as c on order_totals.category_id = c.id
group by 
    c.name


--- 2 задание
select
    user_name,
    total_spent,
    user_rank 
from (
    select 
        u.name as user_name,
        sum(p.amount) as total_spent,
        rank() over (order by sum(p.amount) desc) as user_rank
    from 
        users as u
    join 
        orders as o on o.user_id = u.id
    join 
        payments as p on p.order_id = o.id
    where 
        o.status = 'Оплачен'
    group by 
        u.name
)
where 
    user_rank <= 3

--- 3 задание
select
    to_char(o.created_at, 'YYYY-MM') as month,
    count(o.id) as total_orders,
    sum(p.amount) as total_payments
from
    orders as o
join 
    payments as p on o.id = p.order_id
where 
    o.created_at >= '2023-01-01' and o.created_at < '2024-01-01'
group by 
    to_char(o.created_at, 'YYYY-MM')
order by 
    month;


--- 4 задание
select 
    product_name,
    total_sold,
    round((total_sold / sum(total_sold) over ()) * 100, 2) as procent
from (
    select 
        p.name as product_name,
        sum(oi.quantity) as total_sold
    from 
        orders as o
    join 
        order_items as oi on o.id = oi.order_id
    join 
        products as p on oi.product_id = p.id
    group by 
        p.name
)
order by 
    total_sold desc
limit 5;


--- 5 задание
select
	user_name,
	total_spend
from(
    select 
        u.name as user_name,
        sum(p.amount) as total_spend,
        avg(sum(p.amount)) over() as sred
    from 
        users as u
    join 
        orders as o on o.user_id = u.id
    join 
        payments as p on p.order_id = o.id
    group by 
        u.name
)
where 
    total_spend > sred;

--- 6 задание
select 
	category_name,
	product_name,
	total_sold
from (
	select 
	    c.name as category_name,
	    p.name as product_name,
	    sum(oi.quantity) as total_sold,
	    rank() over(partition by c.name order by sum(oi.quantity) desc) as rank
	from 
		categories as c
	join 
		products as p on p.category_id  = c.id
	join
		order_items as oi on oi.product_id = p.id
	group by 
		c.name, p.name
)
where  
    rank <= 3



--- 7 задание
select 
	month,
	category_name,
	total_revenue
from (
	select 
	    to_char(o.created_at, 'YYYY-MM') as month,
	    c.name as category_name,
	    sum(oi.quantity * p.price) as total_revenue,
	    rank() over(partition by to_char(o.created_at, 'YYYY-MM') order by(	sum(oi.quantity * p.price)) desc) as rank
	from 
        categories as c
	join 
        products as p on p.category_id = c.id
	join 
        order_items as oi on oi.product_id = p.id
	join   
        orders as o on o.id = oi.order_id
	group by 
        to_char(o.created_at, 'YYYY-MM'), c.name
)
where 
    rank = 1;


--- 8 задание
select
    to_char(p.payment_date, 'YYYY-MM') as month,
    sum(p.amount) as monthly_payments,
    sum(sum(p.amount)) over (order by to_char(p.payment_date, 'YYYY-MM') rows between unbounded preceding and current row) as cumulative_payments
from
    payments as p
where
    p.payment_date >= '2023-01-01' and p.payment_date < '2024-01-01'
group by
    to_char(p.payment_date, 'YYYY-MM');




