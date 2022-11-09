--IS 443/543 Fall Semester 2022
--Group O - Weston Evans and Saicharan Gattepali

--Create a procedure similar to DROP IF EXISTS

CREATE OR REPLACE PROCEDURE DelObject(ObjName varchar2,ObjType varchar2)
IS
 v_counter number := 0;   
begin    
  if ObjType = 'TABLE' then
    select count(*) into v_counter from user_tables where table_name = upper(ObjName);
    if v_counter > 0 then          
      execute immediate 'drop table ' || ObjName || ' cascade constraints';        
    end if;   
  end if;
  if ObjType = 'PROCEDURE' then
    select count(*) into v_counter from User_Objects where object_type = 'PROCEDURE' and OBJECT_NAME = upper(ObjName);
      if v_counter > 0 then          
        execute immediate 'DROP PROCEDURE ' || ObjName;        
      end if; 
  end if;
  if ObjType = 'FUNCTION' then
    select count(*) into v_counter from User_Objects where object_type = 'FUNCTION' and OBJECT_NAME = upper(ObjName);
      if v_counter > 0 then          
        execute immediate 'DROP FUNCTION ' || ObjName;        
      end if; 
  end if;
  if ObjType = 'TRIGGER' then
    select count(*) into v_counter from User_Triggers where TRIGGER_NAME = upper(ObjName);
      if v_counter > 0 then          
        execute immediate 'DROP TRIGGER ' || ObjName;
      end if; 
  end if;
  if ObjType = 'VIEW' then
    select count(*) into v_counter from User_Views where VIEW_NAME = upper(ObjName);
      if v_counter > 0 then          
        execute immediate 'DROP VIEW ' || ObjName;        
      end if; 
  end if;
  if ObjType = 'SEQUENCE' then
    select count(*) into v_counter from user_sequences where sequence_name = upper(ObjName);
      if v_counter > 0 then          
        execute immediate 'DROP SEQUENCE ' || ObjName;        
      end if; 
  end if;
end;
/
-- DROP statements / Execute procedure DelObject for each obj in database

EXECUTE DelObject ('location_id_seq','SEQUENCE'); 
EXECUTE DelObject ('location_id_incr','TRIGGER'); 
EXECUTE DelObject ('location','TABLE'); 

EXECUTE DelObject ('member_id_seq','SEQUENCE'); 
EXECUTE DelObject ('member_id_incr','TRIGGER'); 
EXECUTE DelObject ('customer','TABLE'); 

EXECUTE DelObject ('category_id_seq','SEQUENCE'); 
EXECUTE DelObject ('category_id_incr','TRIGGER'); 
EXECUTE DelObject ('category','TABLE'); 

EXECUTE DelObject ('rental_id_seq','SEQUENCE'); 
EXECUTE DelObject ('rental_id_incr','TRIGGER'); 
EXECUTE DelObject ('rental_bike','TABLE'); 

EXECUTE DelObject ('detail_id_seq','SEQUENCE'); 
EXECUTE DelObject ('detail_id_incr','TRIGGER'); 
EXECUTE DelObject ('rental_detail','TABLE');

EXECUTE DelObject ('bike_id_seq','SEQUENCE'); 
EXECUTE DelObject ('bike_id_incr','TRIGGER'); 
EXECUTE DelObject ('bike','TABLE');


EXECUTE DelObject ('manufacturer_id_seq','SEQUENCE'); 
EXECUTE DelObject ('manufacturer_id_incr','TRIGGER'); 
EXECUTE DelObject ('manufacturer','TABLE');

EXECUTE DelObject ('staff_id_seq','SEQUENCE'); 
EXECUTE DelObject ('staff_id_incr','TRIGGER'); 
EXECUTE DelObject ('staff','TABLE');

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

--Row 1
INSERT INTO MANUFACTURER (MANUFACTURER_NAME) VALUES ('Santa Cruz');
--Row 2
INSERT INTO MANUFACTURER (MANUFACTURER_NAME) VALUES ('Diamondback');
--Row 3
INSERT INTO MANUFACTURER (MANUFACTURER_NAME) VALUES ('Raleigh');
--Row 4
INSERT INTO MANUFACTURER (MANUFACTURER_NAME) VALUES ('GT');
--Row 5
INSERT INTO MANUFACTURER (MANUFACTURER_NAME) VALUES ('Schwinn');
--Row 6
INSERT INTO MANUFACTURER (MANUFACTURER_NAME) VALUES ('Canyon');
--Row 7
INSERT INTO MANUFACTURER (MANUFACTURER_NAME) VALUES ('Mongoose');
--Row 8
INSERT INTO MANUFACTURER (MANUFACTURER_NAME) VALUES ('Ancheer');
--Row 9
INSERT INTO MANUFACTURER (MANUFACTURER_NAME) VALUES ('Montague');
--Row 10
INSERT INTO MANUFACTURER (MANUFACTURER_NAME) VALUES ('Pinarello');

