
--Задание 1. 
--Напишите функцию, которая принимает на вход название должности (например, стажер), а также даты периода поиска, 
--и возвращает количество вакансий, опубликованных по этой должности в заданный период.

CREATE OR REPLACE FUNCTION hr.vac_foo(
	vac_title_new text, 
	start_date date, 
	end_date date, 
	OUT vac_qty integer
) AS $$
	BEGIN
		IF start_date IS NULL AND end_date IS NOT NULL 
			THEN start_date = (SELECT min(payment_date::date) FROM payment);
		ELSEIF start_date IS NOT NULL AND end_date IS NULL 
			THEN end_date = current_date;
		ELSEIF start_date > end_date
			THEN RAISE EXCEPTION 'Start date cannot be later than end date. Please edit the start date.';
		END IF;
		SELECT 
			COUNT(vac_id)
		FROM vacancy
		WHERE vacancy.vac_title = vac_title_new
			AND create_date BETWEEN start_date AND end_date
		INTO vac_qty;
	END;
$$ LANGUAGE plpgsql

SELECT hr.vac_foo('ñòàæåð', '2020-01-01', '2021-01-01')


--Задание 2. 
--Напишите триггер, срабатывающий тогда, когда в таблицу position добавляется значение grade, которого нет в таблице-справочнике grade_salary. 
--Триггер должен возвращать предупреждение пользователю о несуществующем значении grade.

CREATE TRIGGER grade_tr 
BEFORE INSERT OR UPDATE ON "position" 
FOR EACH ROW EXECUTE PROCEDURE grade_check_foo();

CREATE OR REPLACE FUNCTION grade_check_foo() RETURNS trigger AS $$
BEGIN
	IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') AND NEW.grade NOT IN (SELECT DISTINCT grade FROM GRADE_SALARY)
		THEN RAISE EXCEPTION 'Grade is not appeared in the grade_salary';
	ELSE RETURN NEW;
	END IF; 
END;
$$ LANGUAGE plpgsql;

--testing with grade 20
INSERT INTO "position"(pos_id, pos_title, pos_category, unit_id, grade, address_id, manager_pos_id)
VALUES (4592, 'BI Engineer', 'Ïðîèçâîäñòâåííûé', 100, 20, 5, 1)

DELETE FROM "position" WHERE pos_id >= 4592



--Задание 3. Создайте таблицу employee_salary_history с полями:

--emp_id - id сотрудника
--salary_old - последнее значение salary (если не найдено, то 0)
--salary_new - новое значение salary
--difference - разница между новым и старым значением salary
--last_update - текущая дата и время

--Напишите триггерную функцию, которая срабатывает при добавлении новой записи о сотруднике 
--или при обновлении значения salary в таблице employee_salary, и заполняет таблицу employee_salary_history данными.

DROP TABLE employee_salary_history

CREATE TABLE employee_salary_history (
	emp_id int,
	salary_old int,
	salary_new int,
	difference int, --GENERATED ALWAYS AS (salary_new - salary_old) STORED, 
	last_update timestamp
);

CREATE OR REPLACE TRIGGER emp_sal_tg
AFTER INSERT OR UPDATE OR DELETE ON employee_salary 
FOR EACH ROW EXECUTE FUNCTION emp_sal_tg_foo()

CREATE OR REPLACE FUNCTION emp_sal_tg_foo() RETURNS TRIGGER AS $$
BEGIN
	IF tg_op = 'DELETE'
		THEN INSERT INTO employee_salary_history SELECT OLD.emp_id, OLD.salary, 0, -OLD.salary, NOW();
		RETURN OLD;
	ELSEIF tg_op = 'INSERT'
		THEN INSERT INTO employee_salary_history SELECT NEW.emp_id, 0, NEW.salary, NEW.salary, NOW();
		RETURN NEW;
	ELSEIF (tg_op = 'UPDATE' AND OLD.salary != NEW.salary)
		THEN INSERT INTO employee_salary_history SELECT NEW.emp_id, OLD.salary, NEW.salary, NEW.salary-OLD.salary, NOW();
		RETURN NEW;
	END IF;
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

--test for inserting new data
INSERT INTO employee_salary (order_id, emp_id, salary, effective_from) 
VALUES (29969, 2, 300000, '2021-01-01')

--test for updating salary column
UPDATE employee_salary 
SET salary = 100000
WHERE emp_id = 2735

--test if other column update doesn't run the trigger
UPDATE employee_salary 
SET effective_from = '2021-01-01'
WHERE emp_id = 2735


DELETE FROM employee_salary WHERE order_id >= 29967

DELETE FROM employee_salary_history WHERE emp_id >= 1 OR emp_id IS NULL  


SELECT * FROM employee_salary ORDER BY 1 DESC

SELECT * FROM employee_salary_history 




--Задание 4. 
--Напишите процедуру, которая содержит в себе транзакцию на вставку данных в таблицу employee_salary. 
--Входными параметрами являются поля таблицы employee_salary.

CREATE OR REPLACE PROCEDURE emp_salary_p(
	_order_id int,
	_emp_id int,
	_salary int,
	_effective_from date
) AS $$
BEGIN
	INSERT INTO employee_salary (order_id, emp_id, salary, effective_from) 
	VALUES (_order_id, _emp_id, _salary, _effective_from);
END;
$$ LANGUAGE plpgsql;

CALL emp_salary_p(29968, 2, 250000, '2021-01-01')


--test
SELECT * FROM employee_salary WHERE order_id >= 29967

--DELETE FROM employee_salary WHERE order_id >= 29967
