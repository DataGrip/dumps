-- Sakila Sample Database Schema
-- Version 0.8

-- Copyright (c) 2006, MySQL AB
-- All rights reserved.

-- Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

--  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
--  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
--  * Neither the name of MySQL AB nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

--
-- Table structure for table `actor`
--

CREATE TABLE SAKILA.actor (
  actor_id SMALLINT NOT NULL AUTO_INCREMENT,
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY  (actor_id)
);

--
-- Table structure for table `address`
--

CREATE TABLE SAKILA.address (
  address_id SMALLINT NOT NULL AUTO_INCREMENT,
  address VARCHAR(50) NOT NULL,
  address2 VARCHAR(50) DEFAULT NULL,
  district VARCHAR(20) NOT NULL,
  city_id SMALLINT NOT NULL,
  postal_code VARCHAR(10) DEFAULT NULL,
  phone VARCHAR(20) NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY  (address_id)
);

--
-- Table structure for table `category`
--

CREATE TABLE SAKILA.category (
  category_id TINYINT NOT NULL AUTO_INCREMENT,
  name VARCHAR(25) NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY  (category_id)
);


--
-- Table structure for table `country`
--

CREATE TABLE SAKILA.country (
  country_id SMALLINT NOT NULL AUTO_INCREMENT,
  country VARCHAR(50) NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY  (country_id)
);

--
-- Table structure for table `city`
--

CREATE TABLE SAKILA.city (
  city_id SMALLINT NOT NULL AUTO_INCREMENT,
  city VARCHAR(50) NOT NULL,
  country_id SMALLINT NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY  (city_id),
  CONSTRAINT `fk_city_country` FOREIGN KEY (country_id) REFERENCES SAKILA.country (country_id)
);

--
-- Table structure for table `staff`
--

CREATE TABLE SAKILA.staff (
  staff_id TINYINT NOT NULL AUTO_INCREMENT,
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  address_id SMALLINT NOT NULL,
  picture BLOB DEFAULT NULL,
  email VARCHAR(50) DEFAULT NULL,
  store_id TINYINT NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  username VARCHAR(16) NOT NULL,
  password VARCHAR(40) DEFAULT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY  (staff_id),
  CONSTRAINT fk_staff_address FOREIGN KEY (address_id) REFERENCES SAKILA.address (address_id) 
);

--
-- Table structure for table `store`
--

CREATE TABLE SAKILA.store (
  store_id TINYINT NOT NULL AUTO_INCREMENT,
  manager_staff_id TINYINT NOT NULL,
  address_id SMALLINT NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  PRIMARY KEY  (store_id),
  CONSTRAINT fk_store_staff FOREIGN KEY (manager_staff_id) REFERENCES SAKILA.staff (staff_id) ,
  CONSTRAINT fk_store_address FOREIGN KEY (address_id) REFERENCES SAKILA.address (address_id) 
);

--
-- Table structure for table `customer`
--

CREATE TABLE SAKILA.customer (
  customer_id SMALLINT NOT NULL AUTO_INCREMENT,
  store_id TINYINT NOT NULL,
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  email VARCHAR(50) DEFAULT NULL,
  address_id SMALLINT NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  create_date DATETIME NOT NULL,
  last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY  (customer_id),
  CONSTRAINT fk_customer_address FOREIGN KEY (address_id) REFERENCES SAKILA.address (address_id),
  CONSTRAINT fk_customer_store FOREIGN KEY (store_id) REFERENCES SAKILA.store (store_id)
);

--
-- Table structure for table `language`
--

CREATE TABLE SAKILA.language (
  language_id TINYINT NOT NULL AUTO_INCREMENT,
  name CHAR(20) NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  PRIMARY KEY (language_id)
);

--
-- Table structure for table `film`
--

CREATE TABLE SAKILA.film (
  film_id SMALLINT NOT NULL AUTO_INCREMENT,
  title VARCHAR(255) NOT NULL,
  description TEXT DEFAULT NULL,
  release_year YEAR DEFAULT NULL,
  language_id TINYINT NOT NULL,
  original_language_id TINYINT DEFAULT NULL,
  rental_duration TINYINT NOT NULL DEFAULT 3,
  rental_rate DECIMAL(4,2) NOT NULL DEFAULT 4.99,
  length SMALLINT DEFAULT NULL,
  replacement_cost DECIMAL(5,2) NOT NULL DEFAULT 19.99,
  rating CHAR(5) DEFAULT 'G',
  special_features VARCHAR(255) DEFAULT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  PRIMARY KEY  (film_id),
  CONSTRAINT fk_film_language FOREIGN KEY (language_id) REFERENCES SAKILA.language (language_id) ,
  CONSTRAINT fk_film_language_original FOREIGN KEY (original_language_id) REFERENCES SAKILA.language (language_id) 
);

