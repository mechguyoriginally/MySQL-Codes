use sql_advanced;

-- Return Jones along with all of his direct and indirect reports, add a field in your CTE to show the iteration number for each record – call it ITER_NO. 
-- Your final query should return the columns EMPNO, ENAME, MGR and ITER_NO.
with recursive cte_mgr as(		-- Returns details of mentioned manager
	select
		empno,
        ename,
        mgr,
        1 as iter_no
	from
		emp
	where
		ename = 'JONES'
union all
	(select		-- Returns direct reports of Clark and recurses again to check indirect reports
		e.empno,
        e.ename,
        e.mgr,
        m.iter_no + 1
	from
		cte_mgr m
	join
		emp e on m.empno = e.mgr)
	)
select		-- Returns the consolidated table
	*
from
	cte_mgr;
    
-- Return Clark and all of his direct and indirect reports. Return the EMPNO, ENAME and MGR fields.
with recursive cte_clark as(		-- Returns details of Clark
	select
		empno,
        ename,
        mgr
	from
		emp
	where
		ename = 'CLARK'
union all
	(select		-- Returns direct reports of Clark and recurses again to check indirect reports
		e.empno,
        e.ename,
        e.mgr
	from
		cte_clark c
	join
		emp e on c.empno = e.mgr)
	)
select		-- Returns the consolidated table
	*
from
	cte_clark;
	
-- Return only those employees who are also managers from the EMP table
select
	*
from
	emp e_a
where
	exists(
		select
			mgr
		from
			emp e_b
		where
			e_a.empno = e_b.mgr
		);
        
-- Query the EBA_COUNTRIES table to return values for the total population grouped by REGION_ID, SUB_REGION_ID and ORGANIZATION_REGION_ID, ensure all null value ID’s are populated with 0 instead of null.
-- I would like you to show sub totals for the following combinations only: REGION_ID and SUB_REGION_ID, SUB_REGION_ID and ORGANIZATION_REGION_ID
SELECT
NVL(REGION_ID,0),
NVL(SUB_REGION_ID,0),
NVL(ORGANIZATION_REGION_ID,0),
SUM(POPULATION)
FROM EBA_COUNTRIES
GROUP BY GROUPING SETS ((NVL(REGION_ID,0), NVL(ORGANIZATION_REGION_ID,0)),
(NVL(SUB_REGION_ID,0), NVL(ORGANIZATION_REGION_ID,0)));
-- ABOVE CODE IS FOR ORACLE SQL

-- Query the EBA_COUNTRIES table to return values for the total population grouped by SUB_REGION_ID and ORGANIZATION_REGION_ID, ensure all null value ID’s are populated with 0 instead of null
-- I would like you to show sub totals for the following combinations only: SUB_REGION_ID and ORGANIZATION_REGION_ID, SUB_REGION_ID, ORGANIZATION_REGION_ID, GRAND TOTAL
select
	nvl(sub_region_id,0) as sub_region_nvl,
    nvl(organization_region_id,0) as organization_region_nvl,
    grouping_id(nvl(sub_region_id,0), nvl(organization_region_id,0)) as group_id,
    sum(population)
from
	eba_countries
group by cube(
	sub_region_nvl,
    organization_region_nvl
    );
-- ABOVE CODE IS FOR ORACLE SQL

-- Query the EBA_COUNTRIES table to return values for the total population grouped by SUB_REGION and ORGANIZATION_REGION_ID, ensure all null value ID’s are populated with 0 instead of null.
-- I would like you to show the sub totals for the following combinations only: SUB_REGION_ID and ORGANIZATION_REGION ID, SUB_REGION_ID, GRAND TOTAL
select
    coalesce(sub_region_id,0) as sub_region_nvl,
    coalesce(organization_region_id,0) as organization_region_nvl,
    sum(population)    
from
	eba_countries
group by
		sub_region_nvl,
        organization_region_nvl
        with rollup;

-- Create the following view:
drop view if exists v_order_year_month;
CREATE VIEW V_ORDER_YEAR_MONTH AS
(SELECT 
	date_format(order_datetime, '%Y-%m') AS order_YEAR_MONTH,
	SUM(ORDER_TOTAL) AS YEAR_MONTH_TOTAL
FROM V_ORDERS
GROUP BY 
	order_YEAR_MONTH
);
-- On the above view use Analytical Functions to create a running total column using the YEAR_MONTH_TOTAL field ordered by the order_YEAR_MONTH field in ascending order
select
	*,
    sum(year_month_total)
		over(
        order by
			order_year_month
        rows unbounded preceding
        ) as running_total
from
	v_order_year_month;

