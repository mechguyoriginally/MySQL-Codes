use employees;

-- Extract the employee number, first name, and last name of the first 100 employees, and 
-- add a fourth column, called “current_employee” saying “Is still employed” if the employee is still working in the company, or “Not an employee anymore” if they aren’t.
select
	e.emp_no,
    e.first_name,
    e.last_name,
    case
		when max(de.to_date) > sysdate()
			then 'is still employed'
		else
			'not an employee anymore'
    end as current_employee
from
	employees e
left join
	dept_emp de on de.emp_no = e.emp_no
group by e.emp_no
order by e.emp_no
limit 100;
 
-- Extract a dataset containing the following information about the managers: employee number, first name, and last name. 
-- Add two columns at the end – one showing the difference between the maximum and minimum salary of that employee, and another one saying whether this salary raise was higher than $30,000 or NOT.
select
	dm.emp_no,
	e.first_name,
	e.last_name,
	max(s.salary) - min(s.salary) as salary_diff,
	case
		when max(s.salary) - min(s.salary) > 30000
			then 'Yes'
		else
			'No'
	end as more_than_30k_increase
from
	dept_manager dm
join
	employees e	on	e.emp_no = dm.emp_no
join
	salaries s	on	s.emp_no = e.emp_no
group by e.emp_no;
-- If possible, provide more than one solution.
select
	dm.emp_no,
	e.first_name,
	e.last_name,
	max(s.salary) - min(s.salary) as salary_diff,
	if(max(s.salary) - min(s.salary) > 30000, 'Yes', 'No')
	as more_than_30k_increase
from
	dept_manager dm
join
	employees e	on	e.emp_no = dm.emp_no
join
	salaries s	on	s.emp_no = e.emp_no
group by e.emp_no;

-- obtain a result set containing the employee number, first name, and last name of all employees with a number higher than 109990.
 select
	emp_no,
	first_name,
    last_name
from
	employees
where
	emp_no > 109990;
-- Create a fourth column in the query, indicating whether this employee is also a manager, according to the data provided in the dept_manager table, or a regular employee. 
 select
	e.emp_no,
	e.first_name,
    e.last_name,
    case
		when dm.emp_no is not null
			then 'Manager'
		else 'Employee'
        end as position
from
	employees e
left join
	dept_manager dm
on
	dm.emp_no = e.emp_no
where
	e.emp_no > 109990;

-- Select all records from the ‘salaries’ table of people whose salary is higher than $89,000 per annum.
select
	*
from
	salaries
where
	salary > 89000;
-- Then, create an index on the ‘salary’ column of that table, and check if it has sped up the search of the same SELECT statement.
create index i_salary
on salaries(salary);

-- Create a trigger that checks if the hire date of an employee is higher than the current date. If true, set this date to be the current date. Format the output appropriately (YY-MM-DD).
drop trigger if exists t_emp_hire_date;

delimiter //
create trigger t_emp_hire_date
before insert on employees
for each row
begin
	if
		new.hire_date > date_format(sysdate(),'%Y-%m-%d')
	then
		set new.hire_date = date_format(sysdate(),'%Y-%m-%d');
	end if;
end //
delimiter ;

delete from employees
where
	emp_no = 999904;
INSERT employees VALUES ('999904', '1970-01-31', 'John', 'Johnson', 'M', '2025-01-01');  

SELECT  
    *  
FROM  
    employees
ORDER BY emp_no DESC;

-- Create a function called ‘emp_info’ that takes for parameters the first and last name of an employee, and returns the salary from the newest contract of that employee.
drop function if exists emp_info;

delimiter //
create function emp_info
	(	p_first_name	varchar(255),
		p_last_name		varchar(255)
	)
returns	
	decimal(10,2)
    
deterministic

begin
	declare
		v_salary		decimal(10,2);
	declare
		v_max_from_date	date;

	select 
		max(s.from_date)
	into
		v_max_from_date
	from
		salaries s
	join
		employees e
	on
		e.emp_no = s.emp_no
	where
		p_first_name = e.first_name	and
        p_last_name = e.last_name;
		
	select 
		s.salary
	into
		v_salary
	from
		salaries s
	join
		employees e
	on
		e.emp_no = s.emp_no
	where
		p_first_name = e.first_name	and
        p_last_name = e.last_name 	and
        v_max_from_date = s.from_date;
  
	return
		v_salary;
end //
delimiter ;
-- Finally, select this function.
SELECT EMP_INFO('Aruna', 'Journel');

