--Find % ratio of flights on aircraft type from total number of flights.

select *, round(flight_qty::numeric / (sum(flight_qty) over ())::numeric * 100, 2) as "% from_ttl" --приводим типы данных к numeric чтобы считать не целые числа -->
from ( --делим количество рейсов по каждому типу ВС на общее количество рейсов (сумму по этому столбцу) 
	select distinct --подзапрос для подсчёта количества рейсов
		a.aircraft_code,
		count(f.flight_id) over (partition by a.aircraft_code) as flight_qty --оконная функция для подсчёта количества рейсов (flight_id), группируемого по типу ВС 
	from aircrafts a
	join flights f on f.aircraft_code = a.aircraft_code 
	order by flight_qty desc
	) as qty --называем таблицу из подзапроса qty 

