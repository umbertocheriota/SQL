/*
Найдите свободные места для каждого рейса, их % отношение к общему количеству мест в самолете.
Добавьте столбец с накопительным итогом - суммарное количество вывезенных пассажиров из аэропорта за день. 
Т.е. в этом столбце должна отражаться сумма - сколько человек уже вылетело из данного аэропорта на этом или более ранних рейсах за сегодняшний день	
- Оконная функция
- Подзапрос
*/

--5.1 Найдите свободные места для каждого рейса
with vacant_seats as ( --создаём CTE "свободные кресла"
	select f.flight_id, s.seat_no as vacant_seat --отображаем все кресла на каждом flight_id
	from flights f
	join aircrafts a on a.aircraft_code = f.aircraft_code 
	join seats s on s.aircraft_code = a.aircraft_code 
		except --убираем из вывода те кресла, на которые были выданы посадочные талоны (т.е. пассажир пришёл на рейс и занял это место)
	select bp.flight_id, bp.seat_no
	from boarding_passes bp 
	order by flight_id 
)
select f.flight_no, vacant_seats.flight_id, vacant_seats.vacant_seat
from vacant_seats 
join flights f on f.flight_id = vacant_seats.flight_id


--5.2 их % отношение к общему количеству мест в самолете.
select 
	f.flight_no,
	occupied_seats.flight_id, 
	count(occupied_seats.flight_id) as occupied_seat, --отображаем количество занятых кресел
	f.aircraft_code,
	seat_capacity.ac_seat_capacity, --отображаем общее количество мест на борту
	round((count(occupied_seats.flight_id::numeric) / seat_capacity.ac_seat_capacity::numeric) * 100, 1) as "load_factor, %" --показатель load factor. % загрузки борта
from (select bp.flight_id, bp.seat_no from boarding_passes bp order by flight_id) as occupied_seats --подзапрос для выборки занятых кресел (пришедших на рейс пассажиров)
join flights f on f.flight_id = occupied_seats.flight_id
join (select aircraft_code, count(row_number) as ac_seat_capacity --подзапрос для расчёта общего количества мест на каждом типе ВС
	from (select s.aircraft_code, s.seat_no, row_number() over (partition by s.aircraft_code) --подзапрос с оконной функцикй для нумерации всех кресел на борту
		from seats s) as seat_capacity
	group by aircraft_code) as seat_capacity on seat_capacity.aircraft_code = f.aircraft_code --соединяем подзапрос по типу ВС
group by occupied_seats.flight_id, f.aircraft_code, seat_capacity.ac_seat_capacity, f.flight_no 


--5.3 Добавьте столбец с накопительным итогом - суммарное количество вывезенных пассажиров из аэропорта за день. 
with ttl as ( --создаём CTE, чтобы из него получить сумму занятых кресел, т.к. нельзя использовать оконную функцию в другой оконной функции 
select 
	f.flight_no,
	occupied_seats.flight_id, 
	f.departure_airport,
	count(occupied_seats.flight_id) as pax, --отображаем количество занятых кресел
	f.aircraft_code,
	seat_capacity.seat_capacity, --отображаем общее количество мест на борту
	round((count(occupied_seats.flight_id::numeric) / seat_capacity.seat_capacity::numeric) * 100, 1) as "load_factor, %", --показатель load factor. % загрузки борта -->
	f.actual_departure --приводим тип данных к numeric, чтобы получить не целые числа, используем round для округления и оставляем 1 знак после запятой
from (select bp.flight_id, bp.seat_no from boarding_passes bp order by flight_id) as occupied_seats --подзапрос для выборки занятых кресел (пришедших на рейс пассажиров)
join flights f on f.flight_id = occupied_seats.flight_id 
join (select aircraft_code, count(row_number) as seat_capacity --подзапрос для расчёта общего количества мест на каждом типе ВС
	from (select s.aircraft_code,	s.seat_no,	row_number() over (partition by s.aircraft_code) --подзапрос с оконной функцикй для нумерации всех кресел на борту
		from seats s) as seat_capacity
	group by aircraft_code) as seat_capacity on seat_capacity.aircraft_code = f.aircraft_code --соединяем подзапрос по типу ВС
where f.actual_departure is not null --отфильтровываем NULL значения actual_departure, т.е. те рейсы, которые ещё не вылетали
group by occupied_seats.flight_id, f.aircraft_code, seat_capacity.seat_capacity, f.flight_no, f.departure_airport, f.actual_departure
)
select *, sum(ttl.pax) over (partition by ttl.actual_departure::date, ttl.departure_airport order by ttl.actual_departure, ttl.departure_airport) as pax_per_day
from ttl --выделяем все те же столбцы + сумму по столбцу pax, т.е. сумму пассажиров, "группируемую" оконной функцией по дате отправления и аэропорту вылета -->
--дату отправления приводим к типу данных date, т.к. по умолчанию она timestamp и каждое новое время будет считаться как новый объект для "группировки"
