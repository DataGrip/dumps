set client_encoding = 'utf8';
set standard_conforming_strings = off;
set check_function_bodies = false;
set client_min_messages = warning;
set escape_string_warning = off;

create or replace procedural language plpgsql;

create sequence actor_actor_id_seq
    increment by 1
    no maxvalue
    no minvalue
    cache 1;

set default_tablespace = '';

set default_with_oids = false;

create table actor (
    actor_id integer default nextval('actor_actor_id_seq'::regclass) not null,
    first_name character varying(45) not null,
    last_name character varying(45) not null,
    last_update timestamp without time zone default now() not null
);

create type mpaa_rating as enum (
    'G',
    'PG',
    'PG-13',
    'R',
    'NC-17'
);

create domain year as integer
	constraint year_check check (((value >= 1901) and (value <= 2155)));

create function _group_concat(text, text) returns text
    as $_$
select case
  when $2 is null then $1
  when $1 is null then $2
  else $1 || ', ' || $2
end
$_$
    language sql immutable;


create aggregate group_concat(text) (
    sfunc = _group_concat,
    stype = text
);

create sequence category_category_id_seq
    increment by 1
    no maxvalue
    no minvalue
    cache 1;

create table category (
    category_id integer default nextval('category_category_id_seq'::regclass) not null,
    name character varying(25) not null,
    last_update timestamp without time zone default now() not null
);

create sequence film_film_id_seq
    increment by 1
    no maxvalue
    no minvalue
    cache 1;

create table film (
    film_id integer default nextval('film_film_id_seq'::regclass) not null,
    title character varying(255) not null,
    description text,
    release_year year,
    language_id smallint not null,
    original_language_id smallint,
    rental_duration smallint default 3 not null,
    rental_rate numeric(4,2) default 4.99 not null,
    length smallint,
    replacement_cost numeric(5,2) default 19.99 not null,
    rating mpaa_rating default 'G'::mpaa_rating,
    last_update timestamp without time zone default now() not null,
    special_features text[],
    fulltext tsvector not null
);

create table film_actor (
    actor_id smallint not null,
    film_id smallint not null,
    last_update timestamp without time zone default now() not null
);

create table film_category (
    film_id smallint not null,
    category_id smallint not null,
    last_update timestamp without time zone default now() not null
);

create view actor_info as
    select a.actor_id, a.first_name, a.last_name, group_concat(distinct (((c.name)::text || ': '::text) || (select group_concat((f.title)::text) as group_concat from ((film f join film_category fc on ((f.film_id = fc.film_id))) join film_actor fa on ((f.film_id = fa.film_id))) where ((fc.category_id = c.category_id) and (fa.actor_id = a.actor_id)) group by fa.actor_id))) as film_info from (((actor a left join film_actor fa on ((a.actor_id = fa.actor_id))) left join film_category fc on ((fa.film_id = fc.film_id))) left join category c on ((fc.category_id = c.category_id))) group by a.actor_id, a.first_name, a.last_name;

create sequence address_address_id_seq
    increment by 1
    no maxvalue
    no minvalue
    cache 1;

create table address (
    address_id integer default nextval('address_address_id_seq'::regclass) not null,
    address character varying(50) not null,
    address2 character varying(50),
    district character varying(20) not null,
    city_id smallint not null,
    postal_code character varying(10),
    phone character varying(20) not null,
    last_update timestamp without time zone default now() not null
);

create sequence city_city_id_seq
    increment by 1
    no maxvalue
    no minvalue
    cache 1;

create table city (
    city_id integer default nextval('city_city_id_seq'::regclass) not null,
    city character varying(50) not null,
    country_id smallint not null,
    last_update timestamp without time zone default now() not null
);

create sequence country_country_id_seq
    increment by 1
    no maxvalue
    no minvalue
    cache 1;

create table country (
    country_id integer default nextval('country_country_id_seq'::regclass) not null,
    country character varying(50) not null,
    last_update timestamp without time zone default now() not null
);

create sequence customer_customer_id_seq
    increment by 1
    no maxvalue
    no minvalue
    cache 1;

