CREATE TABLE actor (
  actor_id    INTEGER IDENTITY (1, 1),
  first_name  CHARACTER VARYING(45)                     NOT NULL,
  last_name   CHARACTER VARYING(45)                     NOT NULL,
  last_update TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (actor_id)
);


CREATE TABLE category (
  category_id INTEGER IDENTITY (1, 1),
  name        CHARACTER VARYING(25)                     NOT NULL,
  last_update TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (category_id)
);


CREATE TABLE film (
  film_id              INTEGER IDENTITY (1, 1),
  title                CHARACTER VARYING(255)                    NOT NULL,
  description          TEXT,
  release_year         INTEGER,
  language_id          SMALLINT                                  NOT NULL,
  original_language_id SMALLINT,
  rental_duration      SMALLINT DEFAULT 3                        NOT NULL,
  rental_rate          NUMERIC(4, 2) DEFAULT 4.99                NOT NULL,
  length               SMALLINT,
  replacement_cost     NUMERIC(5, 2) DEFAULT 19.99               NOT NULL,
  rating               CHARACTER VARYING(5) DEFAULT 'G',
  last_update          TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (film_id)
);


CREATE TABLE film_actor (
  actor_id    SMALLINT                                  NOT NULL,
  film_id     SMALLINT                                  NOT NULL,
  last_update TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (actor_id, film_id)
);


CREATE TABLE film_category (
  film_id     SMALLINT                                  NOT NULL,
  category_id SMALLINT                                  NOT NULL,
  last_update TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (film_id, category_id)
);


CREATE TABLE address (
  address_id  INTEGER IDENTITY (1, 1),
  address     CHARACTER VARYING(50)                     NOT NULL,
  address2    CHARACTER VARYING(50),
  district    CHARACTER VARYING(20)                     NOT NULL,
  city_id     SMALLINT                                  NOT NULL,
  postal_code CHARACTER VARYING(10),
  phone       CHARACTER VARYING(20)                     NOT NULL,
  last_update TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (address_id)
);


CREATE TABLE city (
  city_id     INTEGER IDENTITY (1, 1),
  city        CHARACTER VARYING(50)                     NOT NULL,
  country_id  SMALLINT                                  NOT NULL,
  last_update TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (city_id)
);


CREATE TABLE country (
  country_id  INTEGER IDENTITY (1, 1),
  country     CHARACTER VARYING(50)                     NOT NULL,
  last_update TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (country_id)
);


CREATE TABLE customer (
  customer_id INTEGER IDENTITY (1, 1),
  store_id    SMALLINT                             NOT NULL,
  first_name  CHARACTER VARYING(45)                NOT NULL,
  last_name   CHARACTER VARYING(45)                NOT NULL,
  email       CHARACTER VARYING(50),
  address_id  SMALLINT                             NOT NULL,
  activebool  BOOLEAN DEFAULT TRUE                 NOT NULL,
  create_date DATE DEFAULT ('now' :: TEXT) :: DATE NOT NULL,
  last_update TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
  active      INTEGER,
  PRIMARY KEY (customer_id)
);


CREATE TABLE inventory (
  inventory_id INTEGER IDENTITY (1, 1),
  film_id      SMALLINT                                  NOT NULL,
  store_id     SMALLINT                                  NOT NULL,
  last_update  TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (inventory_id)
);


CREATE TABLE language (
  language_id INTEGER IDENTITY (1, 1),
  name        CHARACTER(20)                             NOT NULL,
  last_update TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (language_id)
);


CREATE TABLE payment (
  payment_id   INTEGER IDENTITY (1, 1),
  customer_id  SMALLINT                    NOT NULL,
  staff_id     SMALLINT                    NOT NULL,
  rental_id    INTEGER                     NOT NULL,
  amount       NUMERIC(5, 2)               NOT NULL,
  payment_date TIMESTAMP WITHOUT TIME ZONE NOT NULL,
  PRIMARY KEY (payment_id)
);


CREATE TABLE rental (
  rental_id    INTEGER IDENTITY (1, 1),
  rental_date  TIMESTAMP WITHOUT TIME ZONE               NOT NULL,
  inventory_id INTEGER                                   NOT NULL,
  customer_id  SMALLINT                                  NOT NULL,
  return_date  TIMESTAMP WITHOUT TIME ZONE,
  staff_id     SMALLINT                                  NOT NULL,
  last_update  TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (rental_id)
);


CREATE TABLE staff (
  staff_id    INTEGER IDENTITY (1, 1),
  first_name  CHARACTER VARYING(45)                     NOT NULL,
  last_name   CHARACTER VARYING(45)                     NOT NULL,
  address_id  SMALLINT                                  NOT NULL,
  email       CHARACTER VARYING(50),
  store_id    SMALLINT                                  NOT NULL,
  active      BOOLEAN DEFAULT TRUE                      NOT NULL,
  username    CHARACTER VARYING(16)                     NOT NULL,
  password    CHARACTER VARYING(40),
  last_update TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (staff_id)
);


CREATE TABLE store (
  store_id         INTEGER IDENTITY (1, 1),
  manager_staff_id SMALLINT                                  NOT NULL,
  address_id       SMALLINT                                  NOT NULL,
  last_update      TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (store_id)
);

CREATE FUNCTION group_concat(TEXT, TEXT)
  RETURNS TEXT
AS $_$
SELECT CASE
       WHEN $2 IS NULL
         THEN $1
       WHEN $1 IS NULL
         THEN $2
       ELSE $1 || ', ' || $2
       END
$_$
LANGUAGE SQL IMMUTABLE;


