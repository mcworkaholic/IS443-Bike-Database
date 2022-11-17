--IS 443/543 Fall Semester 2022
--Group O - Weston Evans 

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
EXECUTE DelObject ('num_rentals_seq','SEQUENCE'); 
EXECUTE DelObject ('member_id_incr','TRIGGER'); 
EXECUTE DelObject ('customer','TABLE'); 

EXECUTE DelObject ('category_id_seq','SEQUENCE'); 
EXECUTE DelObject ('category_id_incr','TRIGGER'); 
EXECUTE DelObject ('category','TABLE'); 

EXECUTE DelObject ('rental_id_seq','SEQUENCE'); 
EXECUTE DelObject ('rental_id_incr','TRIGGER'); 
EXECUTE DelObject ('update_bike_out','TRIGGER'); 
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

--Setting time zone and date format
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-YYYY';
ALTER SESSION SET TIME_ZONE='America/Chicago';

--TABLE Creation

CREATE TABLE manufacturer (
manufacturer_id INTEGER CONSTRAINT manufacturer_PK PRIMARY KEY,
manufacturer_name VARCHAR2(35) NOT NULL UNIQUE
);

CREATE SEQUENCE manufacturer_id_seq;

CREATE OR REPLACE TRIGGER manufacturer_id_incr
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
INSERT INTO MANUFACTURER (MANUFACTURER_NAME) VALUES ('Trek');
--Row 4
INSERT INTO MANUFACTURER (MANUFACTURER_NAME) VALUES ('Raleigh');
--Row 5
INSERT INTO MANUFACTURER (MANUFACTURER_NAME) VALUES ('GT');
--Row 6
INSERT INTO MANUFACTURER (MANUFACTURER_NAME) VALUES ('Schwinn');
--Row 7
INSERT INTO MANUFACTURER (MANUFACTURER_NAME) VALUES ('Canyon');
--Row 8
INSERT INTO MANUFACTURER (MANUFACTURER_NAME) VALUES ('Mongoose');
--Row 9
INSERT INTO MANUFACTURER (MANUFACTURER_NAME) VALUES ('Ancheer');
--Row 10
INSERT INTO MANUFACTURER (MANUFACTURER_NAME) VALUES ('Montague');
--Row 11
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

CREATE OR REPLACE TRIGGER location_id_incr
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

CREATE OR REPLACE TRIGGER staff_id_incr
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
num_rentals INTEGER CONSTRAINT num_rental_check CHECK(num_rentals <= 2),
unpaid_balance NUMBER (6,2) CONSTRAINT balance_check CHECK(unpaid_balance <= 500.00) 
); 

CREATE SEQUENCE member_id_seq;


CREATE OR REPLACE TRIGGER member_id_incr
BEFORE INSERT ON customer
FOR EACH ROW
BEGIN
    SELECT member_id_seq.nextval
    INTO :new.member_id
    FROM DUAL;
    SELECT CURRENT_DATE
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

CREATE OR REPLACE TRIGGER category_id_incr
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
INSERT INTO CATEGORY (CATEGORY_NAME) VALUES ('commuter');
--Row 7
INSERT INTO CATEGORY (CATEGORY_NAME) VALUES ('recumbent');
--Row 8
INSERT INTO CATEGORY (CATEGORY_NAME) VALUES ('road-electric');
--Row 9
INSERT INTO CATEGORY (CATEGORY_NAME) VALUES ('mountain-electric');
--Row 10
INSERT INTO CATEGORY (CATEGORY_NAME) VALUES ('folding-electric');

--TABLE Creation

CREATE TABLE bike (
bike_id INTEGER NOT NULL CONSTRAINT bike_PK PRIMARY KEY,
product VARCHAR2(25) NOT NULL,
description VARCHAR2(1000),
img_path VARCHAR2(250),
status VARCHAR2(3) NOT NULL,
daily_fee INTEGER NOT NULL,
category_id INTEGER NOT NULL CONSTRAINT category_FK REFERENCES category(category_id) ON DELETE CASCADE,
manufacturer_id INTEGER NOT NULL CONSTRAINT manufacturer_FK REFERENCES manufacturer(manufacturer_id) ON DELETE CASCADE,
location_id INTEGER CONSTRAINT location_FK REFERENCES location(location_id) ON DELETE CASCADE
); 

