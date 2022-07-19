create database test;
use test;
create table Addresses(
			ID int,
            House_No int,
            city varchar(20),
            postcode varchar(7)
            );

create table People(
			ID int,
            First_Name varchar(20),
            Last_Name varchar(20),
            Address_ID int
            );

create table Pets(
			ID int,
            Name varchar(20),
			Species varchar(20),
            Owner_ID int
            );

show tables;

describe Addresses;
describe Pets;

alter table Addresses
add primary key (ID);

alter table People
drop primary key;

alter table People
add primary key (ID);

alter table People
add constraint foreign_people_address
foreign key (Address_ID) references Addresses(ID);

alter table People
drop foreign key foreign_people_address;

select*from Pets;
alter table Pets
add constraint u_species unique (Species);

alter table Pets
drop index u_species;

select*from Pets;
alter table Pets 
change `Animal Type` `Species` varchar(20);

describe Addresses;
alter table Addresses
modify city varchar(30);

describe People;


alter table People
add primary key (ID);

alter table Pets
add primary key (ID);

alter table	Pets
add constraint foreign_pets_people
foreign key (Owner_ID) references People (ID);

alter table People
add column Email varchar(30);

alter table People
add constraint unique_email unique (Email);

alter table Pets
change `Name` `First Name` varchar(20);

describe Pets;
describe Addresses;

alter table Addresses
modify postcode char(7);