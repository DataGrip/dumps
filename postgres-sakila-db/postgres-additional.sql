-- creating additional database objects

-- view with rules
create table view_with_rules_t1
(
  ctr         smallint    not null /*primary key*/,
  ctr_name    varchar(26) not null /*unique*/,
  ctr_capital int
);

create table view_with_rules_t2
(
  ctr            smallint    not null /*references country*/,
  cty            integer     not null,
  cty_name       varchar(26) not null /*unique*/,
  cty_is_capital boolean
);

create or replace view view_with_rules
  as
    select ctr,
           ctr_name,
           cty,
           cty_name
    from view_with_rules_t1
      natural join view_with_rules_t2
    where cty_is_capital;

create rule rule_for_view as
on insert to view_with_rules
do instead (
  insert into view_with_rules_t1 (ctr , ctr_name , ctr_capital)
  values (new.ctr, new.ctr_name, new.cty);
  insert into view_with_rules_t2 (ctr , cty , cty_name , cty_is_capital)
  values (new.ctr, new.cty, new.cty_name, true)
);

insert into view_with_rules
values (3, 'Liechtenstein', 1, 'Vaduz');

-- user mapping
create foreign data wrapper dummy;

create server srv1
  foreign data wrapper dummy;

create user mapping for public
  server srv1
options (host 'localhost', port '54325');

-- types
create type my_complex as
(
  re double precision,
  im double precision
);

create type person_name as
(
  first  varchar(25),
  middle varchar(36),
  last   varchar(40)
);

create type punkt as (x int, y int);

create type kleinkreis as (zenter punkt, radius int);
create type weg as (punkte punkt [], zeit time);

-- enums
create type sex as enum ('female', 'male');

create type mood as enum ('sad', 'ok', 'happy', 'ecstatic');

create type literas as enum ('A', 'Ä', 'a', 'Ё', 'ё', 'ß');

-- trigger event
DROP EVENT TRIGGER IF EXISTS abort_ddl CASCADE;

CREATE OR REPLACE FUNCTION abort_any_command()
  RETURNS event_trigger
LANGUAGE plpgsql
AS $$
BEGIN
  --   RAISE EXCEPTION 'command % is disabled', tg_tag;
END;
$$;

CREATE EVENT TRIGGER abort_ddl
ON ddl_command_start
EXECUTE PROCEDURE abort_any_command();

alter event trigger abort_ddl
rename to abort_dll_renamed;

-- table type
CREATE TYPE employee_type AS (name text, salary numeric);

CREATE TABLE employees OF employee_type (
  PRIMARY KEY (name),
  salary WITH OPTIONS DEFAULT 1000
);

-- table like
create table rich_table (
  a int primary key,
  b int default 33,
  c int unique
);

comment on table rich_table
is 'table comment';

comment on column rich_table.c
is 'column comment';

create table like_table2 (like rich_table including all
);

-- inheritance
create table Table_A
(
  A_Id int
);

create table Table_B
(
  B_Id int
)
  inherits (Table_A);

create table Table_C
(
  C_Id int
)
  inherits (Table_A);

create table Table_D
(
  D_Id int
)
  inherits (Table_B, Table_C);

-- table types 9.X
create table table_with_column_of_many_types
(
  boolean                  boolean,
  bool                     bool,
  bit                      bit,
  bit_35                   bit(35),
  bit_varying_70           bit varying(70),
  bit_varying              bit varying,
  varbit                   varbit,
  smallint                 smallint,
  integer                  integer,
  int                      int,
  int2                     int2,
  int4                     int4,
  int8                     int8,
  bigint                   bigint,
  numeric                  numeric,
  numeric_40               numeric(40),
  numeric_45_15            numeric(45, 15),
  real                     real,
  float4                   float4,
  double_precision         double precision,
  float8                   float8,
  money                    money,
  _char_                   "char",
  char                     char,
  char_3                   char(3),
  varchar_80               varchar(80),
  "character varying"      character varying,
  "character varying(40)"  character varying(40),
  name                     name,
  bytea                    bytea,
  date                     date,
  time                     time,
  time_with_time_zone      time with time zone,
  timestamp                timestamp,
  timestamp_with_time_zone timestamp with time zone,
  "time(6)"                time(6),
  interval                 interval,
  point                    point,
  line                     line,
  lseg                     lseg,
  box                      box,
  path                     path,
  polygon                  polygon,
  circle                   circle,
  cidr                     cidr,
  inet                     inet,
  macaddr                  macaddr,
  uuid                     uuid,
  xml                      xml,
  bigserial                bigserial,
  smallserial              smallserial,
  serial2                  serial2,
  serial4                  serial4,
  serial8                  serial8,
  json                     json,
  jsonb                    jsonb,
  pg_lsn                   pg_lsn,
  text                     text,
  tsquery                  tsquery,
  tsvector                 tsvector,
  txid_snapshot            txid_snapshot
);

-- partition table pg10 only
create table inventory (
  id  int not null,
  id1 int default 1,
  dt  date
)
  partition by range (dt);

create table p1
  partition of inventory for values from ('2000-11-11') to ('2001-11-11')
  partition by range (id);
create table p2
  partition of inventory(dt not null) for values from ('2001-11-11') to ('2002-11-11');
create table p3
  partition of inventory(id default 1) for values from ('2002-11-11') to ('2003-11-11');
