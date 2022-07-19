show databases;

use coffee_store;
show tables;

select*from customers;
select*from orders;
select*from products;

select p.Name, p.Price, o.Order_Time from products p
join orders o on o.Product_ID = p.ID
join customers c on o.Customer_ID = c.ID
where c.Gender = 'F' and o.Order_Time between '20170101' and '20170131';

select p.Name, o.Order_Time from products p
join orders o on o.Product_ID = p.ID
where p.Name = 'Filter' and o.Order_Time between '20170115' and '20170214';

select	o.ID, c.Phone_Number from orders o
join customers c on o.Customer_ID = c.ID
where o.Product_ID = 4;

select products.name, orders.Order_Time from products
inner join orders on orders.Product_ID = products.ID;