-- Create a variable, called ‘v_emp_no’, where you will store the output of the procedure you created in the last exercise.
set @v_emp_no = 0;
-- Call the same procedure, inserting the values ‘Aruna’ and ‘Journel’ as a first and last name respectively.
call employees.emp_info('Aruna','Journel',@v_emp_no);
-- Finally, select the obtained output.
select @v_emp_no;

-- Create a procedure called ‘emp_info’ that uses as parameters the first and the last name of an individual, and returns their employee number.
drop procedure if exists emp_info;

delimiter //
create procedure emp_info
	(in 
		e_first_name varchar(14), 
        e_last_name varchar(16),
	out
		e_emp_no int)
begin
select emp_no
into e_emp_no
	from employees
where
	first_name = e_first_name and
    last_name = e_last_name;
end //
delimiter ;

    

-- Create a procedure that will provide the average salary of all employees.
delimiter //
create procedure avg_salary_employees()
begin
	select avg(salary)
		from salaries s
	join employees e on
		s.emp_no = e.emp_no;
end //
delimiter ;
-- Then, call the procedure.
call employees.avg_salary_employees();

-- Create a view that will extract the average salary of all managers registered in the database. Round this value to the nearest cent.
-- If you have worked correctly, after executing the view from the “Schemas” section in Workbench, you should obtain the value of 66924.27.
CREATE OR REPLACE VIEW v_manager_avg_salary AS
    SELECT 
        round(avg(salary),2)
    FROM
        salaries
    WHERE
        emp_no IN (SELECT 
                emp_no
            FROM
                dept_manager);
-- Starting your code with “DROP TABLE”, create a table called “emp_manager” (emp_no – integer of 11, not null; dept_no – CHAR of 4, null; manager_no – integer of 11, not null). 
drop table if exists		emp_manager;
CREATE TABLE IF NOT EXISTS emp_manager (
    emp_no INT(11) NOT NULL,
    dept_no CHAR(4) NULL,
    manager_no INT(11) NOT NULL
);
-- Fill emp_manager with data about employees, the number of the department they are working in, and their managers.
-- assign employee number 110022 as a manager to all employees from 10001 to 10020 (subset A), and employee number 110039 as a manager to all employees from 10021 to 10040 (subset B).
Insert INTO emp_manager 
	SELECT	U.*
		FROM
			(select 
				A.* 
			from
				(SELECT 
					e.emp_no AS employee_id,
					MIN(de.dept_no) AS department_code,
					(SELECT 
							emp_no
						FROM
							dept_manager
						WHERE
							emp_no = 110039) AS manager_id
				FROM
					employees e
					JOIN
				dept_emp de ON de.emp_no = e.emp_no
			WHERE
				e.emp_no BETWEEN 10021 AND 10040
			GROUP BY e.emp_no) 
		as A
UNION select
		B.*
        from (SELECT 
    e.emp_no AS employee_id,
    MIN(de.dept_no) AS department_code,
    (SELECT 
            emp_no
        FROM
            dept_manager
        WHERE
            emp_no = 110022) AS manager_id
FROM
    employees e
        JOIN
    dept_emp de ON de.emp_no = e.emp_no
WHERE
    e.emp_no BETWEEN 10001 AND 10020
GROUP BY e.emp_no) as B
-- Use the structure of subset A to create subset C, where you must assign employee number 110039 as a manager to employee 110022.
UNION select
		C.*
        from (SELECT 
    e.emp_no AS employee_id,
    MIN(de.dept_no) AS department_code,
    (SELECT 
            emp_no
        FROM
            dept_manager
        WHERE
            emp_no = 110039) AS manager_id
FROM
    employees e
        JOIN
    dept_emp de ON de.emp_no = e.emp_no
WHERE
    e.emp_no = 11022
GROUP BY e.emp_no) as C
-- Following the same logic, create subset D. Here you must do the opposite - assign employee 110022 as a manager to employee 110039.
UNION select
		D.*
        from (SELECT 
    e.emp_no AS employee_id,
    MIN(de.dept_no) AS department_code,
    (SELECT 
            emp_no
        FROM
            dept_manager
        WHERE
            emp_no = 110022) AS manager_id
FROM
    employees e
        JOIN
    dept_emp de ON de.emp_no = e.emp_no
WHERE
    e.emp_no = 11039
GROUP BY e.emp_no) as D )AS U;
-- Your output must contain 42 rows.
SELECT 
    *
FROM
    emp_manager;

-- Select the entire information for all employees whose job title is “Assistant Engineer”. 
select	*
	from	employees
    where	emp_no in(	select	emp_no
						from	titles
                        where	title = 'Assistant Engineer');

