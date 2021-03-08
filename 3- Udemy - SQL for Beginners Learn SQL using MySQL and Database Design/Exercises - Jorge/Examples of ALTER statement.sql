SELECT * FROM products;

-- Add columns to a table
ALTER TABLE products
ADD COLUMN coffe_origin VARCHAR(30);

-- Remove columns from the table
ALTER TABLE products
DROP COLUMN coffe_origin;
