-- CS1555 Final Project
-- Team 15
-- Pan Liu
-- Sudeep Albal
-- Xiaolei Yu

------------------------------------Create Tables------------------------------------

DROP TABLE IF EXISTS AIRLINE CASCADE;
DROP TABLE IF EXISTS FLIGHT CASCADE;
DROP TABLE IF EXISTS PLANE CASCADE;
DROP TABLE IF EXISTS PRICE CASCADE;
DROP TABLE IF EXISTS CUSTOMER CASCADE;
DROP TABLE IF EXISTS RESERVATION CASCADE;
DROP TABLE IF EXISTS RESERVATION_DETAIL CASCADE;
DROP TABLE IF EXISTS OURTIMESTAMP CASCADE;
DROP DOMAIN IF EXISTS EMAIL_DOMAIN CASCADE;

--Note: This is a simplified email domain and is not intended to exhaustively check for all requirements of an email
CREATE DOMAIN EMAIL_DOMAIN AS varchar(30)
    CHECK ( value ~ '^[a-zA-Z0-9.!#$%&''*+\/=?^_`{|}~\-]+@(?:[a-zA-Z0-9\-]+\.)+[a-zA-Z0-9\-]+$' );

CREATE TABLE AIRLINE (
  airline_id            integer,
  airline_name          varchar(50)     NOT NULL,
  airline_abbreviation  varchar(10)     NOT NULL,
  year_founded          integer         NOT NULL,
  CONSTRAINT AIRLINE_PK PRIMARY KEY (airline_id),
  CONSTRAINT AIRLINE_UQ1 UNIQUE (airline_name),
  CONSTRAINT AIRLINE_UQ2 UNIQUE (airline_abbreviation)
);

CREATE TABLE PLANE (
    plane_type      char(4),
    manufacturer    varchar(10)     NOT NULL,
    plane_capacity  integer         NOT NULL,
    last_service    date            NOT NULL,
    year            integer         NOT NULL,
    owner_id        integer         NOT NULL,
    CONSTRAINT PLANE_PK PRIMARY KEY (plane_type,owner_id),
    CONSTRAINT PLANE_FK FOREIGN KEY (owner_id) REFERENCES AIRLINE(airline_id)
);

CREATE TABLE FLIGHT (
    flight_number   integer,
    airline_id      integer     NOT NULL,
    plane_type      char(4)     NOT NULL,
    departure_city  char(3)     NOT NULL,
    arrival_city    char(3)     NOT NULL,
    departure_time  varchar(4)  NOT NULL,
    arrival_time    varchar(4)  NOT NULL,
    weekly_schedule varchar(7)  NOT NULL,
    CONSTRAINT FLIGHT_PK PRIMARY KEY (flight_number),
    CONSTRAINT FLIGHT_FK1 FOREIGN KEY (plane_type,airline_id) REFERENCES PLANE(plane_type,owner_id),
    CONSTRAINT FLIGHT_FK2 FOREIGN KEY (airline_id) REFERENCES AIRLINE(airline_id),
    CONSTRAINT FLIGHT_UQ UNIQUE (departure_city, arrival_city)
);

CREATE TABLE PRICE (
    departure_city  char(3),
    arrival_city    char(3),
    airline_id      integer,
    high_price      integer     NOT NULL,
    low_price       integer     NOT NULL,
    CONSTRAINT PRICE_PK PRIMARY KEY (departure_city, arrival_city),
    CONSTRAINT PRICE_FK FOREIGN KEY (airline_id) REFERENCES AIRLINE(airline_id),
    CONSTRAINT PRICE_CHECK_HIGH CHECK (high_price >= 0),
    CONSTRAINT PRICE_CHECK_LOW CHECK (low_price >= 0)
);

--Assuming salutation can be NULL as many people don't use salutations on online forms
--Assuming last_name can be NULL as not everyone has a last name, like Cher
--Assuming phone is optional (can be NULL) but email is required
--Assuming that duplicate first_name and last_name pairs are possible since cid will be unique
--Assuming that email addresses should be unique in the table since multiple customers shouldn't sign up with
---the same email
CREATE TABLE CUSTOMER (
    cid                 integer,
    salutation          varchar(3),
    first_name          varchar(30)     NOT NULL,
    last_name           varchar(30),
    credit_card_num     varchar(16)     NOT NULL,
    credit_card_expire  date            NOT NULL,
    street              varchar(30)     NOT NULL,
    city                varchar(30)     NOT NULL,
    state               varchar(2)      NOT NULL,
    phone               varchar(10),
    email               EMAIL_DOMAIN    NOT NULL,
    frequent_miles      varchar(10),
    CONSTRAINT CUSTOMER_PK PRIMARY KEY (cid),
    CONSTRAINT CUSTOMER_FK FOREIGN KEY (frequent_miles) REFERENCES AIRLINE(airline_abbreviation),
    CONSTRAINT CUSTOMER_CCN CHECK (credit_card_num ~ '\d{16}'),
    CONSTRAINT CUSTOMER_UQ1 UNIQUE (credit_card_num),
    CONSTRAINT CUSTOMER_UQ2 UNIQUE (email)
);

--Assuming that a customer can make multiple reservations, i.e., cid and credit_card_num are not unique here
---since multiple reservations will have unique reservation_numbers
CREATE TABLE RESERVATION (
  reservation_number    integer,
  cid                   integer     NOT NULL,
  cost                  decimal     NOT NULL,
  credit_card_num       varchar(16) NOT NULL,
  reservation_date      timestamp   NOT NULL,
  ticketed              boolean     NOT NULL    DEFAULT FALSE,
  CONSTRAINT RESERVATION_PK PRIMARY KEY (reservation_number),
  CONSTRAINT RESERVATION_FK1 FOREIGN KEY (cid) REFERENCES CUSTOMER(cid),
  CONSTRAINT RESERVATION_FK2 FOREIGN KEY (credit_card_num) REFERENCES CUSTOMER(credit_card_num),
  CONSTRAINT RESERVATION_COST CHECK (cost >= 0)
);

CREATE TABLE RESERVATION_DETAIL (
  reservation_number    integer,
  flight_number         integer     NOT NULL,
  flight_date           timestamp   NOT NULL,
  leg                   integer,
  CONSTRAINT RESERVATION_DETAIL_PK PRIMARY KEY (reservation_number, leg),
  CONSTRAINT RESERVATION_DETAIL_FK1 FOREIGN KEY (reservation_number) REFERENCES RESERVATION(reservation_number) ON DELETE CASCADE,
  CONSTRAINT RESERVATION_DETAIL_FK2 FOREIGN KEY (flight_number) REFERENCES FLIGHT(flight_number),
  CONSTRAINT RESERVATION_DETAIL_CHECK_LEG CHECK (leg > 0)
);

-- The c_timestamp is initialized once using INSERT and updated subsequently
CREATE TABLE OURTIMESTAMP (
    c_timestamp     timestamp,
    CONSTRAINT OURTIMESTAMP_PK PRIMARY KEY (c_timestamp)
);




------------------------------------Admin Tasks------------------------------------

--Task #1 Erase the database
DROP FUNCTION IF EXISTS clear_database;
CREATE OR REPLACE FUNCTION clear_database()
RETURNS BOOLEAN
AS $$
    DECLARE
        res BOOLEAN;
    BEGIN
         TRUNCATE OURTIMESTAMP,RESERVATION_DETAIL,RESERVATION,CUSTOMER,PRICE,FLIGHT,PLANE,AIRLINE;
         RETURN res;
    END;
    $$ LANGUAGE plpgsql;