SELECT 
    *
FROM
    employees e
WHERE
    EXISTS( SELECT 
            *
        FROM
            titles t
        WHERE
            title = 'Assistant Engineer'
                AND t.emp_no = e.emp_no);

-- Extract the information about all department managers who were hired between the 1st of January 1990 and the 1st of January 1995.
select	*
	from	employees e
    where	emp_no	
		in (select	emp_no
			from	dept_manager
            where	e.hire_date between '1990-01-01' and '1995-01-01');
   
 select	*
	from	employees 
    where	hire_date	between '1990-01-01' and '1995-01-01'
		and	emp_no	
		in (select	emp_no
			from	dept_manager)
            ;  
            
SELECT *
FROM dept_manager
WHERE emp_no IN (SELECT
            emp_no  FROM
            employees
        WHERE  hire_date BETWEEN '1990-01-01' AND '1995-01-01');
        
-- How many male and how many female managers do we have in the ‘employees’ database?
select	e.gender, count(dm.emp_no)
	from	employees e
    join	dept_manager dm on dm.emp_no = e.emp_no
    group by	gender;
    
-- Select all managers’ first and last name, hire date, job title, start date, and department name.
select	dm.emp_no, e.first_name, e.last_name, e.hire_date, t.title, t.from_date as start_date, d.dept_name
	from	dept_manager dm
    join	employees e	on	dm.emp_no = e.emp_no
    join	titles t	on	e.emp_no = t.emp_no
    join	departments d	on	d.dept_no =	dm.dept_no;
    
-- Return a list with the first 10 employees with all the departments they can be assigned to.
-- Hint: Don’t use LIMIT; use a WHERE clause.
select e.emp_no, de.dept_no
	from employees e
    cross join	dept_emp de
    where	e.emp_no <= 10010
    order by	e.emp_no, de.dept_no;
-- Use a CROSS JOIN to return a list with all possible combinations between managers from the dept_manager table and department number 9.
select	dm.*, e.*
	from dept_manager dm
    cross join	employees e
    where	dm.dept_no = 'd009'
    order by	e.emp_no;
-- Select the first and last name, the hire date, and the job title of all employees whose first name is “Margareta” and have the last name “Markovitch”.
select	e.first_name, e.last_name, e.hire_date, t.title
	from	employees e
    join	titles t on e.emp_no = t.emp_no
    where	e.first_name = 'Margareta' and e.last_name = 'Markovitch';
    
-- Extract a list containing information about all managers’ employee number, first and last name, department number, and hire date. Use the old type of join syntax to obtain the result.
select	dm.emp_no, e.first_name, e.last_name, dm.dept_no, e.hire_date
	from	dept_manager dm, employees e
    where	dm.emp_no = e.emp_no
	order by	e.emp_no;
    
-- Join the 'employees' and the 'dept_manager' tables to return a subset of all the employees whose last name is Markovitch. See if the output contains a manager with that name.  
select	e.emp_no, e.last_name, dm. dept_no as manager_dept_no
	from	employees e
    left join	dept_manager dm on dm.emp_no = e.emp_no
    order by	dm.dept_no desc, e.last_name;
    
-- Extract a list containing information about all managers’ employee number, first and last name, department number, and hire date. 
select dm.emp_no, e.first_name, e.last_name, dm.dept_no, e.hire_date
	from	dept_manager dm
    join	employees e	on	dm.emp_no = e.emp_no;
    
-- (If you don’t currently have the ‘departments_dup’ table set up, create it. Let it contain two columns: dept_no and dept_name.
-- Let the data type of dept_no be CHAR of 4, and the data type of dept_name be VARCHAR of 40. Both columns are allowed to have null values.
-- Finally, insert the information contained in ‘departments’ into ‘departments_dup’.) Then, insert a record whose department name is “Public Relations”.
-- Delete the record(s) related to department number two. Insert two new records in the “departments_dup” table. Let their values in the “dept_no” column be “d010” and “d011”.
create table	departments_dup
			(	dept_no		char(4)		null,
                dept_name	varchar(40)	null
			);
insert into	departments_dup(dept_no, dept_name)
	select	dept_no, dept_name
		from	departments;
insert into	departments_dup(dept_name)
	value('Public Relations');
delete from	departments_dup
	where	dept_no = 'd002';
insert into	departments_dup(dept_no)
	values	('d010'),
			('d011');

