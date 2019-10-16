-- drop view if exists s

drop view if exists  customer_list;
drop view if exists  film_list;
drop view if exists  nicer_but_slower_film_list;
drop view if exists  sales_by_film_category;
drop view if exists  sales_by_store;
drop view if exists  staff_list;

-- drop table  if exists s


drop table  if exists  payment cascade;
drop table  if exists  rental cascade;
drop table  if exists  inventory cascade;
drop table  if exists  film_category cascade;
drop table  if exists  film_actor cascade;
drop table  if exists  film cascade;
drop table  if exists  language cascade;
drop table  if exists  customer cascade;
drop table  if exists  actor cascade;
drop table  if exists  category cascade;
drop table  if exists  store cascade;
drop table  if exists  address cascade;
drop table  if exists  staff cascade;
drop table  if exists  city cascade;
drop table  if exists  country cascade;

--procedures

drop function  if exists  film_in_stock(integer, integer);
drop function  if exists  film_not_in_stock(integer, integer);
drop function  if exists  get_customer_balance(integer, timestamp without time zone);
drop function  if exists  inventory_held_by_customer(integer);
drop function  if exists  inventory_in_stock(integer);
drop function  if exists  last_day(timestamp without time zone);
drop function  if exists  rewards_report(integer, numeric);
drop function  if exists  last_updated();
drop function  if exists  _group_concat(text, text) cascade;

-- drop sequence  if exists s
drop sequence  if exists  actor_actor_id_seq;
drop sequence  if exists  address_address_id_seq;
drop sequence  if exists  category_category_id_seq;
drop sequence  if exists  city_city_id_seq;
drop sequence  if exists  country_country_id_seq;
drop sequence  if exists  customer_customer_id_seq;
drop sequence  if exists  film_film_id_seq;
drop sequence  if exists  inventory_inventory_id_seq;
drop sequence  if exists  language_language_id_seq;
drop sequence  if exists  payment_payment_id_seq;
drop sequence  if exists  rental_rental_id_seq;
drop sequence  if exists  staff_staff_id_seq;
drop sequence  if exists  store_store_id_seq;


--- drop types
drop type if exists mpaa_rating;


--- drop domains
drop domain if exists year;