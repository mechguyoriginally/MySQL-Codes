use cinema_booking_system;
select*from screenings;

-- film name & length of all films whose length > avg length 
select Name, LengthMin from films
where LengthMin >
(select avg(LengthMin) from films);

-- max & min no of screenings of a particular film
select max(id), min(id) from
(select FilmID, count(ID) as id from screenings
group by FilmID) screeningfilm;

-- each film name & no. of screenings for that film
select Name,
(select count(ID) from screenings
where FilmID = f.ID)
from films f;