CREATE SEQUENCE bike_id_seq;

CREATE OR REPLACE TRIGGER bike_id_incr
BEFORE INSERT ON bike
FOR EACH ROW
BEGIN
    SELECT bike_id_seq.nextval
    INTO :new.bike_id
    FROM DUAL;
END; 
/

--Row 1
INSERT INTO BIKE (PRODUCT, DESCRIPTION, CATEGORY_ID, STATUS, MANUFACTURER_ID, LOCATION_ID, DAILY_FEE, IMG_PATH) VALUES ('Performer 29','Modern technology providing a super smooth ride and top notch reliability. Chromoly frame and forks, sealed headset and bottom bracket, and 3-piece cranks allow this to be more than just a show bike and can be really ridden without worry. The Performer 29" is a worthy entry into GT''s Heritage line.',1,'in',5,1,40,'GT - Performer 29.png');
--Row 2
INSERT INTO BIKE (PRODUCT, DESCRIPTION, CATEGORY_ID, STATUS, MANUFACTURER_ID, LOCATION_ID, DAILY_FEE, IMG_PATH) VALUES ('Atroz 2','The Atroz 2 utilizes sealed cartridge bearings in an understated single-pivot design to deliver smooth, durable performance. The Atroz 2 ups the ante with Shimano hydraulic disc brakes, Suntour air-sprung rear suspension and an easy-to-operate single-ring drivetrain — features you usually find on bikes with a whole lot more dollar signs on their price tags.',3,'in',2,1,80,'Diamondback - Atroz2.png');
--Row 3
INSERT INTO BIKE (PRODUCT, DESCRIPTION, CATEGORY_ID, STATUS, MANUFACTURER_ID, LOCATION_ID, DAILY_FEE, IMG_PATH) VALUES ('Fastback Carbon 105', 'Designed for advanced to expert riders who want to go farther and faster on a bike built for superior performance.',2,'in',6,1,120, 'Schwinn - Fastback Carbon 105.png');
--Row 4
INSERT INTO BIKE (PRODUCT, DESCRIPTION, CATEGORY_ID, STATUS, MANUFACTURER_ID, LOCATION_ID, DAILY_FEE, IMG_PATH) VALUES ('Lux Trail CF 7','More suspension travel, longer and slacker geometry, wider tires: the Lux Trail CF 7 is everything a down country bike should be, with the perfect balance of fast climbing performance and descending capability.',3,'in',7,1,150,'Canyon - Lux Trail CF 7.png');
--Row 5
INSERT INTO BIKE (PRODUCT, DESCRIPTION, CATEGORY_ID, STATUS, MANUFACTURER_ID, LOCATION_ID, DAILY_FEE, IMG_PATH) VALUES ('AMA5183','Ancheer E-Bike, it weighs a mere 12KG/26.5lbs, making it a breeze to carry up to a flight of stairs. You can also leave it anywhere in your office. Convenient and saves space and our time, inspired by the shape of dolphins, also conform to young people''s pursuit of freedom and fashion.',10,'in',9,1,25,'Ancheer - AMA5183.png');
--Row 6
INSERT INTO BIKE (PRODUCT, DESCRIPTION, CATEGORY_ID, STATUS, MANUFACTURER_ID, LOCATION_ID, DAILY_FEE, IMG_PATH) VALUES ('Prince Force ETAP AXS 12S','A bicycle with technical characteristics and performance standards that outperform many high end Road bikes on the market today, and the reason that the PRINCE  is a real alternative to DOGMA F12. The Prince inherits the DOGMA F12 total cable integration system, called TiCR, which enables a significant aerodynamic advantage.',2,'in',11,1,175,'Pinarello - Prince Force ETAP AXS 12S.png');
--Row 7
INSERT INTO BIKE (PRODUCT, DESCRIPTION, CATEGORY_ID, STATUS, MANUFACTURER_ID, LOCATION_ID, DAILY_FEE, IMG_PATH) VALUES ('M-E1','The Montague M-E1 is the world''s first full-size performance foldable e-bike. A revolutionary new e-bike designed for both urban riding and trekking, the M-E1 is equipped with a Shimano Steps E6100 mid-drive motor and a Deore drivetrain, and folds in seconds with a single quick release.',10,'in',10,1,150,'Montague - M-E1.jpg');
--Row 8
INSERT INTO BIKE (PRODUCT, DESCRIPTION, CATEGORY_ID, STATUS, MANUFACTURER_ID, LOCATION_ID, DAILY_FEE, IMG_PATH) VALUES ('District 4 Equipped','District 4 Equipped is a hip and stylish high-end city bike designed for fun on cruises, commutes, and trips around town. It has a quiet, low-maintenance Gates CDX belt drive system with an 8-speed Shimano Alfine internal hub for smooth, crisp shifting.',6,'in',3,1,150,'District 4 Equipped.jpg');