create table customer (
    customer_id integer default nextval('customer_customer_id_seq'::regclass) not null,
    store_id smallint not null,
    first_name character varying(45) not null,
    last_name character varying(45) not null,
    email character varying(50),
    address_id smallint not null,
    activebool boolean default true not null,
    create_date date default ('now'::text)::date not null,
    last_update timestamp without time zone default now(),
    active integer
);

create view customer_list as
    select cu.customer_id as id, (((cu.first_name)::text || ' '::text) || (cu.last_name)::text) as name, a.address, a.postal_code as "zip code", a.phone, city.city, country.country, case when cu.activebool then 'active'::text else ''::text end as notes, cu.store_id as sid from (((customer cu join address a on ((cu.address_id = a.address_id))) join city on ((a.city_id = city.city_id))) join country on ((city.country_id = country.country_id)));

create view film_list as
    select film.film_id as fid, film.title, film.description, category.name as category, film.rental_rate as price, film.length, film.rating, group_concat((((actor.first_name)::text || ' '::text) || (actor.last_name)::text)) as actors from ((((category left join film_category on ((category.category_id = film_category.category_id))) left join film on ((film_category.film_id = film.film_id))) join film_actor on ((film.film_id = film_actor.film_id))) join actor on ((film_actor.actor_id = actor.actor_id))) group by film.film_id, film.title, film.description, category.name, film.rental_rate, film.length, film.rating;

create sequence inventory_inventory_id_seq
    increment by 1
    no maxvalue
    no minvalue
    cache 1;

create table inventory (
    inventory_id integer default nextval('inventory_inventory_id_seq'::regclass) not null,
    film_id smallint not null,
    store_id smallint not null,
    last_update timestamp without time zone default now() not null
);

create sequence language_language_id_seq
    increment by 1
    no maxvalue
    no minvalue
    cache 1;

create table language (
    language_id integer default nextval('language_language_id_seq'::regclass) not null,
    name character(20) not null,
    last_update timestamp without time zone default now() not null
);

create view nicer_but_slower_film_list as
    select film.film_id as fid, film.title, film.description, category.name as category, film.rental_rate as price, film.length, film.rating, group_concat((((upper("substring"((actor.first_name)::text, 1, 1)) || lower("substring"((actor.first_name)::text, 2))) || upper("substring"((actor.last_name)::text, 1, 1))) || lower("substring"((actor.last_name)::text, 2)))) as actors from ((((category left join film_category on ((category.category_id = film_category.category_id))) left join film on ((film_category.film_id = film.film_id))) join film_actor on ((film.film_id = film_actor.film_id))) join actor on ((film_actor.actor_id = actor.actor_id))) group by film.film_id, film.title, film.description, category.name, film.rental_rate, film.length, film.rating;

create sequence payment_payment_id_seq
    increment by 1
    no maxvalue
    no minvalue
    cache 1;

create table payment (
    payment_id integer default nextval('payment_payment_id_seq'::regclass) not null,
    customer_id smallint not null,
    staff_id smallint not null,
    rental_id integer not null,
    amount numeric(5,2) not null,
    payment_date timestamp without time zone not null
);

create table payment_p2007_01 (constraint payment_p2007_01_payment_date_check check (((payment_date >= '2007-01-01 00:00:00'::timestamp without time zone) and (payment_date < '2007-02-01 00:00:00'::timestamp without time zone)))
)
inherits (payment);

create table payment_p2007_02 (constraint payment_p2007_02_payment_date_check check (((payment_date >= '2007-02-01 00:00:00'::timestamp without time zone) and (payment_date < '2007-03-01 00:00:00'::timestamp without time zone)))
)
inherits (payment);

create table payment_p2007_03 (constraint payment_p2007_03_payment_date_check check (((payment_date >= '2007-03-01 00:00:00'::timestamp without time zone) and (payment_date < '2007-04-01 00:00:00'::timestamp without time zone)))
)
inherits (payment);

create table payment_p2007_04 (constraint payment_p2007_04_payment_date_check check (((payment_date >= '2007-04-01 00:00:00'::timestamp without time zone) and (payment_date < '2007-05-01 00:00:00'::timestamp without time zone)))
)
inherits (payment);

create table payment_p2007_05 (constraint payment_p2007_05_payment_date_check check (((payment_date >= '2007-05-01 00:00:00'::timestamp without time zone) and (payment_date < '2007-06-01 00:00:00'::timestamp without time zone)))
)
inherits (payment);

