use employees_mod;

-- Task 4: Create an SQL stored procedure that will allow you to obtain the average male and female salary per department within a certain salary range. 
-- Let this range be defined by two values the user can insert when calling the procedure.
-- Finally, visualize the obtained result-set in Tableau as a double bar chart. 
drop procedure if exists avg_salary_dept;

delimiter //
create procedure avg_salary_dept(in lower_limit_salary float, 
									upper_limit_salary float)
begin
	select
		dept_name,
        gender,
        avg(salary) as avg_salary
	from
		t_departments d
	join
		t_dept_emp de on d.dept_no = de.dept_no
	join
		t_employees e on de.emp_no = e.emp_no
	join
		t_salaries s on e.emp_no = s.emp_no
	where
		salary between lower_limit_salary and upper_limit_salary
	group by
		dept_name,
        gender
	order by
		dept_name;
end //
delimiter ;

call employees_mod.avg_salary_dept(50000, 90000);

-- Task 3: Compare the average salary of female versus male employees in the entire company until year 2002, and add a filter allowing you to see that per each department.
select
	year(s.from_date) as calendar_year,
    dept_name,
    gender,
    avg(salary) as avg_salary
from
	t_salaries s
join
	t_employees e on e.emp_no = s.emp_no
join
	t_dept_emp de on e.emp_no = de.emp_no
join
	t_departments d on d.dept_no = de.dept_no
group by
	calendar_year,
    dept_name,
    gender
having
	calendar_year <= 2002
order by
    dept_name,
    calendar_year;
    
-- Task 2: Compare the number of male managers to the number of female managers from different departments for each year, starting from 1990.
SELECT 
    d.dept_name,
    ee.gender,
    dm.emp_no,
    dm.from_date,
    dm.to_date,
    e.calendar_year,
    CASE
        WHEN YEAR(dm.to_date) >= e.calendar_year AND YEAR(dm.from_date) <= e.calendar_year THEN 1
        ELSE 0
    END AS active
FROM
    (SELECT 
        YEAR(from_date) AS calendar_year
    FROM
        t_dept_manager
    GROUP BY calendar_year) e
            CROSS JOIN
	t_dept_manager dm
	    JOIN
	t_departments d ON dm.dept_no = d.dept_no
            JOIN 
    t_employees ee ON dm.emp_no = ee.emp_no
ORDER BY dm.emp_no, calendar_year;

-- Task 1: Create a visualization that provides a breakdown between the male and female employees working in the company each year, starting from 1990. 
select 
	year(de.from_date) as calendar_year,
    e.gender,
    count(e.emp_no) as no_of_employees
from
	t_dept_emp de
join
	t_employees e on de.emp_no = e.emp_no
group by
	calendar_year,
    gender
having
	calendar_year >= 1990
order by
	calendar_year;