SELECT clear_database();


--Task #2 Load airline information
DROP FUNCTION IF EXISTS load_airline_info;
CREATE OR REPLACE FUNCTION load_airline_info(id integer, name varchar(50), abbreviation varchar(10), year integer)
RETURNS BOOLEAN
AS $$
    DECLARE
        res BOOLEAN;
    BEGIN
         INSERT INTO AIRLINE (airline_id, airline_name, airline_abbreviation, year_founded)
         VALUES (id, name, abbreviation, year);
         RETURN res;
    END;
    $$ LANGUAGE plpgsql;



--Task #3 Load schedule information
DROP FUNCTION IF EXISTS load_schedule_info;
CREATE OR REPLACE FUNCTION load_schedule_info(f_number integer,
                                              a_id integer,
                                              p_type char(4),
                                              d_city char(3),
                                              a_city char(3),
                                              d_time varchar(4),
                                              a_time varchar(4),
                                              w_schedule varchar(7))
RETURNS BOOLEAN
AS $$
    DECLARE
        res BOOLEAN;
    BEGIN
         INSERT INTO FLIGHT (flight_number, airline_id, plane_type, departure_city,
                             arrival_city, departure_time, arrival_time,weekly_schedule)
         VALUES (f_number, a_id, p_type, d_city, a_city, d_time, a_time, w_schedule);
         RETURN res;
    END;
    $$ LANGUAGE plpgsql;



--Task #4  Load pricing information
DROP FUNCTION IF EXISTS load_pricing_info;
CREATE OR REPLACE FUNCTION load_pricing_info(d_city char(3),
                                             a_city char(3),
                                             id integer,
                                             h_price integer,
                                             l_price integer)
RETURNS BOOLEAN
AS $$
    DECLARE
        res BOOLEAN;
    BEGIN
        INSERT INTO PRICE (departure_city, arrival_city, airline_id, high_price, low_price)
        VALUES (d_city, a_city, id, h_price, l_price);
         RETURN res;
    END;
    $$ LANGUAGE plpgsql;




--Task #5 Load plane information
DROP FUNCTION IF EXISTS load_plane_info;
CREATE OR REPLACE FUNCTION load_plane_info(p_type char(4),
                                           manuf varchar(10),
                                           p_capacity integer,
                                           l_service varchar(10),
                                           y integer,
                                           id integer)
RETURNS BOOLEAN
AS $$
    DECLARE
        res BOOLEAN;
    BEGIN
         INSERT INTO PLANE (plane_type, manufacturer, plane_capacity, last_service, year, owner_id)
         VALUES (p_type, manuf, p_capacity, TO_DATE(l_service, 'MM-DD-YYYY'), y, id);
         RETURN res;
    END;
    $$ LANGUAGE plpgsql;




--Task #6: Generate passenger manifest for specific flight on given day
DROP FUNCTION IF EXISTS list_passenger;
DROP TYPE IF EXISTS customer_name;
CREATE TYPE customer_name AS (sal varchar(3), first varchar(30), last varchar(30));

CREATE OR REPLACE FUNCTION list_passenger(f_number integer, date varchar(10))
RETURNS setof customer_name
AS $$
        SELECT salutation, first_name, last_name
        FROM customer
        NATURAL JOIN reservation
        NATURAL JOIN reservation_detail
        WHERE flight_date::date = TO_TIMESTAMP(date, 'MM-DD-YYYY HH24:MI')
              AND flight_number = f_number
              AND ticketed = true;
$$ LANGUAGE sql;

SELECT list_passenger(5, '12/15/2020');




--Task #7 Update the current timestamp
DROP FUNCTION IF EXISTS update_time;
CREATE OR REPLACE FUNCTION update_time(t varchar(20))
RETURNS BOOLEAN
AS $$
    DECLARE
         res BOOLEAN;
    BEGIN
         TRUNCATE OURTIMESTAMP;
         INSERT INTO OURTIMESTAMP (c_timestamp)
         VALUES (TO_TIMESTAMP(t, 'MM-DD-YYYY HH24:MI'));
         RETURN res;
    END;
    $$ LANGUAGE plpgsql;



------------------------------------Customer Tasks------------------------------------

-- Function for task 1
DROP FUNCTION IF EXISTS add_customer CASCADE;
CREATE OR REPLACE FUNCTION add_customer(cid integer,
                            sal varchar(3),
                            f_name varchar(30),
                            l_name  varchar(30),
                            c_num varchar(16),
                            c_expire varchar(10),
                            st varchar(30),
                            c varchar(30),
                            sta varchar(2),
                            ph varchar(10),
                            em EMAIL_DOMAIN,
                            f_m varchar(10))
RETURNS BOOLEAN
AS $$
    DECLARE
         res BOOLEAN;
    BEGIN
        INSERT INTO CUSTOMER (cid, salutation, first_name, last_name, credit_card_num, credit_card_expire, street,
                              city, state,phone, email, frequent_miles)
        VALUES (cid, sal, f_name, l_name, c_num, TO_DATE(c_expire, 'MM-DD-YYYY'), st, c, sta, ph, em, f_m);
         RETURN res;
    END;
    $$ LANGUAGE plpgsql;



-- Function for task 2

DROP FUNCTION IF EXISTS get_customer CASCADE;
DROP TYPE IF EXISTS customer_type CASCADE;
CREATE TYPE customer_type AS (r1 integer,r2 varchar(3),r3 varchar(30),r4 varchar(30),
                              r5 varchar(16),r6 date,r7 varchar(30),r8 varchar(30),
                              r9 varchar(2),r10 varchar(10),r11 email_domain,
                              r12 varchar(10));

CREATE  OR REPLACE FUNCTION get_customer(fname varchar(30),lname varchar(30))
RETURNS customer_type
AS $$
    DECLARE record customer_type;
BEGIN
        SELECT cid,salutation,first_name,last_name,credit_card_num,
               credit_card_expire,street,city,state,phone,email,
               frequent_miles
        INTO record.r1,record.r2,record.r3,record.r4,record.r5,record.r6,
             record.r7,record.r8,record.r9,record.r10,record.r11,record.r12
        FROM customer
        WHERE first_name = fname and last_name = lname;

        IF record IS NULL THEN RAISE EXCEPTION 'Customer not found in database';
        END IF;

        RETURN record;
END;
$$ language plpgsql;



-- Task 4
-- 1st function for direct routes between required cities
DROP FUNCTION IF EXISTS direct_routes CASCADE;
DROP TYPE IF EXISTS flight_type CASCADE;


CREATE TYPE flight_type AS (f1 integer, f2 char(3), f3 varchar(4), f4 char(3), f5 varchar(4));

CREATE OR REPLACE FUNCTION direct_routes( depart char(3), arrival char(3))
RETURNS setof flight_type
AS $$
    DECLARE
        flights flight_type;
    BEGIN
        for flights IN (SELECT f.flight_number,f.departure_city,f.departure_time,f.arrival_city,f.arrival_time
                        FROM flight f
                        WHERE f.departure_city = depart and f.arrival_city = arrival) loop
                    return next flights;
            end loop;
    END;
$$ LANGUAGE plpgsql;

SELECT direct_routes('LAX','SEA');