create table payment_p2007_06 (constraint payment_p2007_06_payment_date_check check (((payment_date >= '2007-06-01 00:00:00'::timestamp without time zone) and (payment_date < '2007-07-01 00:00:00'::timestamp without time zone)))
)
inherits (payment);

create sequence rental_rental_id_seq
    increment by 1
    no maxvalue
    no minvalue
    cache 1;

create table rental (
    rental_id integer default nextval('rental_rental_id_seq'::regclass) not null,
    rental_date timestamp without time zone not null,
    inventory_id integer not null,
    customer_id smallint not null,
    return_date timestamp without time zone,
    staff_id smallint not null,
    last_update timestamp without time zone default now() not null
);

create view sales_by_film_category as
    select c.name as category, sum(p.amount) as total_sales from (((((payment p join rental r on ((p.rental_id = r.rental_id))) join inventory i on ((r.inventory_id = i.inventory_id))) join film f on ((i.film_id = f.film_id))) join film_category fc on ((f.film_id = fc.film_id))) join category c on ((fc.category_id = c.category_id))) group by c.name order by sum(p.amount) desc;

create sequence staff_staff_id_seq
    increment by 1
    no maxvalue
    no minvalue
    cache 1;

create table staff (
    staff_id integer default nextval('staff_staff_id_seq'::regclass) not null,
    first_name character varying(45) not null,
    last_name character varying(45) not null,
    address_id smallint not null,
    email character varying(50),
    store_id smallint not null,
    active boolean default true not null,
    username character varying(16) not null,
    password character varying(40),
    last_update timestamp without time zone default now() not null,
    picture bytea
);

create sequence store_store_id_seq
    increment by 1
    no maxvalue
    no minvalue
    cache 1;

create table store (
    store_id integer default nextval('store_store_id_seq'::regclass) not null,
    manager_staff_id smallint not null,
    address_id smallint not null,
    last_update timestamp without time zone default now() not null
);

create view sales_by_store as
    select (((c.city)::text || ','::text) || (cy.country)::text) as store, (((m.first_name)::text || ' '::text) || (m.last_name)::text) as manager, sum(p.amount) as total_sales from (((((((payment p join rental r on ((p.rental_id = r.rental_id))) join inventory i on ((r.inventory_id = i.inventory_id))) join store s on ((i.store_id = s.store_id))) join address a on ((s.address_id = a.address_id))) join city c on ((a.city_id = c.city_id))) join country cy on ((c.country_id = cy.country_id))) join staff m on ((s.manager_staff_id = m.staff_id))) group by cy.country, c.city, s.store_id, m.first_name, m.last_name order by cy.country, c.city;

create view staff_list as
    select s.staff_id as id, (((s.first_name)::text || ' '::text) || (s.last_name)::text) as name, a.address, a.postal_code as "zip code", a.phone, city.city, country.country, s.store_id as sid from (((staff s join address a on ((s.address_id = a.address_id))) join city on ((a.city_id = city.city_id))) join country on ((city.country_id = country.country_id)));


create function film_in_stock(p_film_id integer, p_store_id integer, out p_film_count integer) returns setof integer
    as $_$
     select inventory_id
     from inventory
     where film_id = $1
     and store_id = $2
     and inventory_in_stock(inventory_id);
$_$
    language sql;


create function film_not_in_stock(p_film_id integer, p_store_id integer, out p_film_count integer) returns setof integer
    as $_$
    select inventory_id
    from inventory
    where film_id = $1
    and store_id = $2
    and not inventory_in_stock(inventory_id);
$_$
    language sql;

create function get_customer_balance(p_customer_id integer, p_effective_date timestamp without time zone) returns numeric
    as $$
       --#ok, we need to calculate the current balance given a customer_id and a date
       --#that we want the balance to be effective for. the balance is:
       --#   1) rental fees for all previous rentals
       --#   2) one dollar for every day the previous rentals are overdue
       --#   3) if a film is more than rental_duration * 2 overdue, charge the replacement_cost
       --#   4) subtract all payments made before the date specified
declare
    v_rentfees decimal(5,2); --#fees paid to rent the videos initially
    v_overfees integer;      --#late fees for prior rentals
    v_payments decimal(5,2); --#sum of payments made previously
