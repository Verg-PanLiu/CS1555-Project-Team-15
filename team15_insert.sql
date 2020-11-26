--INsert into customer

INSERT INTO CUSTOMER (cid, salutation, first_name, last_name, credit_card_num, credit_card_expire, street, city, state,
                      phone, email, frequent_miles)
VALUES (1, 'Mr', 'Jon', 'Smith', '6859941825383380', TO_DATE('04-13-2022', 'MM-DD-YYYY'), 'Bigelow Boulevard',
        'Pittsburgh', 'PA', '412222222', 'jsmith@gmail.com', 'ALASKA');
INSERT INTO CUSTOMER (cid, salutation, first_name, last_name, credit_card_num, credit_card_expire, street, city, state,
                      phone, email, frequent_miles)
VALUES (2, 'Mrs', 'Latanya', 'Wood', '7212080255339668', TO_DATE('07-05-2023', 'MM-DD-YYYY'), 'Houston Street',
        'New York', 'NY', '7187181717', 'lw@aol.com', 'ALLEGIANT');
INSERT INTO CUSTOMER (cid, salutation, first_name, last_name, credit_card_num, credit_card_expire, street, city, state,
                      phone, email, frequent_miles)
VALUES (3, 'Ms', 'Gabriella', 'Rojas', '4120892825130802', TO_DATE('09-22-2024', 'MM-DD-YYYY'), 'Melrose Avenue',
        'Los Angeles', 'CA', '2133234567', 'gar@yahoo.com', 'AMERICAN');
INSERT INTO CUSTOMER (cid, salutation, first_name, last_name, credit_card_num, credit_card_expire, street, city, state,
                      phone, email, frequent_miles)
VALUES (4, 'Mr', 'Abbas', 'Malouf', '4259758505178751', TO_DATE('10-17-2021', 'MM-DD-YYYY'), 'Pine Street', 'Seattle',
        'WA', '2066170345', 'malouf.a@outlook.com', 'DELTA');
INSERT INTO CUSTOMER (cid, salutation, first_name, last_name, credit_card_num, credit_card_expire, street, city, state,
                      phone, email, frequent_miles)
VALUES (5, 'Ms', 'Amy', 'Liu', '2538244543760285', TO_DATE('03-24-2022', 'MM-DD-YYYY'), 'Amber Drive', 'Houston', 'TX',
        '2818880106', 'amyliu45@icloud.com', 'UNITED');
INSERT INTO CUSTOMER (cid, salutation, first_name, last_name, credit_card_num, credit_card_expire, street, city, state,
                      phone, email, frequent_miles)
VALUES (6, 'Mr', 'Pan', 'Liu', '2538244543760286', TO_DATE('03-24-2022', 'MM-DD-YYYY'), 'Amber Drive', 'Houston', 'TX',
        '2818880105', 'liupan45@icloud.com', 'PITT');
INSERT INTO CUSTOMER (cid, salutation, first_name, last_name, credit_card_num, credit_card_expire, street, city, state,
                      phone, email, frequent_miles)
VALUES (7, 'Mr', 'Sudeep', 'Albal', '2538244543760287', TO_DATE('03-24-2022', 'MM-DD-YYYY'), 'Amber Drive', 'Houston', 'TX',
        '2818880100', 'sudal45@icloud.com', 'FRONTIER');
INSERT INTO CUSTOMER (cid, salutation, first_name, last_name, credit_card_num, credit_card_expire, street, city, state,
                      phone, email, frequent_miles)
VALUES (8, 'Mr', 'Xiolai', 'Yu', '2538244543760288', TO_DATE('03-24-2022', 'MM-DD-YYYY'), 'Amber Drive', 'Houston', 'TX',
        '2818880101', 'xyu45@icloud.com', 'PITT');
INSERT INTO CUSTOMER (cid, salutation, first_name, last_name, credit_card_num, credit_card_expire, street, city, state,
                      phone, email, frequent_miles)
VALUES (9, 'Mr', 'Parth', 'Shah', '2538244543760289', TO_DATE('03-24-2022', 'MM-DD-YYYY'), 'DithRidge', 'Pittsburgh', 'PA',
        '2818880103', 'ps45@icloud.com', 'AMERICAN');
INSERT INTO CUSTOMER (cid, salutation, first_name, last_name, credit_card_num, credit_card_expire, street, city, state,
                      phone, email, frequent_miles)
VALUES (10, 'Mr', 'Antony', 'Kelvin', '2538244543760280', TO_DATE('03-24-2022', 'MM-DD-YYYY'), 'Shadyside', 'Pittsburgh', 'PA',
        '2818880104', 'ak45@icloud.com', 'ALASKA');
