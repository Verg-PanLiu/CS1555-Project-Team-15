--Team 15
-- Names: Sudeep Albal(SWA14)
-- Liu Pan(pal81)
-- Xiaolei Yu(XIY78)


-- Creation of tables

DROP TABLE IF EXISTS AIRLINE CASCADE;
DROP TABLE IF EXISTS PLANE CASCADE;
DROP TABLE IF EXISTS FLIGHT CASCADE;
DROP TABLE IF EXISTS PRICE CASCADE;
DROP TABLE IF EXISTS CUSTOMER CASCADE;
DROP TABLE IF EXISTS RESERVATION CASCADE;
DROP TABLE IF EXISTS RESERVATION_DETAIL CASCADE;
DROP TABLE IF EXISTS OURTIMESTAMP CASCADE;

CREATE TABLE AIRLINE(
airline_id integer NOT NULL,
airline_name varchar(50) NOT NULL,
airline_abbreviation varchar(10) NOT NULL UNIQUE,
year_founded integer NOT NULL,
CONSTRAINT AIRLINE_PK PRIMARY KEY(airline_id)
);

CREATE TABLE PLANE(
plane_type char(4) NOT NULL,
manufacturer varchar(10) NOT NULL,
plane_capacity integer NOT NULL,
last_service_date date,
year integer NOT NULL,
owner_id integer NOT NULL,
CONSTRAINT PLANE_PK PRIMARY KEY(owner_id,plane_type),
CONSTRAINT PLANE_FK FOREIGN KEY(owner_id) REFERENCES AIRLINE(airline_id)
);

CREATE TABLE FLIGHT(
flight_number integer NOT NULL,
airline_id integer NOT NULL,
plane_type char(4) NOT NULL,
departure_city char(3) NOT NULL,
arrival_city char(3) NOT NULL,
departure_time varchar(4) NOT NULL,
arrival_time varchar(4) NOT NULL,
weekly_schedule varchar(7) NOT NULL,
CONSTRAINT FLIGHT_PK PRIMARY KEY(flight_number),
--CONSTRAINT FLIGHT_FK1 FOREIGN KEY(plane_type) REFERENCES PLANE(plane_type),
CONSTRAINT FLIGHT_FK1 FOREIGN KEY(airline_id,plane_type) REFERENCES PLANE(owner_id,plane_type)
);

CREATE TABLE PRICE(
departure_city char(3) NOT NULL,
arrival_city char(3) NOT NULL,
airline_id integer NOT NULL,
high_price integer NOT NULL,
low_price integer NOT NULL,
CONSTRAINT PRICE_PK PRIMARY KEY(departure_city,arrival_city),
CONSTRAINT PRICE_FK FOREIGN KEY(airline_id) REFERENCES AIRLINE(airline_id),
CONSTRAINT CHECK1 CHECK(low_price < high_price)
);

CREATE TABLE CUSTOMER(
cid integer,
salutation varchar(3),
first_name varchar(30) NOT NULL,
last_name varchar(30) NOT NULL,
credit_card_num varchar(16) UNIQUE NOT NULL,
street varchar(30) NOT NULL,
credit_card_expire date NOT NULL,
city varchar(30) NOT NULL,
state varchar(2) NOT NULL,
phone varchar(10) NOT NULL,
email varchar(30) NOT NULL,
frequent_miles varchar(10),
CONSTRAINT CUSTOMER_PK PRIMARY KEY(cid),
CONSTRAINT CUSTOMER_FK FOREIGN KEY(frequent_miles) REFERENCES AIRLINE(airline_abbreviation)
);

CREATE TABLE RESERVATION(
reservation_number integer,
cid integer NOT NULL,
cost decimal NOT NULL,
credit_card_num varchar(16) NOT NULL,
reservation_date timestamp NOT NULL,
ticketed boolean,
CONSTRAINT RESERVATION_PK PRIMARY KEY(reservation_number),
CONSTRAINT RESERVATION_FK1 FOREIGN KEY(cid) REFERENCES CUSTOMER(cid),
CONSTRAINT RESERVATION_FK2 FOREIGN KEY(credit_card_num) REFERENCES CUSTOMER(credit_card_num)
);

CREATE TABLE RESERVATION_DETAIL(
reservation_number integer NOT NULL,
flight_number integer NOT NULL,
flight_date timestamp NOT NULL,
leg integer NOT NULL,
CONSTRAINT RESERVATION_TABLE_PK PRIMARY KEY(reservation_number,leg),
CONSTRAINT RESERVATION_TABLE_FK1 FOREIGN KEY(reservation_number) REFERENCES RESERVATION(reservation_number),
CONSTRAINT RESERVATION_TABLE_FK2 FOREIGN KEY(flight_number) REFERENCES FLIGHT(flight_number)
);

CREATE TABLE OURTIMESTAMP(
c_timestamp timestamp,
CONSTRAINT OURTIMESTAMP_PK PRIMARY KEY(c_timestamp)
);




