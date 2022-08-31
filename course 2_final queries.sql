use employees;

-- Exercise 10: Based on the previous exercise, you can now try to create a third function that also accepts a second parameter. Let this parameter be a character sequence. 
-- Evaluate if its value is 'min' or 'max' and based on that retrieve either the lowest or the highest salary, respectively (using the same logic and code structure from Exercise 9). 
-- If the inserted value is any string value different from ‘min’ or ‘max’, let the function return the difference between the highest and the lowest salary of that employee.
drop function if exists f_contract;

delimiter //
create function f_contract(p_emp_no int, p_char varchar(10)) returns int
deterministic
begin
	declare
		v_salary int;
	        
	select
		case p_char
			when 
				'max'
			then
				max(salary) 
			when 
				'min'
			then
				min(salary) 
			else
				max(salary) - min(salary)
		end as salary
	into
		v_salary
	from
		salaries 
	where
		emp_no = p_emp_no;
	return
		v_salary;
end//
delimiter ;

select employees.f_contract(11356, 'max');
select employees.f_contract(11356, 'min');
select employees.f_contract(11356, 'maxxx');

-- Exercise 9: Define a function that retrieves the largest contract salary value of an employee. Apply it to employee number 11356. 
drop function if exists f_largest_contract;

delimiter //
create function f_largest_contract(p_emp_no int) returns int
deterministic
begin
	declare
		v_largest_salary int;
        
	select
		max(salary)
	into
		v_largest_salary
	from
		salaries 
	where
		emp_no = p_emp_no;
	return
		v_largest_salary;
end//
delimiter ;

select f_largest_contract(11356) as highest_salary;
-- In addition, what is the lowest contract salary value of the same employee? You may want to create a new function that to obtain the result.
drop function if exists f_smallest_contract;

delimiter //
create function f_smallest_contract(p_emp_no int) returns int
deterministic
begin
	declare
		v_smallest_salary int;
        
	select
		min(salary)
	into
		v_smallest_salary
	from
		salaries 
	where
		emp_no = p_emp_no;
	return
		v_smallest_salary;
end//
delimiter ;

select f_smallest_contract(11356) as lowest_salary;

-- Exercise 8: Create a trigger that checks if the hire date of an employee is higher than the current date. 
-- If true, set the hire date to equal the current date. Format the output appropriately (YY-mm-dd).
-- Extra challenge: You can try to declare a new variable called 'today' which stores today's data, and then use it in your trigger!
drop trigger if exists t_hire_date;

delimiter //
create trigger t_hire_date
before insert on employees
for each row
begin
	declare today date;
    set
		today = date_format(sysdate(),'%Y-%m-%d');
	if 
		new.hire_date > today
	then
		set new.hire_date = today;
	end if;
end //
delimiter //
-- After creating the trigger, execute the following code to see if it's working properly.
delete from
	employees
where
	emp_no = 999904;
    
INSERT employees VALUES ('999904', '1970-01-31', 'John', 'Johnson', 'M', '2025-01-01');  
SELECT 
    *
FROM
    employees
ORDER BY emp_no DESC;

-- Exercise 7: How many contracts have been registered in the ‘salaries’ table with duration of more than one year and of value higher than or equal to $100,000?
SELECT 
    COUNT(*)
FROM
    salaries
WHERE
    salary >= 100000
        AND DATEDIFF(to_date, from_date) > 365;
-- Exercise 6: Create a procedure that asks you to insert an employee number and that will obtain an output containing the same number, 
-- as well as the number and name of the last department the employee has worked in.
drop procedure if exists emp_detail;

delimiter //
create procedure emp_detail(in emp_num int)
begin
	select
		e.emp_no,
        de.dept_no,
        d.dept_name
	from
		employees e
	join
		dept_emp de on de.emp_no = e.emp_no
	join
		departments d on d.dept_no = de.dept_no
	where
		e.emp_no = emp_num
	order by
		de.from_date desc
	limit 1;
end //
delimiter ;
-- Finally, call the procedure for employee number 10010.
-- If you've worked correctly, you should see that employee number 10010 has worked for department number 6 - "Quality Management".
call employees.emp_detail(10010);

-- Exercise 5: Retrieve a list of all employees from the ‘titles’ table who are engineers.
select
	e.emp_no,
    e.first_name,
    e.last_name,
    e.gender,
    t.title,
    t.from_date,
    t.to_date
from
	titles t
join
	employees e on e.emp_no = t.emp_no
where
	title like '%engineer%';
-- Repeat the exercise, this time retrieving a list of all employees from the ‘titles’ table who are senior engineers.
select
	e.emp_no,
    e.first_name,
    e.last_name,
    e.gender,
    t.title,
    t.from_date,
    t.to_date
from
	titles t
join
	employees e on e.emp_no = t.emp_no
where
	title = 'senior engineer';
-- Exercise 4: Retrieve a list of all employees that have been hired in 2000.
select
	*
from
	employees
where
	year(hire_date) = 2000;
    
-- Exercise 3: Obtain a table containing the following three fields for all individuals whose employee number is not greater than 10040:
-- employee number
-- the lowest department number among the departments where the employee has worked in
-- assign '110022' as 'manager' to all individuals whose employee number is lower than or equal to 10020, and '110039' to those whose number is between 10021 and 10040 inclusive.
-- If you've worked correctly, you should obtain an output containing 40 rows.
select
	emp_no,
    (select	
		min(dept_no)
	from
		dept_emp de
	where
		de.emp_no = e.emp_no
	) as dept_no,
    case
		when emp_no <= 10020
			then 110022
		when emp_no between	10021 and 10040
			then 110039
	end as manager_id
from
	employees e
where
	e.emp_no <= 10040
group by
	e.emp_no;

-- Exercise 2: Find the lowest department number encountered in the 'dept_emp' table. Then, find the highest department number.
select
	min(dept_no),
    max(dept_no)
from
	dept_emp;
    
-- Exercise 1: Find the average salary of the male and female employees in each department.
	select
		dept_name,
        gender,
        avg(salary) as avg_salary
	from
		departments d
	join
		dept_emp de on d.dept_no = de.dept_no
	join
		employees e on de.emp_no = e.emp_no
	join
		salaries s on e.emp_no = s.emp_no
	group by
		dept_name,
        gender
	order by
		dept_name;