INSERT INTO CUSTOMER (cid, salutation, first_name, last_name, credit_card_num, credit_card_expire, street, city, state,
                      phone, email, frequent_miles)
VALUES (11, 'Mr', 'Tom', 'Hanks', '2538244543760290', TO_DATE('03-24-2022', 'MM-DD-YYYY'), 'Georgia', 'Atlanta', 'GA',
        '2818880109', 'th45@icloud.com', 'ALLEGIANT');
INSERT INTO CUSTOMER (cid, salutation, first_name, last_name, credit_card_num, credit_card_expire, street, city, state,
                      phone, email, frequent_miles)
VALUES (12, 'Mr', 'Tom', 'Cruise', '2538244543760291', TO_DATE('03-24-2022', 'MM-DD-YYYY'), 'NYC street', 'NewYork', 'NY',
        '2818880209', 'tc45@icloud.com', 'SOUTHWEST');
INSERT INTO CUSTOMER (cid, salutation, first_name, last_name, credit_card_num, credit_card_expire, street, city, state,
                      phone, email, frequent_miles)
VALUES (13, 'Ms', 'Julia', 'Roberts', '2538244543760292', TO_DATE('03-24-2022', 'MM-DD-YYYY'), 'NYC street', 'NewYork', 'NY',
        '2818880209', 'jr45@icloud.com', 'PITT');

-- INsert into reservation

INSERT INTO RESERVATION (reservation_number, cid, cost, credit_card_num, reservation_date, ticketed)
VALUES (1, 1, 540, '6859941825383380', TO_TIMESTAMP('11-02-2020 10:55', 'MM-DD-YYYY HH24:MI'), TRUE);
INSERT INTO RESERVATION (reservation_number, cid, cost, credit_card_num, reservation_date, ticketed)
VALUES (2, 2, 531, '7212080255339668', TO_TIMESTAMP('11-22-2020 14:25', 'MM-DD-YYYY HH24:MI'), TRUE);
INSERT INTO RESERVATION (reservation_number, cid, cost, credit_card_num, reservation_date, ticketed)
VALUES (3, 3, 350, '4120892825130802', TO_TIMESTAMP('11-05-2020 17:20', 'MM-DD-YYYY HH24:MI'), FALSE);
INSERT INTO RESERVATION (reservation_number, cid, cost, credit_card_num, reservation_date, ticketed)
VALUES (4, 4, 680, '4259758505178751', TO_TIMESTAMP('12-01-2020 06:05', 'MM-DD-YYYY HH24:MI'), TRUE);
INSERT INTO RESERVATION (reservation_number, cid, cost, credit_card_num, reservation_date, ticketed)
VALUES (5, 5, 702, '2538244543760285', TO_TIMESTAMP('10-28-2020 22:45', 'MM-DD-YYYY HH24:MI'), TRUE);
INSERT INTO RESERVATION (reservation_number, cid, cost, credit_card_num, reservation_date, ticketed)
VALUES (6, 6, 1332, '2538244543760286', TO_TIMESTAMP('10-28-2020 22:45', 'MM-DD-YYYY HH24:MI'), FALSE);
INSERT INTO RESERVATION (reservation_number, cid, cost, credit_card_num, reservation_date, ticketed)
VALUES (7, 1, 315, '6859941825383380', TO_TIMESTAMP('11-02-2020 10:55', 'MM-DD-YYYY HH24:MI'), TRUE);
INSERT INTO RESERVATION (reservation_number, cid, cost, credit_card_num, reservation_date, ticketed)
VALUES (8, 3,1180, '4120892825130802', TO_TIMESTAMP('11-05-2020 17:20', 'MM-DD-YYYY HH24:MI'), TRUE);
INSERT INTO RESERVATION (reservation_number, cid, cost, credit_card_num, reservation_date, ticketed)
VALUES (9, 8, 440, '2538244543760288', TO_TIMESTAMP('10-28-2020 22:45', 'MM-DD-YYYY HH24:MI'), TRUE);
INSERT INTO RESERVATION (reservation_number, cid, cost, credit_card_num, reservation_date, ticketed)
VALUES (10, 9, 480, '2538244543760289', TO_TIMESTAMP('10-28-2020 22:45', 'MM-DD-YYYY HH24:MI'), TRUE);
INSERT INTO RESERVATION (reservation_number, cid, cost, credit_card_num, reservation_date, ticketed)
VALUES (11,11, 350, '2538244543760290', TO_TIMESTAMP('10-30-2020 22:45', 'MM-DD-YYYY HH24:MI'), TRUE);