begin
    select coalesce(sum(film.rental_rate),0) into v_rentfees
    from film, inventory, rental
    where film.film_id = inventory.film_id
      and inventory.inventory_id = rental.inventory_id
      and rental.rental_date <= p_effective_date
      and rental.customer_id = p_customer_id;

    select coalesce(sum(if((rental.return_date - rental.rental_date) > (film.rental_duration * '1 day'::interval),
        ((rental.return_date - rental.rental_date) - (film.rental_duration * '1 day'::interval)),0)),0) into v_overfees
    from rental, inventory, film
    where film.film_id = inventory.film_id
      and inventory.inventory_id = rental.inventory_id
      and rental.rental_date <= p_effective_date
      and rental.customer_id = p_customer_id;

    select coalesce(sum(payment.amount),0) into v_payments
    from payment
    where payment.payment_date <= p_effective_date
    and payment.customer_id = p_customer_id;

    return v_rentfees + v_overfees - v_payments;
end
$$
    language plpgsql;
create function inventory_held_by_customer(p_inventory_id integer) returns integer
    as $$
declare
    v_customer_id integer;
begin
  select customer_id into v_customer_id
  from rental
  where return_date is null
  and inventory_id = p_inventory_id;
  return v_customer_id;
end $$
    language plpgsql;


create function inventory_in_stock(p_inventory_id integer) returns boolean
    as $$
declare
    v_rentals integer;
    v_out     integer;
begin
    -- an item is in-stock if there are either no rows in the rental table
    -- for the item or all rows have return_date populated

    select count(*) into v_rentals
    from rental
    where inventory_id = p_inventory_id;

    if v_rentals = 0 then
      return true;
    end if;

    select count(rental_id) into v_out
    from inventory left join rental using(inventory_id)
    where inventory.inventory_id = p_inventory_id
    and rental.return_date is null;

    if v_out > 0 then
      return false;
    else
      return true;
    end if;
end $$
    language plpgsql;


create function last_day(timestamp without time zone) returns date
    as $_$
  select case
    when extract(month from $1) = 12 then
      (((extract(year from $1) + 1) operator(pg_catalog.||) '-01-01')::date - interval '1 day')::date
    else
      ((extract(year from $1) operator(pg_catalog.||) '-' operator(pg_catalog.||) (extract(month from $1) + 1) operator(pg_catalog.||) '-01')::date - interval '1 day')::date
    end
$_$
    language sql immutable strict;



create function last_updated() returns trigger
    as $$
begin
    new.last_update = current_timestamp;
    return new;
end $$
    language plpgsql;

create function rewards_report(min_monthly_purchases integer, min_dollar_amount_purchased numeric) returns setof customer
    as $_$
declare
    last_month_start date;
    last_month_end date;
rr record;
tmpsql text;
begin

    /* some sanity checks... */
    if min_monthly_purchases = 0 then
        raise exception 'minimum monthly purchases parameter must be > 0';
    end if;
    if min_dollar_amount_purchased = 0.00 then
        raise exception 'minimum monthly dollar amount purchased parameter must be > $0.00';
    end if;

    last_month_start := current_date - '3 month'::interval;
    last_month_start := to_date((extract(year from last_month_start) || '-' || extract(month from last_month_start) || '-01'),'yyyy-mm-dd');
    last_month_end := last_day(last_month_start);

    /*
    create a temporary storage area for customer ids.
    */
    create temporary table tmpcustomer (customer_id integer not null primary key);

    /*
    find all customers meeting the monthly purchase requirements
    */

    tmpsql := 'insert into tmpcustomer (customer_id)
        select p.customer_id
        from payment as p
        where date(p.payment_date) between '||quote_literal(last_month_start) ||' and '|| quote_literal(last_month_end) || '
        group by customer_id
        having sum(p.amount) > '|| min_dollar_amount_purchased || '
        and count(customer_id) > ' ||min_monthly_purchases ;

    execute tmpsql;

    /*
    output all customer information of matching rewardees.
    customize output as needed.
    */
    for rr in execute 'select c.* from tmpcustomer as t inner join customer as c on t.customer_id = c.customer_id' loop
        return next rr;
    end loop;

    /* clean up */
    tmpsql := 'drop table tmpcustomer';
    execute tmpsql;