--
-- Table structure for table `film_actor`
--

CREATE TABLE SAKILA.film_actor (
  actor_id SMALLINT NOT NULL,
  film_id SMALLINT NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  PRIMARY KEY  (actor_id,film_id),
  CONSTRAINT fk_film_actor_actor FOREIGN KEY (actor_id) REFERENCES SAKILA.actor (actor_id) ,
  CONSTRAINT fk_film_actor_film FOREIGN KEY (film_id) REFERENCES SAKILA.film (film_id) 
);

--
-- Table structure for table `film_category`
--

CREATE TABLE SAKILA.film_category (
  film_id SMALLINT NOT NULL,
  category_id TINYINT NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  PRIMARY KEY (film_id, category_id),
  CONSTRAINT fk_film_category_film FOREIGN KEY (film_id) REFERENCES SAKILA.film (film_id) ,
  CONSTRAINT fk_film_category_category FOREIGN KEY (category_id) REFERENCES SAKILA.category (category_id) 
);

--
-- Table structure for table `film_text`
--

CREATE TABLE SAKILA.film_text (
  film_id SMALLINT NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  PRIMARY KEY  (film_id),
);

--
-- Table structure for table `inventory`
--

CREATE TABLE SAKILA.inventory (
  inventory_id MEDIUMINT NOT NULL AUTO_INCREMENT,
  film_id SMALLINT NOT NULL,
  store_id TINYINT NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  PRIMARY KEY  (inventory_id),
  CONSTRAINT fk_inventory_store FOREIGN KEY (store_id) REFERENCES SAKILA.store (store_id) ,
  CONSTRAINT fk_inventory_film FOREIGN KEY (film_id) REFERENCES SAKILA.film (film_id) 
);

--
-- Table structure for table `rental`
--

CREATE TABLE SAKILA.rental (
  rental_id INT NOT NULL AUTO_INCREMENT,
  rental_date DATETIME NOT NULL,
  inventory_id MEDIUMINT NOT NULL,
  customer_id SMALLINT NOT NULL,
  return_date DATETIME DEFAULT NULL,
  staff_id TINYINT NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  PRIMARY KEY (rental_id),
  --UNIQUE KEY  (rental_date,inventory_id,customer_id),
  CONSTRAINT fk_rental_staff FOREIGN KEY (staff_id) REFERENCES staff (staff_id) ,
  CONSTRAINT fk_rental_inventory FOREIGN KEY (inventory_id) REFERENCES SAKILA.inventory (inventory_id) ,
  CONSTRAINT fk_rental_customer FOREIGN KEY (customer_id) REFERENCES SAKILA.customer (customer_id) 
);

--
-- Table structure for table `payment`
--

