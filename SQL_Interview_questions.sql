--to generate the numbers from 1 to 10 in oracle

SELECT LEVEL AS n
FROM   dual
CONNECT BY LEVEL <= 10;

--Employee and manager name with connect by prior in oracle

SELECT  e.emp_id,
        e.emp_name,
        PRIOR e.emp_name AS manager_name
FROM    employees e
START WITH e.manager_id IS NULL               -- roots (CEOs)
CONNECT BY PRIOR e.emp_id = e.manager_id;     -- parent emp_id = child manager_id



--Each row shows an employee; PRIOR e.emp_name is the parent (manager) name.

--Add WHERE LEVEL > 1 if you want to exclude the top-level (which has no manager).

--B) Only the immediate manager for a specific employee
SELECT  PRIOR e.emp_name AS manager_name
FROM    employees e
START WITH e.emp_id = :emp_id                 -- your employee
CONNECT BY PRIOR e.manager_id = e.emp_id      -- walk *up* to parent
AND      LEVEL = 2;                           -- the first step up is the manager

--C) Full chain of managers (top → employee)
SELECT  LEVEL           AS lvl,
        e.emp_id,
        e.emp_name,
        SYS_CONNECT_BY_PATH(e.emp_name, ' / ') AS chain
FROM    employees e
START WITH e.manager_id IS NULL
CONNECT BY PRIOR e.emp_id = e.manager_id;


--Or start at :emp_id and flip the CONNECT BY to walk upward:

SELECT  LEVEL AS lvl_up,
        e.emp_id,
        e.emp_name,
        SYS_CONNECT_BY_PATH(e.emp_name, ' -> ') AS up_chain
FROM    employees e
START WITH e.emp_id = :emp_id
CONNECT BY PRIOR e.manager_id = e.emp_id;

select *
from emp e
where e.sal > (select cast(avg(sal) as int) as avgsal from emp );

with avg_sal (avgsal) as 
(select cast(avg(sal) as int) as avgsal from emp )
select *
from emp e, avg_sal avg
where e.sal > avg.avgsal;

select e.deptno, cast(sum(sal) as int) sumsal
from emp e
group by deptno

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
from emp e





