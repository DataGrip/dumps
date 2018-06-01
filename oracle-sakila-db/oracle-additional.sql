-- additional database objects
-- checks
create table Simple_Table_with_Checks
(
  A number(9) check (A between 13 and 42),
  B number(9),
  C number(9),
  M1 number(9) not null,
  M2 number(9),
  constraint Simple_Table_with_Checks_BC_ch
  check (B > 2 or C > 3),
  constraint Simple_Table_with_Checks_M2_nn
  check (M2 is not null)
)
/

CREATE TABLE divisions  (
  div_no    NUMBER  CONSTRAINT check_divno
  CHECK (div_no BETWEEN 10 AND 99)
  DISABLE,
  div_name  VARCHAR2(9)  CONSTRAINT check_divname
  CHECK (div_name = UPPER(div_name))
  DISABLE,
  office    VARCHAR2(10)  CONSTRAINT check_office
  CHECK (office IN ('DALLAS','BOSTON',
                    'PARIS','TOKYO'))
  DISABLE
)
/

-- hash cluster
create cluster STREETS
(
  ID number(4)
)
  single table hashkeys 101
/

create table STREET
(
  ID number(4) not null,
  NAME varchar(40) not null
)
cluster STREETS (ID)
/

-- materialized view
create table my_basic_table
(
  code char(2) primary key,
  note varchar(1000)
)
/

create materialized view my_basic_materialized_view as
  select *
  from my_basic_table
/

-- package
create package SIMPLE_PACK2 as
  procedure PL (MSG string);
  pragma restrict_references (PL, rnds, wnds);
end SIMPLE_PACK2;
/

create package body SIMPLE_PACK2 as
  procedure PL (MSG string) is
    begin
      SYS.DBMS_OUTPUT.put_line(MSG);
    end;
end SIMPLE_PACK2;
/

create package SIMPLE_PACK as
  procedure PL (MSG string);
  pragma restrict_references (PL, rnds, wnds);

    my_exc EXCEPTION;
  my_const CONSTANT BINARY_INTEGER := 1;
  my_var NUMBER := -20001;
  TYPE my_collection IS TABLE OF BLOB NOT NULL;
  TYPE my_collection2 IS varray (2) OF BLOB NOT NULL;
  TYPE my_record IS RECORD(x NUMBER, y NUMBER);
  TYPE my_cursor IS REF CURSOR;
  TYPE my_cursor2 IS REF CURSOR return my_record;
  SUBTYPE my_subtype IS number not null;
end SIMPLE_PACK;
/

-- sequence
create sequence sequence_with_many_parameters
  minvalue 110
  increment by 10
  maxvalue 9999
  cycle
  cache 200
/

-- synonym
create table SIMPLE_SIMPLE_TABLE
(
  C1 char(1)
)
/

create view SIMPLE_SIMPLE_VIEW
  as
    select *
    from SIMPLE_SIMPLE_TABLE
/

create synonym JUST_TABLE for SIMPLE_SIMPLE_TABLE
/

create synonym JUST_VIEW for SIMPLE_SIMPLE_VIEW
/

-- temporary table
create global temporary table Ephemera_1
(
  X number(9)
)
on commit delete rows
/

create global temporary table Ephemera_2
(
  Y number(9)
)
on commit preserve rows
/

-- trigger
create table T1 (
  Id number(9) not null primary key,
  Name varchar(26),
  Kind char,
  Modified_Timestamp date default sysdate
)
/

create trigger T1_kind_tr
  before update on T1
  for each row
  when (old.Id != new.id and old.Kind is not null)
  begin
    raise_application_error(-20001, 'Interdit!');
  end;
/

-- type
CREATE TYPE data_type_alter AS OBJECT(
  year NUMBER,
MEMBER FUNCTION prod(invent NUMBER) RETURN NUMBER
)
/

CREATE TYPE BODY data_type_alter IS
  MEMBER FUNCTION prod (invent NUMBER) RETURN NUMBER IS
    BEGIN
      RETURN (year + invent);
    END;
END;
/

create type words as varray(100) of varchar(30)
/

CREATE TYPE textdoc_typ AS OBJECT
( document_typ      VARCHAR2(32)
  , formatted_doc     BLOB
)
/

CREATE OR REPLACE TYPE textdoc_tab AS TABLE OF textdoc_typ;
/

-- view
create view View_From_Dual
  as
    select sysdate as now,
           sys_context('USERENV','SESSIONID') as sessionid,
           dump(dummy) as dump_of_dummy
    from dual
  with read only
/
