--Были ли города, в которые можно  добраться бизнес - классом дешевле, чем эконом-классом в рамках перелета?	
-- CTE

select distinct comparison.flight_id, f.departure_airport, f.arrival_airport, comparison.business, comparison.bc_amount, comparison.economy, comparison.yc_amount
from (
	with business as ( --CTE отображающее только билеты бизнес-класса
		select distinct tf.flight_id, tf.fare_conditions, tf.amount from ticket_flights tf
		where tf.fare_conditions = 'Business' --условие для выбора только бизнеса
	)
	select business.flight_id, business.fare_conditions business, business.amount bc_amount, economy.fare_conditions economy, economy.amount yc_amount
	from business 
	join (select * from ticket_flights tf where tf.fare_conditions = 'Economy') as economy on economy.flight_id = business.flight_id --объединяем с таблицей цен эконом-класса
) comparison --представление заканчивается, называем его comparison
join flights f on f.flight_id = comparison.flight_id --присоединяем к представленю таблицу flights
where bc_amount < yc_amount --где цена за бизнес-класс меньше, чем в экономе на том же рейсе 

--ответ: нет