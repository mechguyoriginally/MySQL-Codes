use cinema_booking_system;
select*from rooms;

-- Which films are over 2 hours long? 
select Name from films
where LengthMin > 120;

-- which film had most screenings in Oct 2017?
select f.Name from screenings s
join films f on f.ID = s.FilmID
where month(s.StartTime) = 10 and year(s.StartTime) = 2017
group by FilmID												/* groups result by film id*/
order by count(s.FilmID) desc								/* descending order */
limit 1;													/* most highest value is answer */

-- How many bookings did Jigsaw have in October 2017?
select count(b.ID) from bookings b
join screenings s on b.ScreeningID = s.ID
join films f on s.FilmID = f.ID
where f.Name = 'Jigsaw'
and month(s.StartTime) = 10 and year(s.StartTime) = 2017;

-- Which 5 customers made most bookings in Oct 2017?
select concat(c.FirstName," ",c.LastName), count(b.ID) as no_bookings from customers c		/* presenting full name of the customer */
join bookings b on b.CustomerID = c.ID
group by c.FirstName, c.LastName
order by count(b.ID) desc																	/* descending order */
limit 5; 

-- Which film was shown most often in Chaplin Room in Oct 2017?
select f.Name from films f
join screenings s on s.FilmID = f.ID
join rooms r on s.RoomID = r.ID
where r.Name = 'Chaplin'
group by f.Name
order by count(s.ID) desc
limit 1;

-- How many customers made a booking in Oct 2017?
select count(distinct CustomerID) as no_customers from bookings;