return;
end
$_$
    language plpgsql security definer;

alter table only actor
    add constraint actor_pkey primary key (actor_id);

alter table only address
    add constraint address_pkey primary key (address_id);

alter table only category
    add constraint category_pkey primary key (category_id);

alter table only city
    add constraint city_pkey primary key (city_id);

alter table only country
    add constraint country_pkey primary key (country_id);

alter table only customer
    add constraint customer_pkey primary key (customer_id);

alter table only film_actor
    add constraint film_actor_pkey primary key (actor_id, film_id);

alter table only film_category
    add constraint film_category_pkey primary key (film_id, category_id);

alter table only film
    add constraint film_pkey primary key (film_id);

alter table only inventory
    add constraint inventory_pkey primary key (inventory_id);

alter table only language
    add constraint language_pkey primary key (language_id);

alter table only payment
    add constraint payment_pkey primary key (payment_id);

alter table only rental
    add constraint rental_pkey primary key (rental_id);

alter table only staff
    add constraint staff_pkey primary key (staff_id);

alter table only store
    add constraint store_pkey primary key (store_id);

create index film_fulltext_idx on film using gist (fulltext);

create index idx_actor_last_name on actor using btree (last_name);

create index idx_fk_address_id on customer using btree (address_id);

create index idx_fk_city_id on address using btree (city_id);

create index idx_fk_country_id on city using btree (country_id);

create index idx_fk_customer_id on payment using btree (customer_id);

create index idx_fk_film_id on film_actor using btree (film_id);

create index idx_fk_inventory_id on rental using btree (inventory_id);

create index idx_fk_language_id on film using btree (language_id);

create index idx_fk_original_language_id on film using btree (original_language_id);

create index idx_fk_payment_p2007_01_customer_id on payment_p2007_01 using btree (customer_id);

create index idx_fk_payment_p2007_01_staff_id on payment_p2007_01 using btree (staff_id);

create index idx_fk_payment_p2007_02_customer_id on payment_p2007_02 using btree (customer_id);

create index idx_fk_payment_p2007_02_staff_id on payment_p2007_02 using btree (staff_id);

create index idx_fk_payment_p2007_03_customer_id on payment_p2007_03 using btree (customer_id);

create index idx_fk_payment_p2007_03_staff_id on payment_p2007_03 using btree (staff_id);

create index idx_fk_payment_p2007_04_customer_id on payment_p2007_04 using btree (customer_id);

create index idx_fk_payment_p2007_04_staff_id on payment_p2007_04 using btree (staff_id);

create index idx_fk_payment_p2007_05_customer_id on payment_p2007_05 using btree (customer_id);

create index idx_fk_payment_p2007_05_staff_id on payment_p2007_05 using btree (staff_id);

create index idx_fk_payment_p2007_06_customer_id on payment_p2007_06 using btree (customer_id);

create index idx_fk_payment_p2007_06_staff_id on payment_p2007_06 using btree (staff_id);

create index idx_fk_staff_id on payment using btree (staff_id);

create index idx_fk_store_id on customer using btree (store_id);

create index idx_last_name on customer using btree (last_name);

create index idx_store_id_film_id on inventory using btree (store_id, film_id);

create index idx_title on film using btree (title);

create unique index idx_unq_manager_staff_id on store using btree (manager_staff_id);

create unique index idx_unq_rental_rental_date_inventory_id_customer_id on rental using btree (rental_date, inventory_id, customer_id);

create rule payment_insert_p2007_01 as on insert to payment where ((new.payment_date >= '2007-01-01 00:00:00'::timestamp without time zone) and (new.payment_date < '2007-02-01 00:00:00'::timestamp without time zone)) do instead insert into payment_p2007_01 (payment_id, customer_id, staff_id, rental_id, amount, payment_date) values (default, new.customer_id, new.staff_id, new.rental_id, new.amount, new.payment_date);

create rule payment_insert_p2007_02 as on insert to payment where ((new.payment_date >= '2007-02-01 00:00:00'::timestamp without time zone) and (new.payment_date < '2007-03-01 00:00:00'::timestamp without time zone)) do instead insert into payment_p2007_02 (payment_id, customer_id, staff_id, rental_id, amount, payment_date) values (default, new.customer_id, new.staff_id, new.rental_id, new.amount, new.payment_date);