-- functions to make sure 2 flights are connected
-- helper function 1
DROP FUNCTION IF EXISTS check_connected_flight_time CASCADE;
CREATE OR REPLACE FUNCTION check_connected_flight_time(time1 varchar(4),time2 varchar(4))
RETURNS BOOLEAN
AS $$
    DECLARE
        res boolean;
        hr integer;
    BEGIN

        SELECT extract (hours from(cast(time2 AS time) - cast(time1 AS time))) INTO hr;

        IF hr >= 1 THEN res = true;
        ELSE res = false;
        END IF;

        return res;
    end;
$$ LANGUAGE plpgsql;

-- helper function 2
DROP FUNCTION IF EXISTS check_same_day_flight CASCADE;
CREATE OR REPLACE FUNCTION check_same_day_flight(sch1 varchar(7),sch2 varchar(7))
RETURNS BOOLEAN
AS $$

    DECLARE
        res boolean;
        i integer;
        ch1 char;
        ch2 char;
    BEGIN
        res = false;
        FOR i in 1..7 loop
            SELECT substring(sch1,i,1) INTO ch1;
            SELECT substring(sch2,i,1) INTO ch2;

            IF ch1 = ch2 and ch1 != '-' THEN res = true;
            END IF;
            end loop;
        return res;
    end;
    $$LANGUAGE plpgsql;

--function to find indirect routes
DROP FUNCTION IF EXISTS indirect_routes CASCADE;
DROP TYPE IF EXISTS routes CASCADE;
CREATE TYPE routes AS (r1 integer, r2 varchar(3), r3 varchar(3), r4 varchar(4), r5 varchar(4),
                       r6 integer, r7 varchar(3), r8 varchar(3), r9 varchar(4), r10 varchar(4));

CREATE OR REPLACE FUNCTION indirect_routes(departure_c varchar(3), arrival_c varchar(3))
RETURNS SETOF routes
AS $$
    DECLARE
       record routes;
    BEGIN
        DROP VIEW IF EXISTS connected_flights;
        CREATE OR REPLACE VIEW connected_flights
        AS
        SELECT f1.flight_number as f1_number,f1.departure_city as start_city,f1.arrival_city as middle_city,
               f1.departure_time as d_time, f1.arrival_time as first_time,f1.weekly_schedule as f1_sch,
               f2.flight_number as f2_number,f2.departure_city as d2_city,f2.arrival_city as dest_city,
               f2.departure_time as second_time,f2.arrival_time as a_time,f2.weekly_schedule as f2_sch
        FROM flight f1,flight f2
        WHERE f2.departure_city = f1.arrival_city;

        -- Iterate over matching rows from view and check if both functions satisfied or not
        FOR record IN (SELECT c.f1_number,c.start_city,c.middle_city,c.d_time, c.first_time,
                              c.f2_number,c.middle_city,c.dest_city, c.second_time, c.a_time
                       FROM connected_flights c
                       WHERE c.start_city = departure_c and c.dest_city = arrival_c and
                             check_same_day_flight(c.f1_sch,c.f2_sch) = true and
                             check_connected_flight_time(c.first_time,c.second_time) = true
                       ) LOOP
                       RETURN NEXT record;
        END LOOP;
    END;
$$ LANGUAGE plpgsql;



--Task 5

DROP TYPE IF EXISTS direct_type CASCADE ;
DROP TYPE IF EXISTS indirect_type CASCADE ;
DROP FUNCTION IF EXISTS airline_direct_routes CASCADE;
DROP FUNCTION IF EXISTS check_connected_flight_time CASCADE;
DROP FUNCTION IF EXISTS check_same_day_flight CASCADE;
DROP FUNCTION IF EXISTS airline_indirect_routes CASCADE;

CREATE TYPE direct_type AS(a1 integer,a2 char(3),a3 char(3),a4 varchar(4),a5 varchar(4));
CREATE TYPE indirect_type AS(a1 integer,a2 char(3),a3 varchar(4),a4 char(3), a5 varchar(4),
                             a6 integer, a7 char(3), a8 varchar(4));

--Direct Routes
CREATE OR REPLACE FUNCTION airline_direct_routes(airline_num integer,d_city char(3),a_city char(3))
RETURNS setof direct_type
AS $$
    DECLARE
        r direct_type;
        f integer;
    BEGIN
        SELECT f.flight_number into f
        FROM flight f
        WHERE f.departure_city = d_city and f.arrival_city = a_city
        LIMIT 1;

        IF f is NULL THEN
            RAISE NOTICE 'Direct flights between given routes do not exist';
        ELSE
            for r IN (SELECT f.flight_number,f.departure_city,f.arrival_city,f.departure_time,f.arrival_time
                  FROM flight f
                  WHERE f.airline_id = airline_num and f.departure_city = d_city and f.arrival_city = a_city)loop
                return next r;
            end loop;
        end if;
    end;
    $$ LANGUAGE plpgsql;


--Indirect Routes
DROP FUNCTION IF EXISTS check_connected_flight_time CASCADE;
CREATE OR REPLACE FUNCTION check_connected_flight_time(time1 varchar(4),time2 varchar(4))
RETURNS BOOLEAN
AS $$
    DECLARE
        res boolean;
        hr integer;
    BEGIN
        SELECT extract (hours from(cast(time2 AS time) - cast(time1 AS time))) INTO hr;

        IF hr >= 1 THEN res = true;
        ELSE res = false;
        END IF;

        return res;
    end;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS check_same_day_flight CASCADE;
CREATE OR REPLACE FUNCTION check_same_day_flight(sch1 varchar(7),sch2 varchar(7))
RETURNS BOOLEAN
AS $$
    DECLARE
        res boolean;
        i integer;
        ch1 char;
        ch2 char;
    BEGIN
        res = false;
        FOR i in 1..7 loop
            SELECT substring(sch1,i,1) INTO ch1;
            SELECT substring(sch2,i,1) INTO ch2;

            IF ch1 = ch2 and ch1 != '-' THEN res = true;
            END IF;
            end loop;
        return res;
    end;
    $$LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS airline_indirect_routes CASCADE;
CREATE OR REPLACE FUNCTION airline_indirect_routes(airline_num integer,d_city char(3),a_city char(3))
RETURNS setof indirect_type
AS $$
    DECLARE
        f integer;
        r indirect_type;
    BEGIN
        CREATE OR REPLACE VIEW indirect_flights AS
            SELECT f1.airline_id,f1.flight_number as first_flight,f1.departure_city as start_city,
                   f1.departure_time as first_departure_time,f1.arrival_city as middle_city,
                   f1.arrival_time as arrival_time,f2.flight_number as connecting_flight,
                   f2.arrival_city as destination,f2.departure_time as second_departure_time,
                   f1.weekly_schedule as first_schedule, f2.weekly_schedule as second_schedule
            FROM flight f1,flight f2
            WHERE f1.arrival_city = f2.departure_city and f1.airline_id = f2.airline_id;

        SELECT if.first_flight INTO f
        FROM indirect_flights if
        WHERE if.airline_id = airline_num
        LIMIT 1;

        IF f IS NULL THEN
            RAISE NOTICE 'Indirect routes between % to % does not exist',d_city,a_city;
        ELSE
            RAISE NOTICE 'Indirect routes between % to % are as following',d_city,a_city;
            FOR r IN (SELECT if.first_flight,if.start_city,if.first_departure_time,if.middle_city,
                             if.arrival_time,if.connecting_flight,if.destination,if.second_departure_time
                      FROM indirect_flights if
                      WHERE if.airline_id = airline_num and if.start_city = d_city and
                            if.destination = a_city and
                            check_connected_flight_time(if.arrival_time,if.second_departure_time) and
                            check_same_day_flight(if.first_schedule,if.second_schedule))loop
                return next r;
            end loop;
        end if;
    end;
    $$LANGUAGE plpgsql;



