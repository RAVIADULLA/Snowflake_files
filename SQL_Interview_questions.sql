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




