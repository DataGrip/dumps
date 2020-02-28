create PROCEDURE loopproc(inval NUMBER)
    IS
    tmpvar  NUMBER;
    tmpvar2 NUMBER;
    total   NUMBER;
BEGIN
    tmpvar := 0;
    tmpvar2 := 0;
    total := 0;
    FOR lcv IN 1 .. inval
        LOOP
            total := 2 * total + 1 - tmpvar2;
            tmpvar2 := tmpvar;
            tmpvar := total;
        END LOOP;
    DBMS_OUTPUT.put_line('TOTAL IS: ' || total);
END loopproc;;

create table T1
(
    Id                 number(9) not null primary key,
    Name               varchar(26),
    Kind               char,
    Modified_Timestamp date default sysdate
);

create trigger T1_KIND_TR
    before update
    on T1
    for each row
begin
    loopproc(5);
    raise_application_error(-20001, 'Interdit!');
end;;


insert into T1(id, name, kind)
values (1, 'name', '1');



declare
    value  number := 10;
    total  number := 0;
    output number := 0;
begin
    for i in 1 .. value
        loop
        --             PROC_WITH_PROC(i, output);
        --             PROC_WITH_FUNC(i);
        --             LOOPPROC(i);
            complex_data_types(i);
            total := total + i;
        end loop;
end;;

create or replace procedure complex_data_types(inval number)
    is
    tmpvar  number;
    tmpvar2 number;
    total   number;
    type int_arr is varray (3) of number;
    loopzz  int_arr;
    TYPE population_type IS TABLE OF NUMBER INDEX BY VARCHAR2 (64);
    country_population   population_type;
    howmany number;
begin
    tmpvar := 0;
    tmpvar2 := 0;
    total := 0;
    country_population('Greenland') := 100000;
    howmany := country_population('Greenland');

    for lcv in 1 .. inval
        loop
            -- put break point on the line below
            total := 2 * total + 1 - tmpvar2;
            tmpvar2 := tmpvar;
            tmpvar := loopzz.FIRST;
        end loop;
end complex_data_types;;


CREATE OR REPLACE PACKAGE BODY test AS

    FUNCTION get_ups(foo number)
        RETURN measure_table
        PIPELINED IS

        rec            measure_record;

    BEGIN
        SELECT 'foo', 'bar', 'baz', 2010, 5, 13
          INTO rec
          FROM DUAL;

        -- you would usually have a cursor and a loop here
        PIPE ROW (rec);

        RETURN;
    END get_ups;
END;;

-- new generation
CREATE OR REPLACE PACKAGE test AS

    TYPE measure_record IS RECORD(
       l4_id VARCHAR2(50),
       l6_id VARCHAR2(50),
       l8_id VARCHAR2(50),
       year NUMBER,
       period NUMBER,
       VALUE NUMBER);

    TYPE measure_table IS TABLE OF measure_record;

    FUNCTION get_ups(foo NUMBER)
        RETURN measure_table
        PIPELINED;
END;;

create package SIMPLE_PACK as
    procedure PL(MSG string);
    pragma restrict_references (PL, rnds, wnds);

    my_exc EXCEPTION;
    my_const CONSTANT BINARY_INTEGER := 1;
    my_var NUMBER := -20001;
    TYPE my_collection IS TABLE OF BLOB NOT NULL;
    TYPE my_collection2 IS varray (2) OF BLOB NOT NULL;
    TYPE my_record IS RECORD (x NUMBER, y NUMBER);
    TYPE my_cursor IS REF CURSOR;
    TYPE my_cursor2 IS REF CURSOR return my_record;
    SUBTYPE my_subtype IS number not null;
end SIMPLE_PACK;;

create package body SIMPLE_PACK2 as
    procedure PL(MSG string) is
    begin
        SYS.DBMS_OUTPUT.put_line(MSG);
    end;
end SIMPLE_PACK2;;

create procedure proc_with_proc(inval number, output out number)
    is
    total number;
begin
    total := 0;
    for i in 1 .. inval
        loop
            loopproc(i);
            total := total + personal_inc2(i);
        end loop;
    output := total;
end proc_with_proc;;

create procedure proc_with_func(inval number)
    is
    total number;
begin
    total := 0;
    for i in 1 .. inval
        loop
            total := total + personal_inc2(i);
        end loop;
    DBMS_OUTPUT.put_line('TOTAL IS: ' || total);
end proc_with_func;;

create function personal_inc2(val in number)
    return number
    is
    res number(11, 2);
begin
    res := val + 2;
    return (res);
end;;

create or replace package body pkg_dbgd as
  function tst_1(i in integer) return integer is
  begin
    if i between 5 and 10 then
      return 2*i;
    end if;

    if i between 0 and 4 then
      return tst_2(3+i);
    end if;

    if i between 6 and 10 then
      return tst_2(i-2);
    end if;

    return i;
  end tst_1;

  function tst_2(i in integer) return integer is
  begin
    if i between 6 and 8 then
      return tst_1(i-1);
    end if;

    if i between 1 and 5 then
      return i*2;
    end if;

    return i-1;
  end tst_2;
end pkg_dbgd;;

create or replace package pkg_dbgd as
  function tst_1(i in integer) return integer;
  function tst_2(i in integer) return integer;
end pkg_dbgd;;