--Team 15
-- Names: Sudeep Albal(SWA14)
-- Liu Pan(pal81)
-- Xiaolei Yu(XIY78)

-- Q5 Trigger

-- Allows insertion of tuple into reservation_detail until plane can be
--switched to new type.Gives exception if biggest plane is also full.
CREATE OR REPLACE FUNCTION getNewPlaneType()
RETURNS TRIGGER
AS $$
DECLARE
    new_type char(4);
    current_type char(4);
    current_capacity integer;
    airline_number integer;

BEGIN
    IF isplanefull(new.flight_number) = true THEN

        SELECT f.airline_id into airline_number
        FROM flight f
        WHERE f.flight_number = new.flight_number;

        SELECT f.plane_type into current_type
        FROM flight f
        WHERE f.flight_number = new.flight_number;

        SELECT p.plane_capacity into current_capacity
        FROM plane p
        WHERE p.plane_type = current_type and p.owner_id = airline_number;

        SELECT t1.plane_type into new_type
        FROM
             (SELECT p.plane_type,p.plane_capacity
              FROM plane p
              WHERE p.owner_id = airline_number and p.plane_capacity > current_capacity
              ORDER BY p.plane_capacity
              LIMIT 1) as t1;


        IF new_type is NOT NULL THEN
            UPDATE flight SET plane_type = new_type
            WHERE flight_number = new.flight_number;
        ELSE
            RAISE EXCEPTION 'Ticket Cannot be booked as flight is booked';
        END IF;

    end if;
    RETURN new;
END
$$ LANGUAGE plpgsql;

drop trigger if exists planeUpgrade on flight;
create trigger planeUpgrade
before insert on reservation_detail
for each row
execute procedure getNewPlaneType();


-- Capcaity of P100 was 3 after below 2 inserts plane type will change to p200
-- After that third INSERT will result in exception
INSERT INTO RESERVATION_DETAIL VALUES (10,7,to_timestamp('10022020','MMDDYYYY'),2);
INSERT INTO RESERVATION_DETAIL VALUES (11,7,to_timestamp('10022020','MMDDYYYY'),2);
INSERT INTO RESERVATION_DETAIL VALUES (12,7,to_timestamp('10022020','MMDDYYYY'),1);

--Q6 Trigger

/*
 question6
 */

create or replace procedure myP2_sub (p__flight_number 		Flight.flight_number%type) as
$$
declare
p__now_amt 				plane.plane_capacity%type;
p__new_plane_type		plane.plane_type%type;
p__new_owner_id			plane.owner_id%type;
p__new_plane_capacity 	plane.plane_capacity%type;
begin
    select count(*)
    into p__now_amt
    from Reservation_Detail
    where flight_number = p__flight_number;
        select plane_type, owner_id, plane_capacity into p__new_plane_type, p__new_owner_id, p__new_plane_capacity
        from plane
        where plane_capacity > p__now_amt
        order by plane_capacity asc;

        RAISE NOTICE 'XXXXXXXXXXXXXXXXXXXXXXX  called by  p__flight_number			: (%) ', p__flight_number;

        update 	Flight
        set 	plane_type = p__new_plane_type, airline_id = p__new_owner_id
        where 	flight_number = p__flight_number;
    end;
$$ language plpgsql;

create or replace function myP_Q6() RETURNS TRIGGER as
$$
declare
curr_time 			timestamp;
the_now             char(99);
cancellTime			timestamp;
the_cancellTime		char(99);
flight_number		Reservation_Detail.flight_number%type;
hours               integer;
cur 				CURSOR FOR SELECT Reservation_Detail.* FROM Reservation natural join Reservation_Detail  where ticketed = false;
begin

    SELECT new.c_timestamp into curr_time
    FROM ourtimestamp;

    FOR one IN cur LOOP
        RAISE NOTICE 'loop in cur -----------------------';
        RAISE NOTICE 'cur --  reservation_number 	: (%) ', one.reservation_number;
        RAISE NOTICE 'cur --  leg 		 	: (%) ', one.leg;
        RAISE NOTICE 'cur --  flight_number 	 	: (%) ', one.flight_number;


        flight_number 	:= one.flight_number;
        --the_now 		:= to_char(curr_time, 'yyyy-MM-dd hh24:MI:SS');
        cancellTime 	:= getCancellationTime(flight_number);
        --the_cancellTime	:= to_char(cancellTime, 'yyyy-MM-dd hh24:MI:SS');

        RAISE NOTICE 'current_time : (%) ', curr_time;
        RAISE NOTICE 'the_cancellTime : (%) ', cancellTime;



        if curr_time = cancellTime
        then
            RAISE NOTICE 'condition satisfied';
            delete from Reservation_Detail where reservation_number = one.reservation_number;
            call myP2_sub(flight_number);
        end if;

    END LOOP;
return NEW;
end;
$$ language plpgsql;

DROP TRIGGER IF EXISTS cancelReservation ON ourtimestamp;

CREATE TRIGGER cancelReservation
AFTER UPDATE ON ourtimestamp
FOR EACH ROW EXECUTE PROCEDURE myP_Q6();


UPDATE ourtimestamp
set c_timestamp = to_timestamp('12012020 18:30:00','MMDDYYYY HH24:MI:SS')
WHERE c_timestamp = to_timestamp('11/05/2020 02:15','MM/DD/YYYY HH24:MI');