--INsert into reservation_detail

INSERT INTO RESERVATION_DETAIL (reservation_number, flight_number, flight_date, leg)
VALUES (1, 1, TO_TIMESTAMP('11-02-2020 13:55', 'MM-DD-YYYY HH24:MI'), 1);
INSERT INTO RESERVATION_DETAIL (reservation_number, flight_number, flight_date, leg)
VALUES (1, 2, TO_TIMESTAMP('11-02-2020 18:20', 'MM-DD-YYYY HH24:MI'), 2);
INSERT INTO RESERVATION_DETAIL (reservation_number, flight_number, flight_date, leg)
VALUES (7, 1, TO_TIMESTAMP('11-05-2020 18:30', 'MM-DD-YYYY HH24:MI'), 1);
INSERT INTO RESERVATION_DETAIL (reservation_number, flight_number, flight_date, leg)
VALUES (2, 4, TO_TIMESTAMP('11-05-2020 19:40', 'MM-DD-YYYY HH24:MI'), 1);
INSERT INTO RESERVATION_DETAIL (reservation_number, flight_number, flight_date, leg)
VALUES (2, 6, TO_TIMESTAMP('11-06-2020 20:45', 'MM-DD-YYYY HH24:MI'), 2);
INSERT INTO RESERVATION_DETAIL (reservation_number, flight_number, flight_date, leg)
VALUES (3, 5, TO_TIMESTAMP('11-06-2020 17:40', 'MM-DD-YYYY HH24:MI'), 1);
INSERT INTO RESERVATION_DETAIL (reservation_number, flight_number, flight_date, leg)
VALUES (8, 7, TO_TIMESTAMP('11-07-2020 08:30', 'MM-DD-YYYY HH24:MI'), 1);
INSERT INTO RESERVATION_DETAIL (reservation_number, flight_number, flight_date, leg)
VALUES (8, 8, TO_TIMESTAMP('11-07-2020 11:30', 'MM-DD-YYYY HH24:MI'), 2);
INSERT INTO RESERVATION_DETAIL (reservation_number, flight_number, flight_date, leg)
VALUES (5, 10, TO_TIMESTAMP('11-08-2020 16:30', 'MM-DD-YYYY HH24:MI'), 1);
INSERT INTO RESERVATION_DETAIL (reservation_number, flight_number, flight_date, leg)
VALUES (5, 11, TO_TIMESTAMP('11-08-2020 19:30', 'MM-DD-YYYY HH24:MI'), 2);
INSERT INTO RESERVATION_DETAIL (reservation_number, flight_number, flight_date, leg)
VALUES (9, 10, TO_TIMESTAMP('11-08-2020 16:30', 'MM-DD-YYYY HH24:MI'), 1);
INSERT INTO RESERVATION_DETAIL (reservation_number, flight_number, flight_date, leg)
VALUES (6, 12, TO_TIMESTAMP('11-08-2020 13:30', 'MM-DD-YYYY HH24:MI'), 1);
INSERT INTO RESERVATION_DETAIL (reservation_number, flight_number, flight_date, leg)
VALUES (6, 13, TO_TIMESTAMP('11-08-2020 15:45', 'MM-DD-YYYY HH24:MI'), 2);
INSERT INTO RESERVATION_DETAIL (reservation_number, flight_number, flight_date, leg)
VALUES (6, 14, TO_TIMESTAMP('11-08-2020 19:50', 'MM-DD-YYYY HH24:MI'), 3);
INSERT INTO RESERVATION_DETAIL (reservation_number, flight_number, flight_date, leg)
VALUES (10, 14, TO_TIMESTAMP('11-10-2020 19:50', 'MM-DD-YYYY HH24:MI'), 1);
INSERT INTO RESERVATION_DETAIL (reservation_number, flight_number, flight_date, leg)
VALUES (4, 17, TO_TIMESTAMP('11-10-2020 13:30', 'MM-DD-YYYY HH24:MI'), 1);
INSERT INTO RESERVATION_DETAIL (reservation_number, flight_number, flight_date, leg)
VALUES (4, 18, TO_TIMESTAMP('11-10-2020 15:30', 'MM-DD-YYYY HH24:MI'), 2);
INSERT INTO RESERVATION_DETAIL (reservation_number, flight_number, flight_date, leg)
VALUES (11, 20, TO_TIMESTAMP('11-10-2020 15:30', 'MM-DD-YYYY HH24:MI'), 1);