create table p4
  partition of inventory(id primary key) for values from ('2003-11-11') to ('2004-11-11');
create table p11
  partition of p1 for values from (1) to (10);

-- operator
create or replace function add_suffix_if_not_exists(str varchar, suffix varchar)
  returns varchar as
$$begin
  if str like '%' || suffix
  then return str;
  else return str || suffix;
  end if;
end;$$
language plpgsql
immutable;

create operator @@+ (
  procedure = add_suffix_if_not_exists, leftarg = varchar, rightarg = varchar);

create or replace function near(a int, b int)
  returns boolean as
$$begin
  return a = b or a = b + 1 or b = a + 1;
end;$$
language plpgsql
immutable;

create operator ~~~ (
  procedure = near, leftarg = int, rightarg = int );

create or replace function to_string_with_plus(val int)
  returns varchar as
$$begin
  if val > 0
  then return '+' || val :: varchar;
  else return val :: varchar;
  end if;
end;$$
language plpgsql
immutable;

create operator <+> (
  procedure = to_string_with_plus, rightarg = int );


create or replace function quote_it(s varchar)
  returns varchar as
$$begin
  if s is not null
  then return '"' || s || '"';
  else return null;
  end if;
end;$$
language plpgsql
immutable;

create operator !!! (
  procedure = quote_it, leftarg = varchar );

-- materialized view
create table taba
(
  id     int primary key,
  phrase varchar(25)
);

create materialized view matv
  as
    select *
    from taba;

create unique index matv_id_ui
  on matv (id);

create index matv_phrase_i
  on matv (phrase);

-- conditional index
create table My_Table
(
  N1 bigint,
  N2 bigint,
  N3 bigint
);

create index My_Table_Index_1
  on My_Table (N1);

create index My_Table_Index_2
  on My_Table (N2)
  where N2 > 0;

create index My_Table_Index_3
  on My_Table (N3)
  where N2 < 0;

create index My_Table_Index_4
  on My_Table (N1 asc, N2 desc)
  where N1 * (N2 + N3) < 1000;

create table My_Insane_Table
(
  "CREATE" varchar(10),
  "INDEX"  varchar(10),
  "USING"  varchar(10),
  "WHERE"  varchar(10),
  "X"      varchar(10)
);

create index My_Insane_Table_Index_1
  on My_Insane_Table ("CREATE", "INDEX", "USING", "WHERE", "X")
  where "USING" < ("WHERE" || "X");

-- function with defaults
create function param_def_516_1(p1 int default 1, p2 varchar(10) default 'some text')
  returns int as
$body$
begin
  return p1 + length(p2);
end;
$body$
language plpgsql;

-- function with return type table
create function function_044()
  returns table(x int) language sql as 'select 44';

-- foreign table
create foreign table "my foreign table"
(
  id int
)
server srv1
options (my_opt '1');

-- foreign server
create server srv2
  type 'my_type'
  version '1'
  foreign data wrapper dummy
options (my_option1 '1', my_option2 '2');

-- extension
DROP EXTENSION IF EXISTS hstore CASCADE;
CREATE EXTENSION hstore;

-- domains
create domain person_dob as date
  constraint person_dob_possible_date_1_ch check (value >= date '1900-01-01')
  constraint person_dob_possible_date_2_ch check (value <= date '2099-12-31');

-- cascade rules
create table master

(
  id int not null constraint master_pk primary key
);

create table refer
(
  ref1 int constraint ref1 references master,
  ref2 int constraint ref2 references master
    deferrable,
  ref3 int constraint ref3 references master
    deferrable initially deferred,
  ref4 int constraint ref4 references master on update cascade on delete cascade,
  ref5 int constraint ref5 references master on update set null on delete set null,
  ref6 int constraint ref6 references master on update restrict,
  ref7 int constraint ref7 references master on update restrict deferrable,
  ref8 int constraint ref8 references master on update restrict deferrable initially deferred,
  ref9 int default 9 constraint ref9 references master on delete set default
);

-- aggregate
create function _group_concat(a text, b text)
  returns text
as $_$
select case
             when b is null
         then a
             when a is null
         then b
           else a || ', ' || b
           end
$_$
language sql
immutable;

create function mf(a text, b text)
  returns text
as $_$
begin
  return 'c';
end;
$_$
language plpgsql;

create function mvf(a text, b text)
  returns text
as $_$
begin
  return 'a';
end;
$_$
language plpgsql;

create function mff(a text, b text)
  returns text
as $_$
begin
  return 'b';
end;
$_$
language plpgsql;

create function _group_concat(a text)
  returns text
as $$
begin
  return a;
end;
$$
language plpgsql;

create function final(a text, b text, c text)
  returns text
as $$
begin
  return a;
end
$$
language plpgsql;

create function final(a text, b text)
  returns text
as $$
begin
  return a;
end
$$
language plpgsql;

create aggregate group_concat2(a text) (
  sfunc = _group_concat,
  stype = text,
  sspace = 112,
  finalfunc = final,
  finalfunc_extra,
  initcond = 'a',
  msfunc = mf,
  minvfunc = mvf,
  mstype = text,
  msspace = 113,
  mfinalfunc = mff,
  mfinalfunc_extra,
  minitcond = 3,
  sortop = operator (<)
);
