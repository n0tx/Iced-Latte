--liquibase formatted sql
--changeset n0tx:add-category-to-product

-- add new column 'category'
ALTER TABLE product ADD COLUMN category VARCHAR(100);

-- set existing product category to 'Coffee'
UPDATE product SET category = 'Coffee' WHERE category IS NULL;