CREATE TABLE SAKILA.payment (
  payment_id SMALLINT NOT NULL AUTO_INCREMENT,
  customer_id SMALLINT NOT NULL,
  staff_id TINYINT NOT NULL,
  rental_id INT DEFAULT NULL,
  amount DECIMAL(5,2) NOT NULL,
  payment_date DATETIME NOT NULL,
  last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP ,
  PRIMARY KEY  (payment_id),
  CONSTRAINT fk_payment_rental FOREIGN KEY (rental_id) REFERENCES SAKILA.rental (rental_id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_payment_customer FOREIGN KEY (customer_id) REFERENCES SAKILA.customer (customer_id) ,
  CONSTRAINT fk_payment_staff FOREIGN KEY (staff_id) REFERENCES SAKILA.staff (staff_id) 
);




--
-- View structure for view `customer_list`
--

CREATE VIEW SAKILA.customer_list
AS
SELECT cu.customer_id AS ID, CONCAT(cu.first_name, ' ', cu.last_name) AS name, a.address AS address, a.postal_code AS `zip_code`,
	a.phone AS phone, city.city AS city, country.country AS country, cu.active AS notes, cu.store_id AS SID
FROM SAKILA.customer AS cu
JOIN SAKILA.address AS a ON cu.address_id = a.address_id 
JOIN SAKILA.city ON a.city_id = city.city_id
JOIN SAKILA.country ON city.country_id = country.country_id
;

--
-- View structure for view `film_list`
--

CREATE VIEW SAKILA.film_list
AS
SELECT SAKILA.film.film_id AS FID,
       SAKILA.film.title AS title,
	   SAKILA.film.description AS description,
	   SAKILA.category.name AS category,
	   SAKILA.film.rental_rate AS price,
	   SAKILA.film.length AS length,
	   SAKILA.film.rating AS rating,
	   GROUP_CONCAT(CONCAT(SAKILA.actor.first_name, ' ', SAKILA.actor.last_name) SEPARATOR ', ') AS actors
FROM SAKILA.category 
LEFT JOIN SAKILA.film_category ON SAKILA.category.category_id = SAKILA.film_category.category_id 
LEFT JOIN SAKILA.film ON SAKILA.film_category.film_id = SAKILA.film.film_id
JOIN SAKILA.film_actor ON SAKILA.film.film_id = SAKILA.film_actor.film_id
JOIN SAKILA.actor ON SAKILA.film_actor.actor_id = SAKILA.actor.actor_id
GROUP BY SAKILA.film.film_id
;

--
-- View structure for view `nicer_but_slower_film_list`
--

CREATE VIEW SAKILA.nicer_but_slower_film_list
AS
SELECT SAKILA.film.film_id AS FID,
 SAKILA.film.title AS title,
 SAKILA.film.description AS description,
 SAKILA.category.name AS category,
 SAKILA.film.rental_rate AS price,
 SAKILA.film.length AS length,
 SAKILA.film.rating AS rating
FROM SAKILA.category
    LEFT JOIN SAKILA.film_category ON SAKILA.category.category_id = SAKILA.film_category.category_id 
	LEFT JOIN SAKILA.film ON SAKILA.film_category.film_id = SAKILA.film.film_id
         JOIN SAKILA.film_actor ON SAKILA.film.film_id = SAKILA.film_actor.film_id
     	 JOIN SAKILA.actor ON SAKILA.film_actor.actor_id = SAKILA.actor.actor_id
GROUP BY SAKILA.film.film_id
;

--
-- View structure for view `staff_list`
--

CREATE VIEW SAKILA.staff_list
AS
SELECT s.staff_id AS ID, CONCAT(s.first_name, ' ', s.last_name) AS name, a.address AS address, a.postal_code AS `zip_code`, a.phone AS phone,
	city.city AS city, country.country AS country, s.store_id AS SID
FROM SAKILA.staff AS s 
JOIN SAKILA.address AS a ON s.address_id = a.address_id
JOIN SAKILA.city ON a.city_id = city.city_id
JOIN SAKILA.country ON SAKILA.city.country_id = SAKILA.country.country_id
;

--
-- View structure for view `sales_by_store`
--

CREATE VIEW SAKILA.sales_by_store
AS
SELECT
CONCAT(c.city, ',', cy.country) AS store
, CONCAT(m.first_name, ' ', m.last_name) AS manager
, SUM(p.amount) AS total_sales
FROM SAKILA.payment AS p
INNER JOIN SAKILA.rental AS r ON p.rental_id = r.rental_id
INNER JOIN SAKILA.inventory AS i ON r.inventory_id = i.inventory_id
INNER JOIN SAKILA.store AS s ON i.store_id = s.store_id
INNER JOIN SAKILA.address AS a ON s.address_id = a.address_id
INNER JOIN SAKILA.city AS c ON a.city_id = c.city_id
INNER JOIN SAKILA.country AS cy ON c.country_id = cy.country_id
INNER JOIN SAKILA.staff AS m ON s.manager_staff_id = m.staff_id
GROUP BY s.store_id
ORDER BY cy.country, c.city
;

--
-- View structure for view `sales_by_film_category`
--
-- Note that total sales will add up to >100% because
-- some titles belong to more than 1 category
--

CREATE VIEW SAKILA.sales_by_film_category
AS
SELECT
c.name AS category
, SUM(p.amount) AS total_sales
FROM SAKILA.payment AS p
INNER JOIN SAKILA.rental AS r ON p.rental_id = r.rental_id
INNER JOIN SAKILA.inventory AS i ON r.inventory_id = i.inventory_id
INNER JOIN SAKILA.film AS f ON i.film_id = f.film_id
INNER JOIN SAKILA.film_category AS fc ON f.film_id = fc.film_id
INNER JOIN SAKILA.category AS c ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY total_sales DESC
;

--
-- View structure for view `actor_info`
--

CREATE VIEW SAKILA.actor_info
AS
SELECT
a.actor_id,
a.first_name,
a.last_name,
GROUP_CONCAT(DISTINCT CONCAT(c.name, ': ',
		(SELECT GROUP_CONCAT(f.title ORDER BY f.title SEPARATOR ', ')
                    FROM SAKILA.film f
                    INNER JOIN SAKILA.film_category fc ON f.film_id = fc.film_id
                    INNER JOIN SAKILA.film_actor fa    ON f.film_id = fa.film_id
                    WHERE fc.category_id = c.category_id
                    AND fa.actor_id = a.actor_id
                 )
             )
             ORDER BY c.name SEPARATOR '; ')
AS film_info
FROM SAKILA.actor a
LEFT JOIN SAKILA.film_actor fa  ON a.actor_id = fa.actor_id
LEFT JOIN SAKILA.film_category fc  ON fa.film_id = fc.film_id
LEFT JOIN SAKILA.category c  ON fc.category_id = c.category_id
GROUP BY a.actor_id, a.first_name, a.last_name
;