--Task 6

DROP FUNCTION IF EXISTS direct_routes_available_seats CASCADE;
DROP FUNCTION IF EXISTS indirect_routes_available_seats CASCADE;
DROP TYPE IF EXISTS f_type CASCADE;
DROP TYPE IF EXISTS f_indirect_type CASCADE;

CREATE TYPE f_type AS (a1 integer,a2 char(3),a3 char(3),a4 varchar(4),a5 varchar(4));

CREATE OR REPLACE FUNCTION direct_routes_available_seats(d_city char(3),a_city char(3),depart_date date)
RETURNS setof f_type
AS $$
    DECLARE
        r f_type;
    BEGIN
        FOR r IN(SELECT f.flight_number,f.departure_city as start_city,f.arrival_city as dest_city,
                        f.departure_time as start_time,f.arrival_time as reach_time
                 FROM flight f
                 WHERE f.departure_city = d_city and f.arrival_city = a_city and
                        flight_seat_day_check(f.flight_number,depart_date)= true)loop
            return next r;
        end loop;
    end;
    $$LANGUAGE plpgsql;

--SELECT direct_routes_available_seats('PIT','NYC',to_date('05-22-2020','MM-DD-YYYY'))

CREATE TYPE f_indirect_type AS(a1 integer,a2 char(3),a3 varchar(4),a4 char(3), a5 varchar(4),
                             a6 integer, a7 char(3), a8 varchar(4));

CREATE OR REPLACE FUNCTION indirect_routes_available_seats(d_city char(3),a_city char(3),depart_date date)
RETURNS setof f_indirect_type
AS $$
    DECLARE
        r f_indirect_type;
    BEGIN
        CREATE OR REPLACE VIEW one_connection_flights AS
            SELECT f1.airline_id,f1.flight_number as first_flight,f1.departure_city as start_city,
                   f1.departure_time as first_departure_time,f1.arrival_city as middle_city,
                   f1.arrival_time as arrival_time,f2.flight_number as connecting_flight,
                   f2.arrival_city as destination,f2.departure_time as second_departure_time,
                   f1.weekly_schedule as first_schedule, f2.weekly_schedule as second_schedule
            FROM flight f1,flight f2
            WHERE f1.arrival_city = f2.departure_city;

        for r IN (SELECT o.first_flight,o.start_city,o.first_departure_time,o.middle_city,
                         o.arrival_time,o.connecting_flight,o.destination,o.second_departure_time
                  FROM one_connection_flights o
                  WHERE o.start_city = d_city and o.destination = a_city and
                        check_connected_flight_time(o.arrival_time,o.second_departure_time) and
                        check_same_day_flight(o.first_schedule,o.second_schedule) and
                        flight_seat_day_check(o.first_flight,depart_date) and
                        flight_seat_day_check(o.connecting_flight,depart_date))loop
            return next r;
        end loop;
    end;
    $$LANGUAGE plpgsql;


--Task 7

--returns true if switch to bigger plane possible else returns false
DROP FUNCTION IF EXISTS check_plane_upgrade CASCADE;
CREATE OR REPLACE FUNCTION check_plane_upgrade(flight integer)
RETURNS BOOLEAN
AS
$$
    DECLARE
        current_capacity integer;
        new_type char(4);
        current_type char(4);
        airline_number integer;
    BEGIN
        SELECT f.airline_id into airline_number
        FROM flight f
        WHERE f.flight_number = flight;

        SELECT f.plane_type into current_type
        FROM flight f
        WHERE f.flight_number = flight;

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
            RETURN true;
        ELSE
            RETURN false;
        END IF;

    end;
    $$LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS seat_available CASCADE;
CREATE OR REPLACE FUNCTION seat_available(flight_num integer,departure_date date)
RETURNS boolean
AS
$$
    DECLARE
        plane_full boolean;
        upgrade boolean;
        flight_d timestamp;
    BEGIN
        flight_d = getCalculatedDepartureDate(flight_num,departure_date);
        plane_full = isPlaneFull(flight_num,departure_date);
        RAISE NOTICE 'plane full function returned %',plane_full;
        upgrade = check_plane_upgrade(flight_num);

        IF plane_full = false THEN return true;
        ELSE
            IF upgrade = true THEN return true;
            ELSE return false;
            END IF;
        END IF;
    end;
    $$LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS getDayLetterFromSchedule CASCADE;
CREATE OR REPLACE FUNCTION getDayLetterFromSchedule(flight_num integer,departure_date date)
    RETURNS VARCHAR AS
$$
DECLARE
    day_of_week integer;
    weekly      varchar(7);
    day         varchar(1);
BEGIN
    SELECT EXTRACT(dow FROM departure_date) INTO day_of_week;

    SELECT weekly_schedule
    INTO weekly
    FROM FLIGHT AS F
    WHERE F.flight_number = flight_num;

    --CAUTION: substring function is one-index based and not zero
    SELECT substring(weekly from (day_of_week + 1) for 1) INTO day;

    RETURN day;
END;
$$ language plpgsql;


DROP FUNCTION IF EXISTS flight_seat_day_check CASCADE;
CREATE OR REPLACE FUNCTION flight_seat_day_check(flight_num integer,departure_date date)
RETURNS boolean AS
$$
    DECLARE
        seat_check boolean;
        d date;
        day varchar(1);
        flight_d timestamp;
    BEGIN
        flight_d = getCalculatedDepartureDate(flight_num,departure_date);
        select flight_d::timestamp::date into d;
        seat_check = seat_available(flight_num,departure_date);
        day = getDayLetterFromSchedule(flight_num,d);

        IF seat_check = true and day <> '-' THEN return true;
        ELSE return false;
        END IF;
    END;
    $$LANGUAGE plpgsql;


-------------------------------------IF above functions return true then update reservation and reservation_detail
DROP PROCEDURE IF EXISTS update_reservation_table CASCADE;
CREATE OR REPLACE PROCEDURE update_reservation_table(cust_id integer,curr_date timestamp)
AS
$$
    DECLARE
        curr_max_res integer;
        res_no integer;
        c_card varchar(16);
    BEGIN
        SELECT r.reservation_number INTO curr_max_res
        FROM reservation r
        ORDER BY r.reservation_number DESC
        LIMIT 1;

        IF curr_max_res is NULL THEN res_no = 1;
        ELSE res_no = curr_max_res + 1;
        END IF;

        SELECT c.credit_card_num INTO c_card
        FROM customer c
        WHERE c.cid = cust_id;

        INSERT INTO reservation(reservation_number, cid, cost, credit_card_num, reservation_date,ticketed)
        VALUES (res_no,cust_id,0,c_card,curr_date,false);
    end;
$$LANGUAGE plpgsql;


DROP PROCEDURE IF EXISTS update_reservation_detailt CASCADE;
CREATE OR REPLACE PROCEDURE update_reservation_detail(flight_num integer,departure_date date,legno integer)
AS
$$
    DECLARE
        res_no integer;
        f_date timestamp;
    BEGIN
        SELECT r.reservation_number INTO res_no
        FROM reservation r
        ORDER BY r.reservation_number DESC
        LIMIT 1;

        f_date = getCalculatedDepartureDate(flight_num,departure_date);

        INSERT INTO reservation_detail(reservation_number, flight_number, flight_date, leg)
        VALUES (res_no,flight_num,f_date,legno);
    end;
    $$LANGUAGE plpgsql;