DROP TABLE IF EXISTS dept_manager_dup;
CREATE TABLE dept_manager_dup (
  emp_no int(11) NOT NULL,
  dept_no char(4) NULL,
  from_date date NOT NULL,
  to_date date NULL
  );
INSERT INTO dept_manager_dup
select * from dept_manager;
INSERT INTO dept_manager_dup (emp_no, from_date)
VALUES                (999904, '2017-01-01'),
                      (999905, '2017-01-01'),
                      (999906, '2017-01-01'),
                      (999907, '2017-01-01');
DELETE FROM dept_manager_dup
WHERE
    dept_no = 'd001';
INSERT INTO departments_dup (dept_name)
VALUES                ('Public Relations');
DELETE FROM departments_dup
WHERE
    dept_no = 'd002'; 
    
select *
	from	departments_dup
	order by	dept_no;
    
-- Select the department number and name from the ‘departments_dup’ table and add a third column where you name the department number (‘dept_no’) as ‘dept_info’.
-- If ‘dept_no’ does not have a value, use ‘dept_name’.
select	dept_no, dept_name, coalesce(dept_no, dept_name) as dept_info	from	departments;

-- Round the average amount of money spent on salaries for all contracts that started after the 1st of January 1997 to a precision of cents.
select	round(avg(salary),2) from salaries
where	from_date > '1997-01-01';

-- What is the average annual salary paid to employees who started after the 1st of January 1997?
select	avg(salary) from salaries
where	from_date > '1997-01-01';

-- 1. Which is the lowest employee number in the database?
select	min(emp_no) from employees;
-- 2. Which is the highest employee number in the database?
select	max(emp_no) from employees;

-- What is the total amount of money spent on salaries for all contracts starting after the 1st of January 1997?
select	sum(salary) from salaries
where	from_date > '1997-01-01';

-- How many departments are there in the “employees” database? Use the ‘dept_emp’ table to answer the question.
select	count(distinct dept_no) from departments;

-- Remove the department number 10 record from the “departments” table.
delete from	departments
where	dept_no = 'd010';

-- Change the “Business Analysis” department name to “Data Analysis”.
update	departments
set	dept_name = 'Data Analysis'
where	dept_name = 'Business Analysis';

-- Create a new department called “Business Analysis”. Register it under number ‘d010’.
insert into	departments
values	(	'd010',
			'Business Analysis'
		);

-- Insert information about the individual with employee number 999903 into the “dept_emp” table. He/She is working for department number 5, and has started work on  October 1st, 1997; her/his contract is for an indefinite period of time.
insert into	dept_emp
values	(	999903,
			'd005',
            '1997-10-01',
            '9999-01-01'
		);
		
-- Select ten records from the “titles” table to get a better idea about its content.
select * from titles
limit	10; 
-- Then, in the same table, insert information about employee number 999903. State that he/she is a “Senior Engineer”, who has started working in this position on October 1st, 1997.
INSERT INTO employees
VALUES
(    999903,
    '1977-09-14',
    'Johnathan',
    'Creek',
    'M',
    '1999-01-01'
);
-- above code is required as employees table is the parent table of titles
insert into 
titles	(
		emp_no,
        title,
        from_date
        )
values	(
		999903,
		'Senior Engineer',
        '1997-10-01'        
        );
-- At the end, sort the records from the “titles” table in descending order to check if you have successfully inserted the new record.
select *from titles
order by	emp_no	desc;

-- Select the first 100 rows from the ‘dept_emp’ table
select * from dept_emp
limit 100;

-- Select the employee numbers of all individuals who have signed more than 1 contract after the 1st of January 2000.
select emp_no, count(emp_no) as no_of_contracts from dept_emp
where		from_date > '2000-01*01'
group by	emp_no
having		count(emp_no) > 1;

Hint: To solve this exercise, use the “dept_emp” table.
-- Select all employees whose average salary is higher than $120,000 per annum.
select emp_no, avg(salary) from salaries
group by emp_no
having	avg(salary) > 120000
order by emp_no;
-- reurns data with individual salary values greater than given limit
SELECT *, AVG(salary) FROM salaries
WHERE		salary > 120000
GROUP BY 	emp_no
ORDER BY 	emp_no;

-- Write a query that obtains two columns. The first column must contain annual salaries higher than 80,000 dollars.
-- The second column, renamed to “emps_with_same_salary”, must show the number of employees contracted to that salary. Lastly, sort the output by the first column.
select salary, count(emp_no) as emps_with_same_salary from salaries
where		salary > 80000
group by	salary
order by	salary desc;