--TABLE Creation

CREATE TABLE rental_bike (
rental_id INTEGER NOT NULL CONSTRAINT bike_rental_PK PRIMARY KEY,
member_id INTEGER NOT NULL CONSTRAINT member_id_FK REFERENCES customer(member_id) ON DELETE CASCADE,
bike_id INTEGER NOT NULL CONSTRAINT bike_fk REFERENCES bike(bike_id) ON DELETE CASCADE,
days_out INTEGER NOT NULL,
rented_out DATE NOT NULL
); 

CREATE SEQUENCE rental_id_seq;
CREATE SEQUENCE num_rentals_seq;

CREATE OR REPLACE TRIGGER update_bike_out
AFTER INSERT ON rental_bike
FOR EACH ROW
BEGIN
  UPDATE bike
  SET bike.status = 'out' WHERE bike.bike_id = :NEW.bike_id AND (SELECT num_rentals FROM customer WHERE member_id = :new.member_id) != 2;
  UPDATE customer
  SET customer.num_rentals = num_rentals_seq.nextval 
  WHERE member_id = :new.member_id;
END update_bike_out;
/

CREATE OR REPLACE TRIGGER rental_id_incr
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

CREATE  TABLE rental_detail (
detail_id INTEGER NOT NULL CONSTRAINT rental_detail_PK PRIMARY KEY,
rental_id INTEGER NOT NULL CONSTRAINT rental_id_FK REFERENCES rental_bike(rental_id) ON DELETE CASCADE,
exp_return DATE NOT NULL,
act_return DATE,
location_from INTEGER NOT NULL CONSTRAINT rented_from_FK REFERENCES location(location_id) ON DELETE CASCADE,
location_return INTEGER CONSTRAINT returned_FK REFERENCES location(location_id) ON DELETE CASCADE
); 

CREATE SEQUENCE detail_id_seq;

CREATE OR REPLACE TRIGGER detail_id_incr
BEFORE INSERT ON rental_detail
FOR EACH ROW
BEGIN
    SELECT detail_id_seq.nextval
    INTO :new.detail_id
    FROM DUAL;
END; 
/

COMMIT;

--INSERT INTO rental_bike
--(member_id, bike_id, rented_out)
--VALUES(1, 3, (TO_DATE('09-19-2022', 'MM-DD-YYYY')));
--ROLLBACK;
--WORKING UPDATE
--UPDATE  customer SET customer.unpaid_balance = (SELECT unpaid_balance FROM customer WHERE customer.member_id = 1) + (80.00 * 3) WHERE customer.member_id = 1; 

--SELECT * FROM bike INNER JOIN category ON bike.category_id = category.category_id INNER JOIN manufacturer ON bike.manufacturer_id = manufacturer.manufacturer_id ORDER BY bike_id;

-- INSERT INTO rental_detail (rental_id, exp_return, location_from)

-- VALUES ((SELECT rental_bike.rental_id FROM rental_bike WHERE rental_bike.member_id = 1 AND rental_bike.rented_out = TO_DATE('13-NOV-22') AND rental_bike.bike_id = 4), ((SELECT rented_out FROM rental_bike WHERE rental_bike.member_id = 1 AND rental_bike.bike_id = 4 AND rented_out = TO_DATE('13-NOV-22'))+7), (SELECT bike.location_id FROM bike WHERE bike.bike_id = 4));

--SELECT daily_fee FROM bike;

--INSERT INTO rental_bike VALUES(1,1,1, TO_DATE('17-NOV-22', 'DD-MON-YYYY')); 

