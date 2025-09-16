---- CTE Use cases

select * from emp_before_update;

with cte_avg_sal (avg_sal) as 
    (select cast(avg(sal)as int) as avg_sal from emp_before_update)
select * from emp_before_update e, cte_avg_sal av
where e.sal > av.avg_sal;

select * from emp_before_update e
where e.sal > (select cast(avg(sal)as int) from emp_before_update);

select * from sales;

select store_id,sum(cost) as total_sales_per_store
from sales s
group by store_id

select cast(avg(total_sales_per_store) as int) avg_all_stores from (
select store_id,sum(cost) as total_sales_per_store
from sales s
group by store_id ) x

select * from 
    (select store_id,sum(cost) as total_sales_per_store
        from sales s
        group by store_id ) as total_sales_by_store
    join
    (select cast(avg(total_sales_per_store) as int) avg_all_stores from (
        select store_id,sum(cost) as total_sales_per_store
        from sales s
        group by store_id )x ) as avg_of_total_stores_sales
    on total_sales_by_store.total_sales_per_store >  avg_of_total_stores_sales.avg_all_stores


with total_sales(store_id, avg_sales_by_store) as
    (select store_id, cast(sum(cost)as int) as avg_sales_by_store from sales s group by store_id),
    avg_sales_by_total_store (avg_sales_for_all_stores)  as 
    (select cast(avg(avg_sales_by_store) as int) as avg_sales_for_all_stores from total_sales)
select * 
from total_sales ts join avg_sales_by_total_store av on   ts.avg_sales_by_store > av.avg_sales_for_all_stores
