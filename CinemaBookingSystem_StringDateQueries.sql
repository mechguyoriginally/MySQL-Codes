use cinema_booking_system;
select*from screenings;

-- concatenate film name & length 
select concat(Name, ": ", LengthMin) as film_name_with_duration from films;

-- customer's email from 5th character onwards
select substring(Email, 5) from customers;

-- customer first name in smalls & last name in capitals for last name as Smith
select lower(FirstName) as first_name, upper(LastName) as last_name from customers
where LastName = 'Smith';

-- last 3 letters of each film
select substring(Name, -3) as short_name from films;

-- combine first 3 letters of first & last name of each customer
select concat(short_firstname, " ", short_lastname) as short_name from
(select substring(FirstName,1,3) as short_firstname, substring(LastName, 1, 3) as short_lastname from customers) x;

select concat(substring(FirstName,1,3), " ", substring(LastName, 1, 3)) as short_name from customers;	-- Method 2

-- show film id & start time for 20 Oct 2017
select ID, StartTime from screenings
where date(StartTime) = '2017-10-20';

-- screening data between 6th & 13th Oct 2017
select * from screenings
where date(StartTime) between '2017-10-06' and '2017-10-13';

-- screening data for Oct 2017
select * from screenings
where month(StartTime) = 10 and year(StartTime) = 2017;