create rule payment_insert_p2007_03 as on insert to payment where ((new.payment_date >= '2007-03-01 00:00:00'::timestamp without time zone) and (new.payment_date < '2007-04-01 00:00:00'::timestamp without time zone)) do instead insert into payment_p2007_03 (payment_id, customer_id, staff_id, rental_id, amount, payment_date) values (default, new.customer_id, new.staff_id, new.rental_id, new.amount, new.payment_date);

create rule payment_insert_p2007_04 as on insert to payment where ((new.payment_date >= '2007-04-01 00:00:00'::timestamp without time zone) and (new.payment_date < '2007-05-01 00:00:00'::timestamp without time zone)) do instead insert into payment_p2007_04 (payment_id, customer_id, staff_id, rental_id, amount, payment_date) values (default, new.customer_id, new.staff_id, new.rental_id, new.amount, new.payment_date);

create rule payment_insert_p2007_05 as on insert to payment where ((new.payment_date >= '2007-05-01 00:00:00'::timestamp without time zone) and (new.payment_date < '2007-06-01 00:00:00'::timestamp without time zone)) do instead insert into payment_p2007_05 (payment_id, customer_id, staff_id, rental_id, amount, payment_date) values (default, new.customer_id, new.staff_id, new.rental_id, new.amount, new.payment_date);

create rule payment_insert_p2007_06 as on insert to payment where ((new.payment_date >= '2007-06-01 00:00:00'::timestamp without time zone) and (new.payment_date < '2007-07-01 00:00:00'::timestamp without time zone)) do instead insert into payment_p2007_06 (payment_id, customer_id, staff_id, rental_id, amount, payment_date) values (default, new.customer_id, new.staff_id, new.rental_id, new.amount, new.payment_date);

create trigger film_fulltext_trigger
    before insert or update on film
    for each row
    execute procedure tsvector_update_trigger('fulltext', 'pg_catalog.english', 'title', 'description');

create trigger last_updated
    before update on actor
    for each row
    execute procedure last_updated();

create trigger last_updated
    before update on address
    for each row
    execute procedure last_updated();

create trigger last_updated
    before update on category
    for each row
    execute procedure last_updated();

create trigger last_updated
    before update on city
    for each row
    execute procedure last_updated();

create trigger last_updated
    before update on country
    for each row
    execute procedure last_updated();

create trigger last_updated
    before update on customer
    for each row
    execute procedure last_updated();

create trigger last_updated
    before update on film
    for each row
    execute procedure last_updated();

create trigger last_updated
    before update on film_actor
    for each row
    execute procedure last_updated();

create trigger last_updated
    before update on film_category
    for each row
    execute procedure last_updated();

create trigger last_updated
    before update on inventory
    for each row
    execute procedure last_updated();

create trigger last_updated
    before update on language
    for each row
    execute procedure last_updated();

create trigger last_updated
    before update on rental
    for each row
    execute procedure last_updated();

create trigger last_updated
    before update on staff
    for each row
    execute procedure last_updated();

create trigger last_updated
    before update on store
    for each row
    execute procedure last_updated();

alter table only address
    add constraint address_city_id_fkey foreign key (city_id) references city(city_id) on update cascade on delete restrict;

alter table only city
    add constraint city_country_id_fkey foreign key (country_id) references country(country_id) on update cascade on delete restrict;

alter table only customer
    add constraint customer_address_id_fkey foreign key (address_id) references address(address_id) on update cascade on delete restrict;

alter table only customer
    add constraint customer_store_id_fkey foreign key (store_id) references store(store_id) on update cascade on delete restrict;

alter table only film_actor
    add constraint film_actor_actor_id_fkey foreign key (actor_id) references actor(actor_id) on update cascade on delete restrict;

alter table only film_actor
    add constraint film_actor_film_id_fkey foreign key (film_id) references film(film_id) on update cascade on delete restrict;

alter table only film_category
    add constraint film_category_category_id_fkey foreign key (category_id) references category(category_id) on update cascade on delete restrict;

alter table only film_category
    add constraint film_category_film_id_fkey foreign key (film_id) references film(film_id) on update cascade on delete restrict;

alter table only film
    add constraint film_language_id_fkey foreign key (language_id) references language(language_id) on update cascade on delete restrict;

