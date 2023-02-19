-- LISTS OF CUSTOMERS
select row1.o1 , trim('[]' from concat_ws(' ', row1.cus1, row0.cus0)) as Customer FROM (
    select order_id as o1, cus as cus1 , ROW_NUMBER() over(order by row) as r1 from (
        select order_id, value as cus, ROW_NUMBER() over(order by order_id) as row from Invoices CROSS APPLY string_split(Participants, ' ') ) as rows0 where row %2 = 1) 
        as row1
    join (
    select order_id as o2, cus as cus0 , ROW_NUMBER() over(order by row) as r0 from (
        select order_id, value as cus, ROW_NUMBER() over(order by order_id) as row from Invoices CROSS APPLY string_split(Participants, ' ') ) as rows0 where row %2 = 0) 
        as row0
    on r1 = r0

-- JOIN ORDERLEADS AND INVOICES
select o.Order_Id, o.Company_Id, o.Company_Name, o.Order_Value, i.Participants, i.Meal_Price, i.Type_of_Meal, o.Converted  from OrderLeads o 
join Invoices i 
on o.Order_Id = i.Order_Id

-- LISTS OF ORDERS
with converted_sales (order_id, Company_Id, Company_Name, Customer, Order_Value, Converted) as (
select row1.o1, o.Company_Id, o.Company_Name, trim('[]' from concat_ws(' ', row1.cus1, row0.cus0)) as Customer, o.Order_Value, o.Converted FROM (
    select order_id as o1, cus as cus1 , ROW_NUMBER() over(order by row) as r1 from (
        select order_id, value as cus, ROW_NUMBER() over(order by order_id) as row from Invoices CROSS APPLY string_split(Participants, ' ') ) as rows0 where row %2 = 1) 
        as row1
    join (
    select order_id as o2, cus as cus0 , ROW_NUMBER() over(order by row) as r0 from (
        select order_id, value as cus, ROW_NUMBER() over(order by order_id) as row from Invoices CROSS APPLY string_split(Participants, ' ') ) as rows0 where row %2 = 0) 
        as row0
    on r1 = r0
    join OrderLeads o on row1.o1 = o.Order_Id
    join Invoices i on row1.o1 = i.Order_Id
)

-- IDENTIFYING PROFITABLE CUSTOMER SEGMENT BASED ON ORDER VALUE AND CONVERTED SALES
select Customer, Company_id, Company_name, sum(order_value) as Order_value, sum(converted) as Number_of_orders from converted_sales
where Converted = 1
group by customer, Company_Id, Company_Name
order by order_value DESC

-- TEMP TABLE
Drop table if exists #Summary_customer_order
Create Table #Summary_customer_order
(
order_id nvarchar(50),
Company_Id nvarchar(50),
Company_Name nvarchar(50),
Customer nvarchar(100),
Order_value int,
Converted int 
)
insert into #Summary_customer_order
select row1.o1, o.Company_Id, o.Company_Name, trim('[]' from concat_ws(' ', row1.cus1, row0.cus0)) as Customer, o.Order_Value, o.Converted FROM (
    select order_id as o1, cus as cus1 , ROW_NUMBER() over(order by row) as r1 from (
        select order_id, value as cus, ROW_NUMBER() over(order by order_id) as row from Invoices CROSS APPLY string_split(Participants, ' ') ) as rows0 where row %2 = 1) 
        as row1
    join (
    select order_id as o2, cus as cus0 , ROW_NUMBER() over(order by row) as r0 from (
        select order_id, value as cus, ROW_NUMBER() over(order by order_id) as row from Invoices CROSS APPLY string_split(Participants, ' ') ) as rows0 where row %2 = 0) 
        as row0
    on r1 = r0
    join OrderLeads o on row1.o1 = o.Order_Id
    join Invoices i on row1.o1 = i.Order_Id


-- CREATE VIEW

create view converted_sales as
with converted_sales (order_id, Company_Id, Company_Name, Customer, Order_Value, Converted) as (
select row1.o1, o.Company_Id, o.Company_Name, trim('[]' from concat_ws(' ', row1.cus1, row0.cus0)) as Customer, o.Order_Value, o.Converted FROM (
    select order_id as o1, cus as cus1 , ROW_NUMBER() over(order by row) as r1 from (
        select order_id, value as cus, ROW_NUMBER() over(order by order_id) as row from Invoices CROSS APPLY string_split(Participants, ' ') ) as rows0 where row %2 = 1) 
        as row1
    join (
    select order_id as o2, cus as cus0 , ROW_NUMBER() over(order by row) as r0 from (
        select order_id, value as cus, ROW_NUMBER() over(order by order_id) as row from Invoices CROSS APPLY string_split(Participants, ' ') ) as rows0 where row %2 = 0) 
        as row0
    on r1 = r0
    join OrderLeads o on row1.o1 = o.Order_Id
    join Invoices i on row1.o1 = i.Order_Id
)
select Customer, Company_id, Company_name, sum(order_value) as Order_value, sum(converted) as Number_of_orders from converted_sales
where Converted = 1
group by customer, Company_Id, Company_Name
