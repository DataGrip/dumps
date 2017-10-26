-- Drop Views

DROP VIEW customer_list;
DROP VIEW sales_by_film_category;
DROP VIEW sales_by_store;
DROP VIEW staff_list;

-- Drop Tables

DROP TABLE payment CASCADE;
DROP TABLE rental CASCADE;
DROP TABLE inventory CASCADE;
DROP TABLE film_category CASCADE;
DROP TABLE film_actor CASCADE;
DROP TABLE film CASCADE;
DROP TABLE language CASCADE;
DROP TABLE customer CASCADE;
DROP TABLE actor CASCADE;
DROP TABLE category CASCADE;
DROP TABLE store CASCADE;
DROP TABLE address CASCADE;
DROP TABLE staff CASCADE;
DROP TABLE city CASCADE;
DROP TABLE country CASCADE;

--Procedures

DROP FUNCTION group_concat(text, text) CASCADE;
