/*
Спроектируйте базу данных для следующих сущностей:
-язык (в смысле английский, французский и тп)
-народность (в смысле славяне, англосаксы и тп)
-страны (в смысле Россия, Германия и тп)

Правила следующие:
-на одном языке может говорить несколько народностей
-одна народность может входить в несколько стран
-каждая страна может состоять из нескольких народностей

Дополнительная часть:
-показать, как назначать внешние ключи краткой записью при создании таблицы и как можно присвоить внешние ключи для столбцов существующей таблицы
-масштабировать получившуюся базу данных используя следующие типы данных: timestamp, boolean и text[]

в таблицах со связями должны быть составные первичные ключи, так как связи по двум столбцам, то и ограничение должно быть по двум столбцам
дополните работу запросами на внесение данных в таблицы со связями, машина не знает какие фактические связи могут существовать и поэтому данные вносятся руками
*/

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
	nation_id int, --not null и unique не нужно, т.к. указывается далее первичным ключом
	country_id int,
	primary key (nation_id, country_id), --составной первичный ключ
	foreign key (country_id) references country (country_id),
	foreign key (nation_id) references nationality (nation_id)
	);
	
create table nationality_language(
	nation_id int, --not null и unique не нужно, т.к. указывается далее первичным ключом
	language_id int,
	primary key (nation_id, language_id) --составной первичный ключ
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




