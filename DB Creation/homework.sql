--create schema homework

--set search_path to homework

drop table nationality, country, languages, country_nationality, nationality_language;

create table nationality(
	nation_id serial primary key,
	nation_name varchar(30) unique not null
	);

create table languages(
	language_id serial primary key,
	language_name varchar(30) unique not null
	);
	
create table country(
	country_id serial primary key,
	country_name varchar(30) unique not null
	);

create table country_nationality(
	nation_id int,
	country_id int,
	primary key (nation_id, country_id),
	foreign key (country_id) references country (country_id),
	foreign key (nation_id) references nationality (nation_id)
	);
	
create table nationality_language(
	nation_id int,
	language_id int,
	primary key (nation_id, language_id)
	);
	
alter table nationality_language 
add constraint language2language foreign key (language_id) references languages(language_id),
add constraint nation2nation foreign key (nation_id) references nationality(nation_id);

insert into country (country_name)
values ('Russia'), ('Canada'), ('Germany'), ('China'), ('Turkey');

insert into languages (language_name)
values ('russian'), ('tatar'), ('german'), ('turkish'), ('chinese');

insert into nationality (nation_name)
values ('russian'), ('tatar'), ('german'), ('turkish'), ('chinese');

insert into country_nationality
values 
	(1, 1), (1, 2), (1, 3), (1, 4),
	(2, 1), (2, 2), (2, 5),
	(3, 1), (3, 3),
	(4, 1), (4, 2), (4, 3), (4, 5),
	(5, 1), (5, 2), (5, 3), (5, 4), (5, 5);

insert into nationality_language
values (1, 1), (2, 1), (3, 3), (4, 1), (5, 5);

alter table country
add last_update timestamp not null default now();

alter table languages 
add last_update timestamp not null default now();

alter table nationality 
add last_update timestamp not null default now();