alter table only film
    add constraint film_original_language_id_fkey foreign key (original_language_id) references language(language_id) on update cascade on delete restrict;

alter table only inventory
    add constraint inventory_film_id_fkey foreign key (film_id) references film(film_id) on update cascade on delete restrict;

alter table only inventory
    add constraint inventory_store_id_fkey foreign key (store_id) references store(store_id) on update cascade on delete restrict;

alter table only payment
    add constraint payment_customer_id_fkey foreign key (customer_id) references customer(customer_id) on update cascade on delete restrict;

alter table only payment_p2007_01
    add constraint payment_p2007_01_customer_id_fkey foreign key (customer_id) references customer(customer_id);

alter table only payment_p2007_01
    add constraint payment_p2007_01_rental_id_fkey foreign key (rental_id) references rental(rental_id);

alter table only payment_p2007_01
    add constraint payment_p2007_01_staff_id_fkey foreign key (staff_id) references staff(staff_id);

alter table only payment_p2007_02
    add constraint payment_p2007_02_customer_id_fkey foreign key (customer_id) references customer(customer_id);

alter table only payment_p2007_02
    add constraint payment_p2007_02_rental_id_fkey foreign key (rental_id) references rental(rental_id);

alter table only payment_p2007_02
    add constraint payment_p2007_02_staff_id_fkey foreign key (staff_id) references staff(staff_id);

alter table only payment_p2007_03
    add constraint payment_p2007_03_customer_id_fkey foreign key (customer_id) references customer(customer_id);

alter table only payment_p2007_03
    add constraint payment_p2007_03_rental_id_fkey foreign key (rental_id) references rental(rental_id);

alter table only payment_p2007_03
    add constraint payment_p2007_03_staff_id_fkey foreign key (staff_id) references staff(staff_id);

alter table only payment_p2007_04
    add constraint payment_p2007_04_customer_id_fkey foreign key (customer_id) references customer(customer_id);

alter table only payment_p2007_04
    add constraint payment_p2007_04_rental_id_fkey foreign key (rental_id) references rental(rental_id);

alter table only payment_p2007_04
    add constraint payment_p2007_04_staff_id_fkey foreign key (staff_id) references staff(staff_id);

alter table only payment_p2007_05
    add constraint payment_p2007_05_customer_id_fkey foreign key (customer_id) references customer(customer_id);

alter table only payment_p2007_05
    add constraint payment_p2007_05_rental_id_fkey foreign key (rental_id) references rental(rental_id);

alter table only payment_p2007_05
    add constraint payment_p2007_05_staff_id_fkey foreign key (staff_id) references staff(staff_id);

alter table only payment_p2007_06
    add constraint payment_p2007_06_customer_id_fkey foreign key (customer_id) references customer(customer_id);

alter table only payment_p2007_06
    add constraint payment_p2007_06_rental_id_fkey foreign key (rental_id) references rental(rental_id);

alter table only payment_p2007_06
    add constraint payment_p2007_06_staff_id_fkey foreign key (staff_id) references staff(staff_id);

alter table only payment
    add constraint payment_rental_id_fkey foreign key (rental_id) references rental(rental_id) on update cascade on delete set null;

alter table only payment
    add constraint payment_staff_id_fkey foreign key (staff_id) references staff(staff_id) on update cascade on delete restrict;

alter table only rental
    add constraint rental_customer_id_fkey foreign key (customer_id) references customer(customer_id) on update cascade on delete restrict;

alter table only rental
    add constraint rental_inventory_id_fkey foreign key (inventory_id) references inventory(inventory_id) on update cascade on delete restrict;

alter table only rental
    add constraint rental_staff_id_fkey foreign key (staff_id) references staff(staff_id) on update cascade on delete restrict;

alter table only staff
    add constraint staff_address_id_fkey foreign key (address_id) references address(address_id) on update cascade on delete restrict;

alter table only staff
    add constraint staff_store_id_fkey foreign key (store_id) references store(store_id);

alter table only store
    add constraint store_address_id_fkey foreign key (address_id) references address(address_id) on update cascade on delete restrict;

alter table only store
    add constraint store_manager_staff_id_fkey foreign key (manager_staff_id) references staff(staff_id) on update cascade on delete restrict;