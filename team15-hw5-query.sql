--Team 15
-- Names: Sudeep Albal(SWA14)
-- Liu Pan(pal81)
-- Xiaolei Yu(XIY78)


-- Q3 function

CREATE OR REPLACE FUNCTION getCancellationTime(res_number integer)
RETURNS timestamp
AS $$
DECLARE
     cancel_time timestamp;
BEGIN
     SELECT r.flight_date - interval '12 hours' into cancel_time
     FROM reservation_detail r
     WHERE r.reservation_number = res_number and r.leg = 1;

     RETURN cancel_time;
END
$$ LANGUAGE plpgsql;

SELECT getCancellationTime(1);
SELECT getCancellationTime(2);
SELECT getCancellationTime(3);
SELECT getCancellationTime(4);
SELECT getCancellationTime(5);
-- for the reservation number which entry is not there in the reservation_details
SELECT getCancellationTime(12);

--Q4 Function

CREATE OR REPLACE FUNCTION isPlaneFull(flight_no integer)
RETURNS BOOLEAN
AS $$
    DECLARE
        capacity integer;
        seats_booked integer;
        plane_full BOOLEAN := false;
    BEGIN
        SELECT count(r.reservation_number) into seats_booked
        FROM reservation_detail r
        WHERE r.flight_number = flight_no
        GROUP BY r.flight_number;


        SELECT p.plane_capacity into capacity
        FROM plane p,(
            SELECT f.airline_id,f.plane_type
            FROM flight f
            WHERE f.flight_number = flight_no) as t1
        WHERE p.plane_type = t1.plane_type and p.owner_id = t1.airline_id;

        IF capacity = seats_booked THEN
            plane_full = true;
        end if;

        RETURN plane_full;
    end;
    $$LANGUAGE plpgsql;

SELECT isPlaneFull(7);
--8 flight number not full
SELECT isPlaneFull(8);

--Q4 Procedure

CREATE OR REPLACE PROCEDURE makeReservation(reservation_num integer, flight_num integer, departure_date varchar, f_order integer)
LANGUAGE plpgsql AS
$$
DECLARE
        fd timestamp;
        d integer;
        week_schedule varchar;
        dow varchar;
BEGIN
        SELECT EXTRACT(dow from CAST (departure_date AS DATE)) INTO d;

        SELECT weekly_schedule INTO week_schedule
        FROM flight
        WHERE flight_number = flight_num;

        SELECT SUBSTRING(week_schedule from d+1 for 1) INTO dow;

        IF dow = '-'
            THEN RAISE NOTICE 'The flight does not match its desired departure date';
        ELSE
            SELECT CAST(departure_date AS DATE) + CAST(departure_time AS TIME) INTO fd
            FROM reservation NATURAL JOIN flight
            WHERE reservation_number = reservation_num AND flight_number = flight_num;

            INSERT INTO reservation_detail (reservation_number, flight_number, flight_date, leg)
            VALUES(reservation_num,flight_num, fd, f_order)
            ON CONFLICT ON CONSTRAINT RESERVATION_TABLE_PK
            DO
               UPDATE SET flight_date = fd;
        END IF;
END
$$;

/* Valid cases */
call makeReservation(1,1,'20201102',1);
call makeReservation(1,2,'20201104',2);
call makeReservation(1,3,'20201105',3);
call makeReservation(2,4,'20201214',1);
call makeReservation(2,5,'20201215',2);
call makeReservation(3,3,'20201105',1);
call makeReservation(4,5,'20201215',1);
call makeReservation(5,2,'20201104',1);
call makeReservation(5,3,'20201105',2);

/* Invalid cases */
call makeReservation(1,2,'20201101',1);
call makeReservation(1,3,'20201104',2);
call makeReservation(1,4,'20201105',3);
call makeReservation(1,4,'20201106',3);
call makeReservation(1,5,'20201101',3);
call makeReservation(1,5,'20201105',3);
call makeReservation(1,5,'20201106',3);