-- Find the order total for each order_id and subtract the 3 month rolling average order total (the average of the current month and the previous 2 months of orders).
-- Your solution should only calculate the rolling average for months that are in the same year.
-- (For the assignment questions we are using V_ORDERS created in the "Assignment Data Preparation" lecture)
select
	order_id,
    order_total,
    date_format(order_datetime, '%Y-%m') as order_year_month,
	round(order_total - avg(order_total)		-- rounding the result to 2 digits
			over(
				order by cast(date_format(order_datetime, '%Y%m') as float)		-- converting date result to float for comparison purposes
				range 2 preceding		-- considers only 2 preceding months in the same year
				)
		,2) as req_result
from
	v_orders;

-- Find the difference between the order total for each order_id and the order_id with the maximum order total for that month/year
-- (For the assignment questions we are using V_ORDERS created in the "Assignment Data Preparation" lecture)
select
	order_id,
	date_format(order_datetime, '%m-%Y') as order_month_year,
    order_total,
    order_total - max(order_total) over(partition by date_format(order_datetime, '%m-%Y')) as diff_from_max
from
	v_orders;

-- For each customer rank their orders from highest to lowest in terms of order total
-- (For the assignment questions we are using V_ORDERS created in the "Assignment Data Preparation" lecture)
select
	rank() over(partition by customer_id order by order_total desc) as order_rank_customer,
    order_id,
    customer_id,
    order_total
from
	v_orders;
    
-- Data Preparation for above questions
drop view if exists v_orders;
create view v_orders as
(select
	o.*,
    a.order_total
from
	orders o
left join
	(select
		order_id,
        sum(unit_price * quantity) as order_total
	from
		order_items
	group by
		order_id
	) as a on a.order_id = o.order_id
where
	o.order_status = 'COMPLETE'
);
    
-- Return all countries with open & close parenthesis in its name
select
	name
from
	eba_countries
where
	regexp_instr(name, '\\(.+\\)') > 0;
    
-- Change customer email address from "firstname.lastname@internalmail" to "internalmail@firstname-lastname"
select
	*,
    regexp_replace(email_address, '(.+)(@)(.+)', '\3\2\1')		-- Oracle SQL Syntax
from
	customers;

-- Change customer email address from "firstname.lastname@internalmail" to "firstname-lastname@internalmail"
select
	*,
    regexp_replace(email_address, '\\.', '-') as email_address_2
from
	customers;

-- replace internalmail with internalmail.com in email_address column of customers table
select
	*,
    regexp_replace(email_address, '@internalmail', '@internalmail.com') as correct_email_address
from
	customers;
    
-- Select countries that extracts just first word of the country, only for countries with multiple words in its name
select
	name as full_name,
    regexp_substr(name, '^[A-Z]+') as first_word_countries		-- returns only first word without space or comma
from
	eba_countries
where
	regexp_substr(name, '^[A-Z]+( |,)') is not null		-- filter only favourable countries
order by
	full_name;

-- Select countries which start and end with letter "a"
select
	name,
    regexp_substr(name, '^A.+a$') as a_a_countries
from
	eba_countries
order by
	a_a_countries desc;
    
-- Reurn only countries where first occurrence of letter 'n' appears in position 7
select
	name
from
	eba_countries
where
	regexp_instr(name, 'n') = 7
order by
	name;
 
-- Return all customer name with "Steven" or "Stephen"
select
	*
from
	customers
where
	full_name rlike'^(Steven|Stephen)';
    
select
	*
from
	customers
where
	full_name like '%Steven%' or
    full_name like '%Stephen%';
    
-- Filter only US postcodes from stores table
select
	*
from
	stores
where
	physical_address REGEXP' [A-Z]{2} [0-9]{5}';
    
-- Create Table command to create a table that will store information about how many goals players have scored across 3 seasons (2018, 2019 and 2020)
create table if not exists 
	goals_per_season(
		player varchar(10), 
        year_2018 int, 
        year_2019 int, 
        year_2020 int);
-- Now individually execute the 3 Insert commands to insert records into our newly created table
insert into goals_per_season values ('Rick', 51,31,38);
insert into goals_per_season values ('Jeff', 28,37,36);
insert into goals_per_season values ('George', 40,55,48);
-- Your assignment question is to UNPIVOT the GOALS_PER_SEASON Table
SELECT 
	* 
FROM 
	GOALS_PER_SEASON
UNPIVOT
	(GOALS FOR SEASON IN (YEAR_2018 AS '2018', YEAR_2019 AS '2019', YEAR_2020 AS '2020')
    );
-- delete the created tables
drop table if exists 
	goals_per_season

-- Pivot the EMP Table to show the total salary by JOB and DEPTNO in matrix form (pivoting the JOB column)
-- static result for pivot query
select
	distinct job
from
	emp;

select
	*
from
	(select
		dept_no,
        job,
        sum(sal)	-- sum of salaries by each dept
	from
		emp
	)
pivot(sum(sal) for
		job in ('PRESIDENT', 'MANAGER', 'ANALYST', 'CLERK', 'SALESMAN')
    );