--working date selection
--SELECT TO_DATE('11-13-2022', 'MM-DD-YYYY') FROM dual;


--SELECT rented_out + 7 FROM rental_bike WHERE rental_bike.member_id = 1 AND rental_bike.bike_id = :3 AND TRUNC(rented_out) = TO_DATE('14-NOV-22', 'dd-MON-yy')

--UPDATE customer SET customer.num_rentals = ((SELECT num_rentals FROM customer WHERE customer.member_id =1) -1);

--SELECT rented_out + 7 FROM rental_bike WHERE rental_bike.member_id = 1 AND rental_bike.bike_id = 2 AND trunc(rented_out) = '15-NOV-2022';
--SELECT num_rentals, unpaid_balance FROM customer WHERE customer.member_id=1;

--WORKING join
--SELECT * FROM rental_detail
--INNER JOIN rental_bike
--ON rental_detail.rental_id = rental_bike.rental_id;


---WORKING rental_detail update for act_return
--UPDATE rental_detail SET act_return = TO_DATE('18-NOV-2022', 'dd-MON-YYYY') WHERE exp_return = (SELECT TRUNC(rented_out) FROM rental_bike WHERE bike_id = 2 AND member_id = 1) + (SELECT days_out FROM rental_bike WHERE bike_id = 2 AND member_id = 1);
--
---WORKING rental_detail update for location_return
--UPDATE rental_detail SET location_return = 3 WHERE exp_return = (SELECT TRUNC(rented_out) FROM rental_bike WHERE bike_id = 2 AND member_id =1) + (SELECT days_out FROM rental_bike WHERE bike_id = 2 AND member_id = 1);

--SELECT ((act_return - exp_return)*20) FROM rental_detail WHERE rental_id = (SELECT rental_id FROM rental_bike WHERE bike_id = 1 AND member_id =1 AND days_out = 1 AND rented_out = (SELECT exp_return -1 FROM rental_detail);

----Gets needed information for update trigger
--SELECT rental_detail.rental_id, rental_bike.member_id, rental_detail.exp_return, rental_detail.act_return
--FROM rental_detail 
--INNER JOIN rental_bike
--ON rental_detail.rental_id = rental_bike.rental_id;


-- --Needs WORK
-- CREATE OR REPLACE TRIGGER add_fine 
--   BEFORE UPDATE of unpaid_balance ON customer
--   FOR EACH ROW
--   DECLARE
--   late_fine CONSTANT NUMBER(6,2):= 20.00
--   CURSOR rental_detail_cur IS

--   SELECT rental_detail.rental_id, rental_bike.member_id, rental_detail.exp_return, rental_detail.act_return
--   FROM rental_detail 
--   INNER JOIN rental_bike
--   ON rental_detail.rental_id = rental_bike.rental_id;
 
--   rental_detail rental_detail_cur%ROWTYPE;
--   BEGIN
--   IF :new.approved = 'Y' THEN
--    :new.create_dt := SYSDATE;
--   END IF;
--   END;
--   /

CREATE OR REPLACE TRIGGER Rental_Insert_Trigger
AFTER INSERT ON rental_bike
FOR EACH ROW
DECLARE
    expected_return rental_bike.rented_out%TYPE;
    

    CURSOR RentalCursor IS
    SELECT *
    FROM rental_bike
    WHERE rental_bike.member_id = :new.member_id;

    RentalRow RentalCursor%ROWTYPE;

    CURSOR BikeCursor IS
    SELECT *
    FROM bike
    WHERE bike.bike_id = :new.bike_id;
    
    BikeRow BikeCursor%ROWTYPE;

BEGIN
    SELECT TRUNC(rented_out) + days_out 
    INTO expected_return
    FROM rental_bike
    WHERE rental_bike.member_id = RentalRow.member_id;

    INSERT INTO rental_detail (rental_id, exp_return, location_from) VALUES (RentalRow.rental_id, expected_return, (SELECT bike.location_id FROM bike WHERE bike.bike_id = RentalRow.bike_id));
    
    

    UPDATE Customer
    SET num_rentals = (SELECT customer.num_rentals FROM customer WHERE customer.member_id = RentalRow.member_id) + 1;

    CLOSE RentalCursor;
    CLOSE BikeCursor;
END; 
/