-- Select all data from the “employees” table, ordering it by “hire date” in descending order.
select * from employees
order by	hire_date desc;

-- How many annual contracts with a value higher than or equal to $100,000 have been registered in the salaries table?
select	count(*) from salaries
where salary >= 100000;
-- How many managers do we have in the “employees” database? Use the star symbol (*) in your code to solve this exercise.
select count(*) from dept_manager;

-- Obtain a list with all different “hire dates” from the “employees” table.
select distinct hire_date from employees;

-- Retrieve a list with data about all female employees who were hired in the year 2000 or after.
select * from employees
where	gender = 'F'
		and hire_date >= '2000-01-01';
-- Extract a list with all employees’ salaries higher than $150,000 per annum.
select * from salaries
where	salary > 150000;

-- Select the names of all departments whose department number value is not null.
select dept_name from departments
where	dept_no is not null;

-- Select all the information from the “salaries” table regarding contracts from 66,000 to 70,000 dollars per year.
select * from salaries
where	salary between 66000 and 70000;
-- Retrieve a list with all individuals whose employee number is not between ‘10004’ and ‘10012’.
select * from employees
where	emp_no not between 10004 and 10012;
-- Select the names of all departments with numbers between ‘d003’ and ‘d006’.
select * from departments
where	dept_no between 'd003' and 'd006';

-- Extract all individuals from the ‘employees’ table whose first name contains “Jack”.
select * from employees
where	first_name like ('%Jack%');
-- Once you have done that, extract another list containing the names of employees that do not contain “Jack”.
select * from employees
where	first_name not like ('%Jack%');

-- Select the data about all individuals, whose first name starts with “Mark”; specify that the name can be succeeded by any sequence of characters.
select * from employees
where	first_name like ('Mark%');
-- Retrieve a list with all employees who have been hired in the year 2000.
select * from employees
where	hire_date like ('2000%');
-- Retrieve a list with all employees whose employee number is written with 5 characters, and starts with “1000”. 
select * from employees
where	emp_no like ('1000_');

-- Extract all records from the ‘employees’ table, aside from those with employees named John, Mark, or Jacob.
select * from employees
where	first_name not in ('John', 'Mark', 'Jacob');

-- Use the IN operator to select all individuals from the “employees” table, whose first name is either “Denis”, or “Elvis”.
select * from employees
where	first_name in ('Denis', 'Elvis');

-- Retrieve a list with all female employees whose first name is either Kellie or Aruna
select * from employees
where	gender = 'F'
		and	(first_name = 'Kellie' 
		or	first_name = 'Aruna');
        
select * from employees
where	(first_name = 'Kellie' 
		or	first_name = 'Aruna')
        and	gender = 'F';
-- Retrieve a list with all employees whose first name is either Kellie or Aruna
select * from employees
where	first_name = 'Kellie' or 
		first_name = 'Aruna';

-- Retrieve a list with all female employees whose first name is Kellie
select * from employees
where	gender = 'F'
		and	first_name = 'Kellie';
        
# Select all people from the “employees” table whose first name is “Elvis”. 😊
select * from employees
where first_name = 'Elvis';

-- Select the information from the “dept_no” column of the “departments” table.
select dept_no from departments;

-- Select all data from the “departments” table.
select * from departments;

create schema if not exists sales;
use sales;

CREATE TABLE companies
	(	company_id VARCHAR(255),  
		company_name VARCHAR(255) default("X"),  
		headquarters_phone_number varchar(255) unique default("X")
	);
    
alter table companies
alter column headquarters_phone_number drop default;

alter table companies
alter column company_name set default("X");
    
create table customers
	(	customer_id INT auto_increment,  
		first_name varchar(255),  
		last_name varchar(255),  
		email_address varchar(255),  
		number_of_complaints int,  
		primary key (customer_id)  
	);
    
ALTER TABLE customers
ADD COLUMN gender ENUM('M', 'F') AFTER last_name;

INSERT INTO customers (first_name, last_name, gender, email_address, number_of_complaints)
VALUES ('John', 'Mackinley', 'M', 'john.mckinley@365careers.com', 0)
;

drop table customers;
drop table items;
drop table companies;


create table items
	(	item_code VARCHAR(255),  
		item VARCHAR(255),  
		unit_price NUMERIC(10, 2),  
		company­_id VARCHAR(255)
	);



-- Use the same SELECT statement structure as the one shown in the lecture to select all records from the “sales” table. Do it twice – once specifying the name of the database explicitly in the SELECT statement, and once, without that specification.
select * from sales;