CREATE VIEW customer_list AS
  SELECT
    cu.customer_id                                                       AS id,
    (((cu.first_name) :: TEXT || ' ' :: TEXT) || (cu.last_name) :: TEXT) AS name,
    a.address,
    a.postal_code                                                        AS "zip code",
    a.phone,
    city.city,
    country.country,
    CASE WHEN cu.activebool
      THEN 'active' :: TEXT
    ELSE '' :: TEXT END                                                  AS notes,
    cu.store_id                                                          AS sid
  FROM (((customer cu
    JOIN address a ON ((cu.address_id = a.address_id))) JOIN city ON ((a.city_id = city.city_id))) JOIN country
      ON ((city.country_id = country.country_id)));


CREATE VIEW sales_by_film_category AS
  SELECT
    c.name        AS category,
    sum(p.amount) AS total_sales
  FROM (((((payment p
    JOIN rental r ON ((p.rental_id = r.rental_id))) JOIN inventory i ON ((r.inventory_id = i.inventory_id))) JOIN
    film f ON ((i.film_id = f.film_id))) JOIN film_category fc ON ((f.film_id = fc.film_id))) JOIN category c
      ON ((fc.category_id = c.category_id)))
  GROUP BY c.name
  ORDER BY sum(p.amount) DESC;


CREATE VIEW sales_by_store AS
  SELECT
    (((c.city) :: TEXT || ',' :: TEXT) || (cy.country) :: TEXT)        AS store,
    (((m.first_name) :: TEXT || ' ' :: TEXT) || (m.last_name) :: TEXT) AS manager,
    sum(p.amount)                                                      AS total_sales
  FROM (((((((payment p
    JOIN rental r ON ((p.rental_id = r.rental_id))) JOIN inventory i ON ((r.inventory_id = i.inventory_id))) JOIN
    store s ON ((i.store_id = s.store_id))) JOIN address a ON ((s.address_id = a.address_id))) JOIN city c
      ON ((a.city_id = c.city_id))) JOIN country cy ON ((c.country_id = cy.country_id))) JOIN staff m
      ON ((s.manager_staff_id = m.staff_id)))
  GROUP BY cy.country, c.city, s.store_id, m.first_name, m.last_name
  ORDER BY cy.country, c.city;


CREATE VIEW staff_list AS
  SELECT
    s.staff_id                                                         AS id,
    (((s.first_name) :: TEXT || ' ' :: TEXT) || (s.last_name) :: TEXT) AS name,
    a.address,
    a.postal_code                                                      AS "zip code",
    a.phone,
    city.city,
    country.country,
    s.store_id                                                         AS sid
  FROM (((staff s
    JOIN address a ON ((s.address_id = a.address_id))) JOIN city ON ((a.city_id = city.city_id))) JOIN country
      ON ((city.country_id = country.country_id)));


ALTER TABLE address
  ADD CONSTRAINT address_city_id_fkey FOREIGN KEY (city_id) REFERENCES city (city_id);


ALTER TABLE city
  ADD CONSTRAINT city_country_id_fkey FOREIGN KEY (country_id) REFERENCES country (country_id);


ALTER TABLE customer
  ADD CONSTRAINT customer_address_id_fkey FOREIGN KEY (address_id) REFERENCES address (address_id);


ALTER TABLE customer
  ADD CONSTRAINT customer_store_id_fkey FOREIGN KEY (store_id) REFERENCES store (store_id);


ALTER TABLE film_actor
  ADD CONSTRAINT film_actor_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES actor (actor_id);


ALTER TABLE film_actor
  ADD CONSTRAINT film_actor_film_id_fkey FOREIGN KEY (film_id) REFERENCES film (film_id);


ALTER TABLE film_category
  ADD CONSTRAINT film_category_category_id_fkey FOREIGN KEY (category_id) REFERENCES CATEGORY (category_id);


ALTER TABLE film_category
  ADD CONSTRAINT film_category_film_id_fkey FOREIGN KEY (film_id) REFERENCES film (film_id);


ALTER TABLE film
  ADD CONSTRAINT film_language_id_fkey FOREIGN KEY (language_id) REFERENCES LANGUAGE (language_id);


ALTER TABLE film
  ADD CONSTRAINT film_original_language_id_fkey FOREIGN KEY (original_language_id) REFERENCES LANGUAGE (language_id);


ALTER TABLE inventory
  ADD CONSTRAINT inventory_film_id_fkey FOREIGN KEY (film_id) REFERENCES film (film_id);


ALTER TABLE inventory
  ADD CONSTRAINT inventory_store_id_fkey FOREIGN KEY (store_id) REFERENCES store (store_id);


ALTER TABLE payment
  ADD CONSTRAINT payment_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES customer (customer_id);

ALTER TABLE payment
  ADD CONSTRAINT payment_rental_id_fkey FOREIGN KEY (rental_id) REFERENCES rental (rental_id);


ALTER TABLE payment
  ADD CONSTRAINT payment_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES staff (staff_id);


ALTER TABLE rental
  ADD CONSTRAINT rental_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES customer (customer_id);


ALTER TABLE rental
  ADD CONSTRAINT rental_inventory_id_fkey FOREIGN KEY (inventory_id) REFERENCES inventory (inventory_id);


ALTER TABLE rental
  ADD CONSTRAINT rental_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES staff (staff_id);


ALTER TABLE staff
  ADD CONSTRAINT staff_address_id_fkey FOREIGN KEY (address_id) REFERENCES address (address_id);


ALTER TABLE staff
  ADD CONSTRAINT staff_store_id_fkey FOREIGN KEY (store_id) REFERENCES store (store_id);


ALTER TABLE store
  ADD CONSTRAINT store_address_id_fkey FOREIGN KEY (address_id) REFERENCES address (address_id);


ALTER TABLE store
  ADD CONSTRAINT store_manager_staff_id_fkey FOREIGN KEY (manager_staff_id) REFERENCES staff (staff_id);