DROP PROCEDURE IF EXISTS update_price_reservation CASCADE;
CREATE OR REPLACE PROCEDURE update_price_reservation()
AS
$$
    DECLARE
        total_price integer;
        price integer;
        same_day_travel boolean;
        flight integer;
        curr_airline integer;
        res_no integer;
        records record;
        curr_customer integer;
        curr_customer_freq_airline integer;
        depart_city char(3);
        arrive_city char(3);
    BEGIN
        SELECT r.reservation_number INTO res_no
        FROM reservation r
        ORDER BY r.reservation_number DESC
        LIMIT 1;

        RAISE NOTICE 'reservation updated is %',res_no;

        for records IN (SELECT * FROM reservation_detail r WHERE r.reservation_number = res_no)loop

            SELECT r.cid INTO curr_customer
            FROM reservation r
            WHERE r.reservation_number = records.reservation_number;

            RAISE NOTICE 'customer is %',curr_customer;

            SELECT a.airline_id INTO curr_customer_freq_airline
            FROM customer c,airline a
            WHERE lower(split_part(a.airline_name,' ',1)) = lower(c.frequent_miles) and c.cid = curr_customer;

            RAISE NOTICE 'customer freq airline is %',curr_customer_freq_airline;

            SELECT f.airline_id INTO curr_airline
            FROM flight f
            WHERE f.flight_number = records.flight_number;

            RAISE NOTICE 'current airline is %',curr_airline;

            SELECT f.departure_city INTO depart_city
            FROM flight f
            WHERE f.airline_id = curr_airline and f.flight_number = records.flight_number;

            SELECT f.arrival_city INTO arrive_city
            FROM flight f
            WHERE f.airline_id = curr_airline and f.flight_number = records.flight_number;

            RAISE NOTICE 'travel from % to %',depart_city,arrive_city;
            same_day_travel = check_reservation_same_day(records.reservation_number);

            IF same_day_travel = true THEN
                RAISE NOTICE 'same day travel';
                SELECT p.high_price INTO price
                FROM price p
                WHERE p.departure_city = depart_city and p.arrival_city = arrive_city;
            ELSE
                RAISE NOTICE 'not same day travel';
                SELECT p.low_price INTO price
                FROM price p
                WHERE p.departure_city = depart_city and p.arrival_city = arrive_city;
            end if;

            IF curr_airline = curr_customer_freq_airline THEN
                price = price - (10 * price/100);
            end if;
            RAISE NOTICE 'price is %',price;

            UPDATE reservation
            SET cost = cost + price
            WHERE reservation_number = res_no;
        end loop;
            RAISE NOTICE 'total Price updated is %',price;
    end;
    $$LANGUAGE plpgsql;



--Task 8
DROP FUNCTION IF EXISTS delete_reservation CASCADE;
CREATE OR REPLACE FUNCTION delete_reservation(res_number integer)
RETURNS BOOLEAN
AS $$
    DECLARE
        res BOOLEAN;
        reservation_info integer;
    BEGIN
        SELECT r.reservation_number INTO reservation_info
        FROM reservation r
        WHERE r.reservation_number = res_number;

        IF reservation_info IS NULL THEN
            RAISE EXCEPTION 'Reservation does not Exists';
            res = false;
        ELSE
            DELETE FROM reservation_detail
            WHERE reservation_detail.reservation_number = res_number;

            DELETE FROM reservation
            WHERE reservation.reservation_number = res_number;
            res = true;
        END IF;

        RETURN res;
    END;
    $$ LANGUAGE plpgsql;




--Task 9

DROP FUNCTION IF EXISTS display_ticket_info CASCADE;
DROP TYPE IF EXISTS ticket_type CASCADE;
CREATE TYPE ticket_type AS (i1 integer, i2 integer, i3 timestamp, i4 integer);
CREATE OR REPLACE FUNCTION display_ticket_info(res_number integer)
RETURNS setof ticket_type
AS $$
    DECLARE exists integer;
            records ticket_type;
    BEGIN
        SELECT re.reservation_number INTO exists
        FROM reservation re
        WHERE re.reservation_number = res_number;

        IF exists IS NULL THEN
            RAISE EXCEPTION 'reservation number does not exist.';
        ELSE
            for records IN (SELECT r.reservation_number,r.flight_number,r.flight_date,r.leg
                            FROM reservation_detail r
                            WHERE r.reservation_number = res_number) loop
               return next records;
                end loop;
        end if;
    end;

    $$LANGUAGE plpgsql;



--Task 10

DROP PROCEDURE IF EXISTS buy_ticket CASCADE;
CREATE  OR REPLACE PROCEDURE buy_ticket(res_nummber integer)
AS $$
    DECLARE
        req_reservation_number integer;
        already_ticket boolean;
    BEGIN
        SELECT r.reservation_number INTO req_reservation_number
        FROM reservation r
        WHERE r.reservation_number = res_nummber;

        SELECT r.ticketed INTO already_ticket
        FROM reservation r
        WHERE r.reservation_number = res_nummber;

        IF req_reservation_number IS NULL THEN
            RAISE EXCEPTION 'Invalid reservation number';
        ELSE
            IF already_ticket IS TRUE THEN
                RAISE EXCEPTION 'Ticket already purchased';
            ELSE
                UPDATE reservation
                SET ticketed = true
                WHERE reservation_number = req_reservation_number;

                RAISE NOTICE 'Reservation updated';
            end if;
        end if;
    end;
    $$ LANGUAGE plpgsql;


-- Task 11

DROP VIEW IF EXISTS price_view CASCADE;
DROP FUNCTION IF EXISTS check_reservation_same_day CASCADE;
DROP FUNCTION IF EXISTS customer_all_legs_price_with_airline CASCADE;
DROP FUNCTION IF EXISTS airlines_top_customer_price CASCADE;
DROP TYPE IF EXISTS  price_type CASCADE;
DROP VIEW IF EXISTS leg_cost CASCADE;
DROP VIEW IF EXISTS customer_frequent_airline_id CASCADE;

CREATE TYPE price_type AS (a1 varchar(50) , a2 varchar(30), a3 varchar(30));
-- Function for leg costs

-- Check if reservation legs are on same day or not
-- returns false if travel spans over multiple days
-- returns true if single day travel for all legs
DROP FUNCTION IF EXISTS check_reservation_same_day CASCADE;
CREATE OR REPLACE FUNCTION check_reservation_same_day(res_number integer)
RETURNS BOOLEAN
AS $$
    DECLARE
        r record;
        res boolean;
        first_leg_time timestamp;
        date_difference integer;
    BEGIN
        SELECT re.flight_date INTO first_leg_time
        FROM reservation_detail re
        WHERE re.reservation_number = res_number and re.leg = 1;

        res = true;

        for r in (SELECT * FROM reservation_detail re WHERE re.reservation_number = res_number and leg <> 1) loop
            date_difference = extract(days from (age(r.flight_date,first_leg_time)));
            RAISE NOTICE 'first leg date is %',first_leg_time;
            RAISE NOTICE 'current leg date is %',r.flight_date;
            RAISE NOTICE 'difference is %',date_difference;
            IF date_difference >= 1 THEN
                res = false;
            END IF;
        end loop;

        RETURN res;
    end;
    $$LANGUAGE plpgsql;

