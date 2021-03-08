-- Example of a database creation. 
-- By running the commands one by one, the effect can be observed

SHOW DATABASES;

CREATE DATABASE test;

USE test;

SHOW TABLES;

-- TABLES CREATION 
-- Usually the keys are assigned during this stage but here they will be added later

CREATE TABLE addresses (
id INT,
house_number INT,
city VARCHAR(30),
postcode VARCHAR(7)

);

CREATE TABLE people (
id INT,
first_name VARCHAR(20),
last_name VARCHAR(20),
address_id INT
);

CREATE TABLE pets (
id INT,
name VARCHAR(20),
species VARCHAR(20),
owner_id INT
);

SHOW TABLES;

DESCRIBE addresses;
-- Show the fields and the data types for the table

-- ADDING PRIMARY KEYS

ALTER TABLE addresses
ADD PRIMARY KEY (id);
-- When the primary key is added, Null contition changes to NO. It can't be null

ALTER TABLE addresses
DROP PRIMARY KEY;
-- When the Promary key is dropped, the Null condition doesn't change again. It stays as NO

DESCRIBE addresses;

SHOW TABLES;

DESCRIBE people;

ALTER TABLE people
ADD PRIMARY KEY (id);

-- ADDING FOREIGN KEYS

-- Primary key has to be addeed again to addresses table in order to execute the next statement
ALTER TABLE people
ADD CONSTRAINT FK_PeopleAddress
FOREIGN KEY (address_id) REFERENCES addresses(id);

ALTER TABLE people
DROP FOREIGN KEY FK_PeopleAddress;
-- For some reason the foreign key was not removed, even though the statement executed correctly
-- Answer: I needed to remove the constraint, like in the next step, usong DROP INDEX
ALTER TABLE people
DROP INDEX FK_PeopleAddress;

SELECT * FROM PETS;

-- ADDING UNIQUE CONSTRAINTS

ALTER TABLE pets
ADD CONSTRAINT u_species UNIQUE (species);

DESCRIBE pets;

-- REMOVING UNIQUE CONSTRAINTS. We need to use DROP INDEX

ALTER TABLE  pets
DROP INDEX u_species;

-- CHANGING COLUMNS NAMES

ALTER TABLE pets CHANGE `species` `pet_type` VARCHAR(20);
-- Changing the column name back
ALTER TABLE pets CHANGE `pet_type` `species` VARCHAR(20);

-- CHANGING COLUMN TYPES

ALTER TABLE addresses MODIFY city CHAR(25);
-- Chaging it back
ALTER TABLE addresses MODIFY city VARCHAR(30);
-- Be careful when you work with already populated tables

DESCRIBE addresses;