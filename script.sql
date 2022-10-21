--IS 443/543 Fall Semester 2022
--Group O - Weston Evans and Saicharan Gattepali

--DROP Statements


DROP SEQUENCE rental_id_seq;
DROP TRIGGER rental_id_incr;
DROP TABLE bike_rental;

DROP SEQUENCE bike_id_seq;
DROP TRIGGER bike_id_incr;
DROP TABLE bike;

DROP SEQUENCE category_id_seq;
DROP TRIGGER category_id_incr;
DROP TABLE category;


DROP SEQUENCE manufacturer_id_seq;
DROP TRIGGER manufacturer_id_incr;
DROP TABLE manufacturer;

DROP SEQUENCE member_id_seq;
DROP TRIGGER member_id_incr;
DROP TABLE customer;

DROP SEQUENCE staff_id_seq;
DROP TRIGGER staff_id_incr;
DROP TABLE staff;


DROP SEQUENCE location_id_seq;
DROP TRIGGER location_id_incr;
DROP TABLE location;

--TABLE Creation

CREATE TABLE manufacturer (
manufacturer_id INTEGER CONSTRAINT manufacturer_PK PRIMARY KEY,
manufacturer_name VARCHAR2(35) NOT NULL UNIQUE
);

CREATE SEQUENCE manufacturer_id_seq;

CREATE TRIGGER manufacturer_id_incr
BEFORE INSERT ON manufacturer
FOR EACH ROW
BEGIN
    SELECT manufacturer_id_seq.nextval
    INTO :new.manufacturer_id
    FROM DUAL;
END; 
/

CREATE TABLE location (
location_id INTEGER NOT NULL CONSTRAINT location_PK PRIMARY KEY,
street VARCHAR2(50) NOT NULL,
city VARCHAR2(30) NOT NULL,
state CHAR(2) NOT NULL,
zipcode VARCHAR2(10) NOT NULL,
phone VARCHAR2(20) NOT NULL
); 

CREATE SEQUENCE location_id_seq;

CREATE TRIGGER location_id_incr
BEFORE INSERT ON location
FOR EACH ROW
BEGIN
    SELECT location_id_seq.nextval
    INTO :new.location_id
    FROM DUAL;
END; 
/

CREATE TABLE staff (
staff_id INTEGER CONSTRAINT staff_PK PRIMARY KEY,
fname VARCHAR2(50) NOT NULL,
lname VARCHAR2(50) NOT NULL,
position VARCHAR2(25) NOT NULL,
address VARCHAR2(25) NOT NULL,
phone VARCHAR2(20) NOT NULL,
salary NUMBER NOT NULL,
location_id INTEGER NOT NULL CONSTRAINT staff_FK REFERENCES location(location_id)
); 

CREATE SEQUENCE staff_id_seq;

CREATE TRIGGER staff_id_incr
BEFORE INSERT ON staff
FOR EACH ROW
BEGIN
    SELECT staff_id_seq.nextval
    INTO :new.staff_id
    FROM DUAL;
END; 
/

CREATE TABLE customer (
member_id INTEGER CONSTRAINT customer_PK PRIMARY KEY,
fname VARCHAR2(50) NOT NULL,
lname VARCHAR2(50) NOT NULL,
address VARCHAR2(25) NOT NULL,
phone VARCHAR2(20) NOT NULL,
registration_date DATE NOT NULL,
num_rentals NUMBER,
unpaid_balance NUMBER
); 

CREATE SEQUENCE member_id_seq;

CREATE TRIGGER member_id_incr
BEFORE INSERT ON customer
FOR EACH ROW
BEGIN
    SELECT member_id_seq.nextval
    INTO :new.member_id
    FROM DUAL;
    SELECT SYSDATE 
    INTO :new.registration_date
    FROM DUAL;
END; 
/
CREATE TABLE category (
category_id INTEGER CONSTRAINT category_PK PRIMARY KEY,
category_name VARCHAR2(20) NOT NULL
); 

CREATE SEQUENCE category_id_seq;

CREATE TRIGGER category_id_incr
BEFORE INSERT ON category
FOR EACH ROW
BEGIN
    SELECT category_id_seq.nextval
    INTO :new.category_id
    FROM DUAL;
END; 
/

CREATE TABLE bike (
bike_id INTEGER NOT NULL CONSTRAINT bike_PK PRIMARY KEY,
description VARCHAR2(250) NOT NULL,
category_id INTEGER NOT NULL CONSTRAINT category_FK REFERENCES category(category_id),
status VARCHAR2(3) NOT NULL,
manufacturer_id INTEGER NOT NULL CONSTRAINT manufacturer_FK REFERENCES manufacturer(manufacturer_id),
location_id INTEGER CONSTRAINT location_FK REFERENCES location(location_id),
daily_fee NUMBER NOT NULL
); 

CREATE SEQUENCE bike_id_seq;

CREATE TRIGGER bike_id_incr
BEFORE INSERT ON bike
FOR EACH ROW
BEGIN
    SELECT bike_id_seq.nextval
    INTO :new.bike_id
    FROM DUAL;
END; 
/

CREATE TABLE bike_rental (
rental_id INTEGER NOT NULL CONSTRAINT bike_rental_PK PRIMARY KEY,
member_id INTEGER NOT NULL CONSTRAINT member_FK REFERENCES customer(member_id),
bike_id INTEGER NOT NULL CONSTRAINT bike_FK REFERENCES bike(bike_id),
rented_out DATE NOT NULL,
rented_from INTEGER NOT NULL CONSTRAINT rented_from_FK REFERENCES location(location_id),
exp_return DATE NOT NULL,
act_return DATE,
returned_to INTEGER CONSTRAINT returned_FK REFERENCES location(location_id)
); 

CREATE SEQUENCE rental_id_seq;

CREATE TRIGGER rental_id_incr
BEFORE INSERT ON bike_rental
FOR EACH ROW
BEGIN
    SELECT rental_id_seq.nextval
    INTO :new.rental_id
    FROM DUAL;
    SELECT SYSDATE 
    INTO :new.rented_out
    FROM DUAL;
END; 




--INSERT INTO manufacturer (m_name)
--VALUES ('next');
--
--INSERT INTO customer (fname, lname, address, phone)
--VALUES('', '', '', '');
--
--SELECT * FROM manufacturer;
--SELECT * FROM customer;
--
--
--DELETE FROM customer
--WHERE member_id = 1;
--
--DELETE FROM manufacturer
--WHERE m_code = 1 or m_code = 3 or m_code = 4;