--TABLE Creation

CREATE TABLE location (
location_id INTEGER NOT NULL CONSTRAINT location_PK PRIMARY KEY,
street VARCHAR2(50) NOT NULL UNIQUE,
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

--Row 1
INSERT INTO LOCATION (LOCATION_ID, STREET, CITY, STATE, ZIPCODE, PHONE) VALUES (1,'101 S Main St','River Falls','WI','54022','715-629-7246');
--Row 2
INSERT INTO LOCATION (LOCATION_ID, STREET, CITY, STATE, ZIPCODE, PHONE) VALUES (2,'6028 MN-36','Oakdale','MN','55128','651-777-0188');
--Row 3
INSERT INTO LOCATION (LOCATION_ID, STREET, CITY, STATE, ZIPCODE, PHONE) VALUES (3,'1019 1st Ave SE','Aberdeen','SD','57401','605-216-1583');

--TABLE Creation

CREATE TABLE staff (
staff_id INTEGER CONSTRAINT staff_PK PRIMARY KEY,
fname VARCHAR2(50) NOT NULL,
lname VARCHAR2(50) NOT NULL,
position VARCHAR2(25) NOT NULL,
address VARCHAR2(25) NOT NULL,
phone VARCHAR2(20) NOT NULL,
salary INTEGER NOT NULL,
location_id INTEGER NOT NULL CONSTRAINT staff_FK REFERENCES location(location_id) ON DELETE CASCADE
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
--Row 1
INSERT INTO STAFF (FNAME, LNAME, POSITION, ADDRESS, PHONE, SALARY, LOCATION_ID) VALUES ('Delila','Crouse','worker','255 Gateway Lane','633-574-4985',20000,1);
--Row 2
INSERT INTO STAFF (FNAME, LNAME, POSITION, ADDRESS, PHONE, SALARY, LOCATION_ID) VALUES ('Laverne','Oneil','worker','02915 Dayton Junction','585-343-1262',20000,1);
--Row 3
INSERT INTO STAFF (FNAME, LNAME, POSITION, ADDRESS, PHONE, SALARY, LOCATION_ID) VALUES ('Orton','Ealden','worker','12156 Arapahoe Pass','714-592-2549',20000,1);
--Row 4
INSERT INTO STAFF (FNAME, LNAME, POSITION, ADDRESS, PHONE, SALARY, LOCATION_ID) VALUES ('Gael','Mcettrick','worker','59 Jana Street','759-106-3934',20000,1);
--Row 5
INSERT INTO STAFF (FNAME, LNAME, POSITION, ADDRESS, PHONE, SALARY, LOCATION_ID) VALUES ('Philomena','OGara','worker','83976 Redwing Hill','430-964-9538',20000,1);
--Row 6
INSERT INTO STAFF (FNAME, LNAME, POSITION, ADDRESS, PHONE, SALARY, LOCATION_ID) VALUES ('Neils','Sampey','worker','0624 Killdeer Junction','659-929-5640',20000,1);
--Row 7
INSERT INTO STAFF (FNAME, LNAME, POSITION, ADDRESS, PHONE, SALARY, LOCATION_ID) VALUES ('Anne-marie','Fenning','manager','617 Hermina Junction','166-383-6200',60000,1);


--TABLE Creation

CREATE TABLE customer (
member_id INTEGER CONSTRAINT customer_PK PRIMARY KEY,
fname VARCHAR2(150) NOT NULL,
lname VARCHAR2(150) NOT NULL,
email VARCHAR2(250) NOT NULL,
password VARCHAR2(200) NOT NULL,
address VARCHAR2(200) NOT NULL,
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
--TABLE Creation

CREATE TABLE category (
category_id INTEGER CONSTRAINT category_PK PRIMARY KEY,
category_name VARCHAR2(20) NOT NULL UNIQUE
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

--Row 1
INSERT INTO CATEGORY (CATEGORY_NAME) VALUES ('BMX');
--Row 2
INSERT INTO CATEGORY (CATEGORY_NAME) VALUES ('road');
--Row 3
INSERT INTO CATEGORY (CATEGORY_NAME) VALUES ('mountain');
--Row 4
INSERT INTO CATEGORY (CATEGORY_NAME) VALUES ('touring');
--Row 5
INSERT INTO CATEGORY (CATEGORY_NAME) VALUES ('folding');
--Row 6
INSERT INTO CATEGORY (CATEGORY_NAME) VALUES ('recumbent');
--Row 7
INSERT INTO CATEGORY (CATEGORY_NAME) VALUES ('road-electric');
--Row 8
INSERT INTO CATEGORY (CATEGORY_NAME) VALUES ('mountain-electric');
--Row 9
INSERT INTO CATEGORY (CATEGORY_NAME) VALUES ('folding-electric');

--TABLE Creation

CREATE TABLE bike (
bike_id INTEGER NOT NULL CONSTRAINT bike_PK PRIMARY KEY,
description VARCHAR2(250) NOT NULL,
status VARCHAR2(3) NOT NULL,
daily_fee INTEGER NOT NULL,
category_id INTEGER NOT NULL CONSTRAINT category_FK REFERENCES category(category_id) ON DELETE CASCADE,
manufacturer_id INTEGER NOT NULL CONSTRAINT manufacturer_FK REFERENCES manufacturer(manufacturer_id) ON DELETE CASCADE,
location_id INTEGER CONSTRAINT location_FK REFERENCES location(location_id) ON DELETE CASCADE
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

--Row 1
INSERT INTO BIKE (DESCRIPTION, CATEGORY_ID, STATUS, MANUFACTURER_ID, LOCATION_ID, DAILY_FEE) VALUES ('Performer 29',1,'in',4,1,40);
--Row 2
INSERT INTO BIKE (DESCRIPTION, CATEGORY_ID, STATUS, MANUFACTURER_ID, LOCATION_ID, DAILY_FEE) VALUES ('Atroz 2',3,'in',2,1,80);
--Row 3
INSERT INTO BIKE (DESCRIPTION, CATEGORY_ID, STATUS, MANUFACTURER_ID, LOCATION_ID, DAILY_FEE) VALUES ('Fastback Carbon 105',2,'in',5,1,120);
--Row 4
INSERT INTO BIKE (DESCRIPTION, CATEGORY_ID, STATUS, MANUFACTURER_ID, LOCATION_ID, DAILY_FEE) VALUES ('Lux Trail CF 7',3,'in',6,1,150);
--Row 5
INSERT INTO BIKE (DESCRIPTION, CATEGORY_ID, STATUS, MANUFACTURER_ID, LOCATION_ID, DAILY_FEE) VALUES ('AMA5183',9,'in',8,1,25);
--Row 6
INSERT INTO BIKE (DESCRIPTION, CATEGORY_ID, STATUS, MANUFACTURER_ID, LOCATION_ID, DAILY_FEE) VALUES ('Prince Force ETAP AXS 12S',2,'in',10,1,175);
--Row 7
INSERT INTO BIKE (DESCRIPTION, CATEGORY_ID, STATUS, MANUFACTURER_ID, LOCATION_ID, DAILY_FEE) VALUES ('M-E1',7,'in',9,1,150);

--TABLE Creation

CREATE TABLE rental_bike (
rental_id INTEGER NOT NULL CONSTRAINT bike_rental_PK PRIMARY KEY,
member_id INTEGER NOT NULL CONSTRAINT member_id_FK REFERENCES customer(member_id) ON DELETE CASCADE,
rented_out DATE NOT NULL
); 

CREATE SEQUENCE rental_id_seq;

CREATE TRIGGER rental_id_incr
BEFORE INSERT ON rental_bike
FOR EACH ROW
BEGIN
    SELECT rental_id_seq.nextval
    INTO :new.rental_id
    FROM DUAL;
    SELECT SYSDATE 
    INTO :new.rented_out
    FROM DUAL;
END; 
/

--TABLE Creation

CREATE TABLE rental_detail (
detail_id INTEGER NOT NULL CONSTRAINT rental_detail_PK PRIMARY KEY,
rental_id INTEGER NOT NULL CONSTRAINT rental_id_FK REFERENCES rental_bike(rental_id) ON DELETE CASCADE,
bike_id INTEGER NOT NULL CONSTRAINT bike_id_FK REFERENCES bike(bike_id) ON DELETE CASCADE,
rented_from INTEGER NOT NULL CONSTRAINT rented_from_FK REFERENCES location(location_id) ON DELETE CASCADE,
exp_return DATE NOT NULL,
act_return DATE,
returned_to INTEGER CONSTRAINT returned_FK REFERENCES location(location_id) ON DELETE CASCADE,
total_fee INTEGER NOT NULL
); 

CREATE SEQUENCE detail_id_seq;

CREATE TRIGGER detail_id_incr
BEFORE INSERT ON rental_detail
FOR EACH ROW
BEGIN
    SELECT detail_id_seq.nextval
    INTO :new.detail_id
    FROM DUAL;
END; 
/


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