-- Write a function which takes customer id and airline id and returns price paid by customer to airline over all legs
DROP FUNCTION IF EXISTS customer_all_legs_price_with_airline CASCADE;
CREATE OR REPLACE FUNCTION customer_all_legs_price_with_airline(airline integer,c integer)
RETURNS integer
AS $$
    DECLARE
        price int;
        r record;
        same_day boolean;
        total_price integer;
    BEGIN
        total_price = 0;
        for r IN (SELECT * FROM leg_cost l WHERE l.airline_id = airline and l.cid = c)loop
            RAISE NOTICE 'reservation number is %',r.reservation_number;
            RAISE NOTICE 'customer id is %',r.cid;
            RAISE NOTICE 'leg is %',r.leg;
            same_day = check_reservation_same_day(r.reservation_number);

            IF same_day = true THEN price  = r.high_price;
            RAISE NOTICE 'Same day travel';
            RAISE NOTICE 'High Price Selected is %',price;
            ELSE price = r.low_price;
            RAISE NOTICE 'Not a same day travel';
            RAISE NOTICE 'Low Price Selected is %',price;
            END IF;

            IF r.airline_id = r.freq_airline THEN
                RAISE NOTICE 'Airline ID % matches with freq airline %',r.airline_id,r.freq_airline;
                RAISE NOTICE 'Price before discount is %',price;
                price = price - (10 * price)/100;
                RAISE NOTICE 'Price after discount is %',price;
            END IF;

            total_price = total_price + price;

        end loop;

        RETURN total_price;
    end;
    $$LANGUAGE plpgsql;

--Final function
DROP FUNCTION IF EXISTS airlines_top_customer_price CASCADE;
CREATE OR REPLACE FUNCTION airlines_top_customer_price(airline integer,k integer)
RETURNS setof price_type
AS $$
    DECLARE
        records price_type;
    BEGIN
    -- View for maintaing customer id and airline for frequent miles program
        CREATE OR REPLACE VIEW customer_frequent_airline_id AS
        SELECT c.cid,a.airline_id,a.airline_name,c.frequent_miles
        FROM customer c,airline a
        WHERE lower(split_part(a.airline_name,' ',1)) = lower(c.frequent_miles);

        CREATE OR REPLACE VIEW leg_cost AS
        SELECT r.reservation_number,c.cid,re.flight_number,p.airline_id,p.high_price,p.low_price,
               freq.airline_id as freq_airline, re.leg
        FROM reservation_detail re,reservation r,customer c,price p,flight f,customer_frequent_airline_id freq
        WHERE re.reservation_number = r.reservation_number and
              r.cid = c.cid and
              re.flight_number = f.flight_number and
              f.airline_id = p.airline_id and f.departure_city = p.departure_city and f.arrival_city = p.arrival_city and
              r.cid = freq.cid and
              r.ticketed = true;

        CREATE OR REPLACE VIEW price_view AS
        SELECT t1.airline_id,t1.cid,sum(t1.leg_price) as total_price
        FROM (SELECT l.airline_id,l.cid,customer_all_legs_price_with_airline(l.airline_id,l.cid) as leg_price
        FROM leg_cost l) as t1
        GROUP BY t1.airline_id, t1.cid;

        for records IN
        (SELECT a.airline_name,c.first_name,c.last_name
        FROM customer c,airline a,(SELECT t1.airline_id,t1.cid
                         FROM (SELECT p.airline_id,p.cid,p.total_price,rank() over(ORDER BY total_price DESC) as price_rank
                               FROM price_view p
                               WHERE p.airline_id = airline) as t1
                         WHERE t1.price_rank <= k) as t2
        WHERE t2.airline_id = a.airline_id and t2.cid = c.cid)loop
            return next records;
            end loop;
    end;
    $$LANGUAGE plpgsql;




-- Task 12

DROP FUNCTION IF EXISTS airline_customers_leg CASCADE;
--Define function which takes airline id and k
DROP TYPE IF EXISTS leg_type CASCADE;
CREATE TYPE leg_type AS (a1 varchar(50) , a2 varchar(30), a3 varchar(30));

CREATE OR REPLACE FUNCTION airline_customers_leg(airline integer,k integer)
RETURNS setof leg_type
AS $$
    DECLARE
        record leg_type;
    BEGIN
        --Define function which takes airline id and k
        DROP VIEW IF EXISTS airlines_legs;
        CREATE OR REPLACE VIEW airlines_legs AS
            SELECT t4.airline_id,a.airline_name,t4.cid,t4.first_name,t4.last_name,t4.leg_count
            FROM airline a,(SELECT t3.airline_id,t3.cid,c.first_name,c.last_name,t3.leg_count
                            FROM customer c,(SELECT t2.airline_id,t2.cid,count(t2.leg) as leg_count
                                             FROM (SELECT f.airline_id,f.flight_number,t1.reservation_number,t1.cid,t1.leg
                                                   FROM flight f,(SELECT r.reservation_number,re.flight_number,r.cid,re.leg
                                                                  FROM reservation_detail re,reservation r
                                                                  WHERE re.reservation_number = r.reservation_number and r.ticketed = true) as t1
                                                   WHERE f.flight_number = t1.flight_number) as t2
                                             GROUP BY t2.airline_id, t2.cid) as t3
                            WHERE c.cid = t3.cid) as t4
            WHERE t4.airline_id = a.airline_id;

        FOR record IN (SELECT t2.airline_name,t2.first_name,t2.last_name
                       FROM (SELECT t1.airline_name , t1.first_name,t1.last_name,
                             rank() OVER (ORDER BY t1.leg_count DESC) AS ranking
                             FROM(SELECT al.airline_name , al.first_name , al.last_name,al.leg_count
                                  FROM airlines_legs al
                                  WHERE al.airline_id = airline) as t1)as t2
                       WHERE t2.ranking <= k
                       ) loop
            return next record;
            end loop;
    end;
$$ LANGUAGE plpgsql;




-- Task 13
DROP FUNCTION IF EXISTS airline_rank CASCADE;
DROP TYPE IF EXISTS airline_k CASCADE;
CREATE TYPE airline_k AS (airline_n varchar(20), rank bigint);
CREATE OR REPLACE FUNCTION airline_rank()
RETURNS setof airline_k
AS $$
        SELECT t2.airline_name,rank() over(ORDER BY t2.count_customers DESC) as ranking
        FROM (SELECT a.airline_name , t1.count_customers
              FROM airline a,(SELECT f.airline_id,count(re.reservation_number) as count_customers
                              FROM reservation_detail re,flight f,reservation r
                              WHERE re.flight_number = f.flight_number and r.reservation_number = re.reservation_number
                                    and r.ticketed = true
                              GROUP BY f.airline_id) as t1
              WHERE a.airline_id = t1.airline_id) as t2;
$$ LANGUAGE sql;


------------------------------------Triggers------------------------------------

----------------------Start of the trigger UpgradePlaneType----------------------------------

CREATE OR REPLACE FUNCTION getCalculatedDepartureDate(flight_num integer,departure_date date)
    RETURNS timestamp AS
$$
DECLARE
    flight_time varchar(5);
BEGIN
    SELECT (substring(DEPT_TABLE.departure_time from 1 for 2) || ':' ||
            substring(DEPT_TABLE.departure_time from 3 for 2))
    INTO flight_time
    FROM (SELECT departure_time
          FROM FLIGHT AS F
          WHERE F.flight_number = flight_num) AS DEPT_TABLE;
    RAISE NOTICE 'flight time is %',flight_time;
    RETURN to_timestamp(departure_date || ' ' || flight_time, 'YYYY-MM-DD HH24:MI');
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION getNumberOfSeats(flight_num integer, departure_date date)
    RETURNS INTEGER AS
