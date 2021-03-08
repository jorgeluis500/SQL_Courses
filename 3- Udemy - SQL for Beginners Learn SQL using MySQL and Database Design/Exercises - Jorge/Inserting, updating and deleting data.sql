-- INSERTING, UPDATING AND DELETING DATA FROM TABLES

USE coffe_store;

SELECT * FROM products;

-- INSERTING VALUES

INSERT INTO products(name, price,coffe_origin)
VALUES('Expresso', 2.50, 'Brazil');

-- You can enter more than one row at a time

INSERT INTO 
products(name, price,coffe_origin)
VALUES	('Macchiato', 3.00, 'Brazil'),
		('Cappuccino', 3.50, 'Costa Rica');
        
INSERT INTO 
products(name, price, coffe_origin)
VALUES	('Latte', 3.50, 'Indonesia'),
		('Americano', 3.00, 'Brazil'),
        ('Flat White', 3.50, 'Indonesia'),
        ('Filter', 3.00, 'India');
        
-- UPDATING VALUES

UPDATE products
SET name = 'Expresso'
WHERE name = 'Expreso';
-- This query didn't work becasue I was in safe mode. I can't modify a row using a WHERE clasue without a key in safe mode

UPDATE products
SET name = 'Expresso'
WHERE id = 1;
-- This worked

UPDATE products
SET coffe_origin = 'Sri Lanka'
WHERE id = 7;

-- One way to turn off the safe mode is to go to Edit -> Preferences - SQL Editor, uncheck the option and reconnect
-- The other one is:

SET SQL_SAFE_UPDATES=0;

SELECT * FROM products;

-- Updating multiple columns in one statement, no safe mode
UPDATE products
SET coffe_origin = 'Ethiopia', price= 3.25
WHERE name = 'Americano';
-- Be careful and make sure the attribute Americano in this case to be unique

-- Updating multiple rows in one statement
UPDATE products
SET coffe_origin = 'Colombia'
WHERE coffe_origin = 'Brazil';

-- DELETING VALUES

-- I will create a new table with sample values first

CREATE TABLE people_t (
id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(30),
age INT,
gender ENUM('M','F')
);

INSERT INTO people_t (name, age, gender)
			VALUES ('Emma', 21, 'F'),
					('John', 30, 'M'),
                    ('Thomas', 27, 'M'),
                    ('Chris', 44, 'M'),
                    ('Sally', 23, 'F'),
                    ('Frank', 55, 'M')
;
SELECT * FROM people_t;

DELETE FROM people_t
WHERE name = 'John';
-- The second row is deleted. The id becomes 1, 3, 4 etc

DELETE FROM people_t
WHERE gender = 'F';
-- All the rows with gender = F are deleted

DELETE FROM people_t;
-- Deletes all the records in the table

-- Deleting the table
DROP TABLE people_t;