show databases;

use cinema_booking_system;

show tables;
select * from films;

-- show film name and no. of screenings for films > 2 hours long
select f.Name, f.LengthMin, count(s.ID) from films f
join screenings s on s.FilmID = f.ID
group by f.Name
having f.LengthMin > 120;

-- select customer id & count no of reserved seats grouped by customer
select c.ID, count(rs.SeatID) from customers c
join bookings b on c.ID = b.CustomerID
join reserved_seat rs on b.ID = rs.BookingID
group by CustomerID; 

-- no of unique customers who made booking
select count(distinct CustomerID) from bookings;

-- no of screenings for blade runner 2049
select count(*) from screenings s
join films f on s.FilmID = f.ID
where f.name = 'Blade Runner 2049';

-- no. of bookings from customer id 10
select count(*) from bookings
where CustomerID = 10;