$$
DECLARE
    result integer;
    flight_time timestamp;
BEGIN
    flight_time = getCalculatedDepartureDate(flight_num,departure_date);
    SELECT COUNT(reservation_number)
    INTO result
    FROM reservation_detail
    WHERE flight_number = flight_num
      AND flight_date = flight_time
    GROUP BY flight_number, flight_date;


    RETURN result;

END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION isPlaneFull(flight_num integer, departure_date date)
    RETURNS BOOLEAN AS
$$
DECLARE
    max_capacity     integer;
    current_capacity integer;
    result           BOOLEAN := TRUE;
BEGIN
    --Get appropriate plane's capacity
    SELECT plane_capacity
    INTO max_capacity
    FROM PLANE AS P
             NATURAL JOIN (SELECT plane_type
                           FROM FLIGHT
                           WHERE FLIGHT.flight_number = flight_num) AS F;

    --Get number of seats filled on flight
    RAISE NOTICE 'flight no is % and timestamp is %',flight_num,departure_date;
    current_capacity = getNumberOfSeats(flight_num, departure_date);

    IF current_capacity IS NULL THEN
        current_capacity = 0;
    END IF;

    IF current_capacity < max_capacity THEN
        result := FALSE;
    END IF;

    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- SELECT isPlaneFull(2,to_date('2020-11-04','YYYY-MM-DD'));

CREATE OR REPLACE FUNCTION getNewPlaneType()
RETURNS TRIGGER
AS $$
DECLARE
    new_type char(4);
    current_type char(4);
    current_capacity integer;
    airline_number integer;
    d date;
BEGIN
    SELECT new.flight_date::timestamp::date INTO d;

    IF isplanefull(new.flight_number,d) = true THEN

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


-------------------------------------------End of the trigger Upgrade Plane------------------------------------



-- Trigger 2 (adjustTicket)

CREATE OR REPLACE PROCEDURE adjustTicketHelper(depart_city char(3),arrive_city char(3),old_h_price integer,
                                               old_l_price integer,h_price integer,l_price integer)
AS $$
    DECLARE
        flight integer;
        records record;
        ticket_confirmed boolean;
        airline integer;
        old_res_cost integer;
        new_res_cost integer;
        freq_airline boolean;
        same_day_travel boolean;
        curr_customer integer;
        curr_customer_freq_airline integer;
        price_diff integer;
    BEGIN
        SELECT f.flight_number INTO flight
        FROM flight f,price p
        WHERE f.airline_id = p.airline_id and p.departure_city = depart_city and p.arrival_city = arrive_city;

        SELECT f.airline_id INTO airline
        FROM flight f,price p
        WHERE f.airline_id = p.airline_id and p.departure_city = depart_city and p.arrival_city = arrive_city;

        RAISE NOTICE 'Flight updated is % and it belongs to airline %',flight,airline;

        FOR records IN (SELECT * FROM reservation_detail re WHERE re.flight_number = flight)loop
            SELECT r.ticketed INTO ticket_confirmed
            FROM reservation r
            WHERE r.reservation_number = records.reservation_number;

            RAISE NOTICE 'reservation status is %',ticket_confirmed;

            SELECT r.cid INTO curr_customer
            FROM reservation r
            WHERE r.reservation_number = records.reservation_number;

            RAISE NOTICE 'Current customer is %',curr_customer;

            SELECT a.airline_id INTO curr_customer_freq_airline
            FROM customer c,airline a
            WHERE lower(split_part(a.airline_name,' ',1)) = lower(c.frequent_miles) and c.cid = curr_customer;

            RAISE NOTICE 'Current customers frequent airline is % and airline for leg is %',curr_customer_freq_airline,airline;

            IF ticket_confirmed = false THEN
                same_day_travel = check_reservation_same_day(records.reservation_number);

                IF same_day_travel = true THEN
                    old_res_cost = old_h_price;
                ELSE
                    old_res_cost = old_l_price;
                end if;

                IF curr_customer_freq_airline = airline THEN
                    old_res_cost = old_res_cost - ((10 * old_res_cost)/100);
                end if;

                RAISE NOTICE 'old cost of leg is %',old_res_cost;

                IF same_day_travel = true THEN
                    new_res_cost = h_price;
                ELSE
                    new_res_cost = l_price;
                end if;

                IF curr_customer_freq_airline = airline THEN
                    new_res_cost = new_res_cost - ((10 * new_res_cost)/100);
                end if;

                RAISE NOTICE 'new cost of leg is %',new_res_cost;


                price_diff = new_res_cost - old_res_cost;

                RAISE NOTICE 'cost different of leg due to update is %',price_diff;

                UPDATE reservation SET cost = cost + price_diff
                WHERE reservation.reservation_number = records.reservation_number;
            ELSE
                continue;
            end if;
        end loop;
    end;
    $$LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_flight_price()
RETURNS TRIGGER AS
$$
    BEGIN
        RAISE NOTICE 'Old prices for flight between % to % is % and %.',old.departure_city,old.arrival_city,old.high_price,old.low_price;
        RAISE NOTICE 'New prices for flight between % to % is % and %.',new.departure_city,new.arrival_city,new.high_price,new.low_price;

        CALL adjustTicketHelper(new.departure_city,new.arrival_city,old.high_price,old.low_price,new.high_price,new.low_price);
        RETURN NEW;
    end;
$$LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS adjustTicket ON price;
CREATE TRIGGER adjustTicket
    BEFORE UPDATE
    ON price
    FOR EACH ROW
EXECUTE PROCEDURE update_flight_price();

------------------------------------------------------------------------Cancel reservation Trigger-------------------------------------------
DROP PROCEDURE IF EXISTS downgradePlaneHelper CASCADE;
CREATE OR REPLACE PROCEDURE downgradePlaneHelper(flight_num integer, flight_time timestamp)
AS
$$
DECLARE
    numberOfSeats    integer;
    currentPlaneType varchar(4);
    airplane_row     RECORD;
    airlinePlanes CURSOR FOR
        SELECT p.plane_type, p.plane_capacity
        FROM flight f
                 JOIN plane p ON f.airline_id = p.owner_id
        WHERE f.flight_number = flight_num
        ORDER BY plane_capacity;
BEGIN
    -- get number of seats for the flight
    numberOfSeats = getNumberOfSeats(flight_num, flight_time);
    raise notice '% number of seats for %', numberOfSeats, flight_num;

    -- get plane type
    SELECT plane_type
    INTO currentPlaneType
    FROM flight
    WHERE flight_number = flight_num;

    -- open cursor
    OPEN airlinePlanes;

    -- check if another plane owned by the airlines can fit current seats
    LOOP
        -- get next plane
        FETCH airlinePlanes INTO airplane_row;
        --exit when done
        EXIT WHEN NOT FOUND;

        -- found a plane can fit (we are starting from the smallest)
        IF numberOfSeats - 1 <= airplane_row.plane_capacity THEN
            raise notice '% should be downgraded', flight_num;
            -- if the smallest plane can fit is not the one already scheduled for the flight, then change it
            IF airplane_row.plane_type <> currentPlaneType THEN
                raise notice '% is beign downgraded to %', flight_num, airplane_row.plane_type;
                UPDATE flight SET plane_type = airplane_row.plane_type WHERE flight_number = flight_num;
            END IF;
            -- mission accomplished (either we changed the plane OR it is already the smallest we can fit)
            EXIT;
        END IF;

    END LOOP;

    -- close cursor
    CLOSE airlinePlanes;

