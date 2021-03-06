--Find % ratio of occupied seats to the total number of seats in the aircraft (load factor)
--Add a column with a cumulative total quantity of passengers departed from the airport during the day.

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
