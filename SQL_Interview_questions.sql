--to generate the numbers from 1 to 10 in oracle

SELECT LEVEL AS n
FROM   dual
CONNECT BY LEVEL <= 10;

--Employee and manager name with connect by prior in oracle

SELECT  e.empno,
        e.ename
        -,PRIOR e.ename AS manager_name
FROM    emp e
START WITH e.mgr IS NULL               -- roots (CEOs)
CONNECT BY PRIOR e.empno = e.mgr;     -- parent emp_id = child manager_id

--Each row shows an employee; PRIOR e.ename is the parent (manager) name.
--Add WHERE LEVEL > 1 if you want to exclude the top-level (which has no manager).

--B) Only the immediate manager for a specific employee
SELECT  PRIOR e.ename AS manager_name
FROM    emp e
START WITH e.empno = :empno                 -- your employee
CONNECT BY PRIOR e.empno = e.mgr      -- walk *up* to parent
AND      LEVEL = 2;                           -- the first step up is the manager

--C) Full chain of managers (top → employee)
SELECT  LEVEL           AS lvl,
        e.emp_id,
        e.ename,
        SYS_CONNECT_BY_PATH(e.ename, ' / ') AS chain
FROM    emp e
START WITH e.manager_id IS NULL
CONNECT BY PRIOR e.emp_id = e.manager_id;


--Or start at :emp_id and flip the CONNECT BY to walk upward:

SELECT  e.empno,
        e.ename,
        LEVEL AS lvl_up,
        SYS_CONNECT_BY_PATH(e.ename, ' -> ') AS up_chain
FROM    emp e
START WITH e.empno = :empno
CONNECT BY PRIOR e.mgr = e.empno;

select *
from emp e
where e.sal > (select cast(avg(sal) as int) as avgsal from emp );

with avg_sal (avgsal) as 
(select cast(avg(sal) as int) as avgsal from emp )
select *
from emp e, avg_sal avg
where e.sal > avg.avgsal;


select cast(avg(sumsal) as int) avg
from 
(select e.deptno, cast(sum(sal) as int) sumsal
from emp e
group by deptno) as total_avg


select * from 
(select e.deptno, cast(sum(sal) as int) sumsal_dept
from emp e
group by deptno) sum_sal_dept
join
(select cast(avg(sumsal) as int) avgsumsal
from 
    (select e.deptno, cast(sum(sal) as int) sumsal
    from emp e
    group by deptno) as total_avg) as totalavg
on sum_sal_dept.sumsal_dept > totalavg.avgsumsal


with sum_sal_dept (deptno,sumsal_dept) as 
    (select e.deptno, cast(sum(sal) as int) sumsal_dept
    from emp e
    group by deptno),
    totalavg (sum_avg)  as 
    (select cast(avg(sumsal_dept) as int) from sum_sal_dept)
select * from sum_sal_dept , totalavg where sumsal_dept > sum_avg

select e.*,
row_number() over (partition by deptno order by sal desc) as rn
from emp e
qualify rn=2

select e.*,
lag(sal) over (partition by deptno order by deptno desc) as previous_sal, -- default value is null
lag(sal,2,0) over (partition by deptno order by deptno desc) as previous_2_sal, -- default values 0
lead(sal) over (partition by deptno order by deptno desc) as previous_sal, -- default value is null
lead(sal,2,0) over (partition by deptno order by deptno desc) as previous_2_sal, -- default values 0
from emp e;

select * from purchases;
select * from customers;
select * from orders;

--Find customers with successful multiple purchases in the last 1 month. Purchase is considered successful if they are not returned within 1 week of purchase. 

-- SOLUTION:
select customer_id
from purchases
where purchase_date > cast(purchase_date - interval '1 month' as date)
and (return_date is null 
    or return_date > cast(purchase_date + interval '1 week' as date))
group by customer_id
having count(customer_id) > 1;


- Problem 2: Latest Order Summary per Customer

-- Problem Statement: Write an SQL query to fetch the customer name, their latest order date and total value of the order. If a customer made multiple orders on the latest order date then fetch total value for all the orders in that day. If a customer has not done an order yet, display the “9999-01-01” as latest order date and 0 as the total order value.

-- SOLUTION:
select customer
, COALESCE(order_date, '9999-01-01') as last_order_date
, COALESCE(SUM(total_cost), 0) as total_value
from (SELECT o.*,c.name as customer
    , rank() over(partition by o.customer_id order by order_date desc) as rnk 
    FROM orders2 o
    right join customers c on c.customer_id = o.customer_id) x
where x.rnk = 1
group by customer_id, customer, order_date;

-- Problem Statement: Find customers who have not placed any orders yet in 2025 but had placed orders in every month of 2024 and had placed orders in at least 6 of the months in 2023. Display the customer name.

with customer_2025 as 
        (select * from orders where year(order_date)=2025),
     customer_2024 as 
        (select customer_id,
                count(month(order_date)) as unique_monthly_orders
         from orders where year(order_date)=2024
         group by customer_id
         having count(distinct(month(order_date))) >= 12
         ),
     customer_2023 as 
         ( select customer_id,
                  count(month(order_date)) as unique_monthly_orders 
           from orders
           where year(order_date)=2023
           group by customer_id
           having count(distinct(month(order_date))) >= 6 
         )
select c.name as customer
from customers c
join customer_2024 c24 on c24.customer_id =c.customer_id
join customer_2023 c23 on c23.customer_id =c.customer_id
where c.customer_id not in (select customer_id from customer_2025);

with cte as 
    ( select c.customer_id,c.name as customer,
             year(order_date) order_year,
             count(month(order_date)) as unique_monthly_orders
      from orders o
      join customers c on c.customer_id = o.customer_id
           group by c.customer_id,c.name,order_year
    )
select c23.customer
from cte c23
join cte c24 on c23.customer_id = c24.customer_id
where c23.order_year=2023 and c23.unique_monthly_orders >=6
and c24.order_year=2024 and c24.unique_monthly_orders >=12
and c23.customer_id not in(select customer_id from cte where order_year=2025)


-- Solution 1:
with customers_2025 as
        (select * 
        from orders
        where extract(year from order_date) = 2025),
    customers_2024 as 
        (select customer_id
        , count(extract(month from order_date)) as unique_monthly_orders
        from orders
        where extract(year from order_date) = 2024
        group by customer_id
        having count(distinct extract(month from order_date)) >= 12),
    customers_2023 as
        (select customer_id
        , count(extract(month from order_date)) as unique_monthly_orders
        from orders
        where extract(year from order_date) = 2023
        group by customer_id
        having count(distinct extract(month from order_date)) >= 6)
select c.name as customer
from customers c
join customers_2024 c24 on c24.customer_id = c.id
join customers_2023 c23 on c23.customer_id = c.id
where c.id not in (select customer_id from customers_2025);


-- Solution 2:
with cte as 
    (select o.customer_id, c.name as customer
    , extract(year from order_date) as order_year
    , count(distinct extract(month from order_date)) as unique_monthly_orders
    from orders o
    join customers c on c.customer_id = o.customer_id
    group by o.customer_id, c.name, order_year)
select c23.customer
from cte c23
join cte c24 on c23.customer_id = c24.customer_id
where c23.order_year = 2023 and c23.unique_monthly_orders >= 6
and c24.order_year = 2024 and c24.unique_monthly_orders >= 12
and c23.customer_id not in (select customer_id from cte where order_year = 2025);
