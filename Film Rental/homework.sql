
-------------------------1-------------------------
select
	distinct 
	c.first_name || ' ' || c.last_name as name, 
	count(i.inventory_id) over (partition by c.customer_id)
from rental r
join inventory i on i.inventory_id = r.inventory_id 
join film f on f.film_id = i.film_id 
join customer c on c.customer_id = r.customer_id 
where 'Behind the Scenes' = any (special_features)
group by name, i.inventory_id, c.customer_id 
order by count desc

-------------------------2-------------------------
create materialized view special_rent as
with qty as (
	select
		c.customer_id,
		c.first_name || ' ' || c.last_name as name, 
		r.rental_id, 
		r.rental_date,
		row_number() over (partition by r.customer_id order by r.rental_date),
		f.special_features 
	from rental r
	join inventory i on i.inventory_id = r.inventory_id 
	join film f on f.film_id = i.film_id 
	join customer c on c.customer_id = r.customer_id 
	where 'Behind the Scenes' = any (special_features)
)
select name, count(row_number)
from qty 
group by name 
order by count desc;

refresh materialized view special_rent;

select * from special_rent sr 

--drop materialized view special_rent


-------------------------3-------------------------
with qty as (
	select
		c.customer_id,
		c.first_name || ' ' || c.last_name as name, 
		r.rental_id, 
		r.rental_date,
		row_number() over (partition by r.customer_id order by r.rental_date),
		f.special_features,
		unnest(f.special_features) as unnested_array
	from rental r
	join inventory i on i.inventory_id = r.inventory_id 
	join film f on f.film_id = i.film_id 
	join customer c on c.customer_id = r.customer_id 
)
select name, count(row_number)
from qty 
where unnested_array ilike '%behind the scenes%'
--where unnested_array = 'Behind the Scenes' -- доп вариант
group by name 
order by count desc