END;
$$ language plpgsql;

DROP FUNCTION IF EXISTS reservationCancellation CASCADE;
CREATE OR REPLACE FUNCTION reservationCancellation()
    RETURNS TRIGGER AS
$$
DECLARE
    currentTime      timestamp;
    cancellationTime timestamp;
    reservation_row  RECORD;
    reservations CURSOR FOR
        SELECT *
        FROM (SELECT DISTINCT reservation_number
              FROM RESERVATION AS R
              WHERE R.ticketed = FALSE) AS NONTICKETED
                 NATURAL JOIN (SELECT DISTINCT reservation_number, flight_date, flight_number
                               FROM RESERVATION_DETAIL AS RD
                               WHERE (RD.flight_date >= currentTime)) AS CANCELLABLEFLIGHT ;
BEGIN
    -- capture our simulated current time
    currentTime := new.c_timestamp;

    -- open cursor
    OPEN reservations;

    LOOP
        -- get the next reservation number that is not ticketed
        FETCH reservations INTO reservation_row;

        -- exit loop when all records are processed
        EXIT WHEN NOT FOUND;

        -- get the cancellation time for the fetched reservation
        cancellationTime = getcancellationtime(reservation_row.reservation_number);
        raise notice 'cancellationTime = % and currentTime = %', cancellationTime,currentTime;
        -- delete customer reservation if departures is less than or equal 12 hrs
        IF (cancellationTime <= currentTime) THEN
            raise notice '% is being cancelled', reservation_row.reservation_number;
            -- delete the reservation
            DELETE FROM RESERVATION WHERE reservation_number = reservation_row.reservation_number;
            raise notice '% is attempting downgrading', reservation_row.flight_number;
            CALL downgradePlaneHelper(reservation_row.flight_number, reservation_row.flight_date);
        END IF;

    END LOOP;

    -- close cursor
    CLOSE reservations;

    RETURN new;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS cancelReservation ON ourtimestamp;
CREATE TRIGGER cancelReservation
    AFTER UPDATE
    ON OURTIMESTAMP
    FOR EACH ROW
EXECUTE PROCEDURE reservationCancellation();

---------------------------------------------------------------------------Frequent Flyer Trigger--------------------------------

-- It is commented as it was throwing error. Included just to show the logic used.

-- CREATE OR REPLACE FUNCTION customer_airline_price(airline integer,cust_id integer)
-- RETURNS integer
-- AS $$
--     DECLARE
--         total_cost integer;
--         cost integer;
--         freq_airline integer;
--         same_day boolean;
--         d_city char(3);
--         a_city char(3);
--         r record;
--     BEGIN
--         CREATE OR REPLACE VIEW leg_view AS
--             SELECT r.reservation_number,re.flight_number,f.airline_id,r.cid,re.leg
--             FROM reservation r,flight f,reservation_detail re
--             WHERE r.reservation_number = re.reservation_number and f.flight_number = re.flight_number;

--         SELECT a.airline_id INTO freq_airline
--         FROM customer c,airline a
--         WHERE lower(split_part(a.airline_name,' ',1)) = lower(c.frequent_miles) and c.cid = cust_id;
--         total_cost = 0;
--         FOR r IN (SELECT * FROM leg_view l WHERE l.cid = cust_id and l.airline_id = airline) loop

--             SELECT f.departure_city INTO d_city
--             FROM flight f
--             WHERE f.flight_number = r.flight_number;

--             SELECT f.arrival_city INTO a_city
--             FROM flight f
--             WHERE f.flight_number = r.flight_number;

--             same_day = check_reservation_same_day(r.reservation_number);

--             IF same_day = true THEN
--                 SELECT p.high_price INTO cost
--                 FROM price p
--                 WHERE p.departure_city = d_city and p.arrival_city = a_city;
--             ELSE
--                 SELECT p.low_price INTO cost
--                 FROM price p
--                 WHERE p.departure_city = d_city and p.arrival_city = a_city;
--             end if;
--             RAISE NOTICE 'flight between % to %',d_city,a_city;
--             RAISE NOTICE 'Price before discount is %',cost;

--             IF r.airline_id = freq_airline THEN
--                 cost = cost - (10 * cost/100);
--             end if;

--             RAISE NOTICE 'Price after discount is %',cost;
--             total_cost = total_cost + cost;
--             RAISE NOTICE 'updated cost is %',total_cost;
--         end loop;

--         return total_cost;
--     end;
--     $$LANGUAGE plpgsql;

-- CREATE OR REPLACE VIEW customer_airline_leg AS
--     SELECT t1.cid as cust_id,t1.airline_id,count(t1.leg_count) as leg_count
--     FROM (SELECT r.cid,r.reservation_number,a.airline_id,re.flight_number,re.leg as leg_count
--           FROM reservation r,reservation_detail re,airline a,flight f
--           WHERE r.reservation_number = re.reservation_number and r.ticketed = true and
--                 f.flight_number = re.flight_number and f.airline_id = a.airline_id) as t1
--     GROUP BY t1.cid, t1.airline_id;

-- CREATE OR REPLACE VIEW customer_airline_price AS
--     SELECT f.airline_id,r.cid as c_id,customer_airline_price(f.airline_id,r.cid) as price
--     FROM flight f,reservation r,reservation_detail re
--     WHERE re.reservation_number = r.reservation_number and re.flight_number = f.flight_number;


-- CREATE OR REPLACE FUNCTION frequent_flyer()
-- RETURNS TRIGGER
-- AS $$
--     DECLARE
--         freq_airline integer;
--         freq_airline_name varchar(10);
--         customer integer;
--     BEGIN
--         SELECT r.cid INTO customer
--         FROM reservation r
--         WHERE r.reservation_number = new.reservation_number;

--         RAISE NOTICE 'res_number updated is %',new.reservation_number;

--         IF old.ticketed = false and new.ticketed = true THEN

--             CREATE OR REPLACE VIEW leg_view AS
--                 SELECT *
--                 FROM customer_airline_leg cl
--                 WHERE cl.cust_id = new.cid;

--             CREATE OR REPLACE VIEW price_view AS
--                 SELECT *
--                 FROM customer_airline_price cp
--                 WHERE cp.c_id = new.cid;


--             SELECT t2.airline_id INTO freq_airline
--             FROM
--             (SELECT t1.cust_id,t1.airline_id,t1.leg,t1.price
--              FROM (SELECT cl.cust_id,cp.airline_id,cl.leg_count as leg,cp.price as price
--                    FROM leg_view cl,customer_airline_price cp
--                    WHERE cl.airline_id = cp.airline_id) as t1
--              ORDER BY t1.leg DESC,t1.price DESC
--              LIMIT 1) as t2;

--              SELECT upper(split_part(a.airline_name,' ',1)) INTO freq_airline_name
--              FROM airline a
--              WHERE a.airline_id = freq_airline;

--              RAISE NOTICE 'New frequent flyer for customer % is %',new.cid,freq_airline_name;

--              UPDATE customer
--              SET frequent_miles = freq_airline_name
--              WHERE customer.cid = customer;

--         END IF;
--         RETURN new;
--     END;
--     $$LANGUAGE plpgsql;

-- DROP TRIGGER IF EXISTS frequentFlyer on customer;
-- create trigger frequentFlyer
-- BEFORE UPDATE ON reservation
-- for each row
-- execute procedure frequent_flyer();