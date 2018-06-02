-- additional database objects
-- alias types
create type iso2 from char(2)
go

create type iso3 from char(3)
go

-- checks
create table Table_with_Checks
(
    C1 char(1),
    C2 char(2) check (C2 between 'ZZ' and 'ZZ'),
    N1 smallint constraint Check_N1 check (N1 > -100),
    N2 smallint constraint Check_N2 check (N2 > -200),
    constraint Check_NN check (N1 + N2 > 0)
)
go

-- encrypted columns
CREATE COLUMN MASTER KEY MyCMK
WITH (
KEY_STORE_PROVIDER_NAME = N'MSSQL_CERTIFICATE_STORE',
KEY_PATH = 'Current User/Personal/f2260f28d909d21c642a3d8e0b45a830e79a1420'
)
go

CREATE COLUMN ENCRYPTION KEY MyCEK
WITH VALUES
  (
  COLUMN_MASTER_KEY = MyCMK,
  ALGORITHM = 'RSA_OAEP',
  ENCRYPTED_VALUE = 0x01700000016C006F00630061006C006D0061006300680069006E0065002F006D0079002F003200660061006600640038003100320031003400340034006500620031006100320065003000360039003300340038006100350064003400300032003300380065006600620063006300610031006300284FC4316518CF3328A6D9304F65DD2CE387B79D95D077B4156E9ED8683FC0E09FA848275C685373228762B02DF2522AFF6D661782607B4A2275F2F922A5324B392C9D498E4ECFC61B79F0553EE8FB2E5A8635C4DBC0224D5A7F1B136C182DCDE32A00451F1A7AC6B4492067FD0FAC7D3D6F4AB7FC0E86614455DBB2AB37013E0A5B8B5089B180CA36D8B06CDB15E95A7D06E25AACB645D42C85B0B7EA2962BD3080B9A7CDB805C6279FE7DD6941E7EA4C2139E0D4101D8D7891076E70D433A214E82D9030CF1F40C503103075DEEB3D64537D15D244F503C2750CF940B71967F51095BFA51A85D2F764C78704CAB6F015EA87753355367C5C9F66E465C0C66BADEDFDF76FB7E5C21A0D89A2FCCA8595471F8918B1387E055FA0B816E74201CD5C50129D29C015895CD073925B6EA87CAF4A4FAF018C06A3856F5DFB724F42807543F777D82B809232B465D983E6F19DFB572BEA7B61C50154605452A891190FB5A0C4E464862CF5EFAD5E7D91F7D65AA1A78F688E69A1EB098AB42E95C674E234173CD7E0925541AD5AE7CED9A3D12FDFE6EB8EA4F8AAD2629D4F5A18BA3DDCC9CF7F352A892D4BEBDC4A1303F9C683DACD51A237E34B045EBE579A381E26B40DCFBF49EFFA6F65D17F37C6DBA54AA99A65D5573D4EB5BA038E024910A4D36B79A1D4E3C70349DADFF08FD8B4DEE77FDB57F01CB276ED5E676F1EC973154F86
)
go

CREATE TABLE encryptedColumns (
    CustName nvarchar(60)
        ENCRYPTED WITH
            (
             COLUMN_ENCRYPTION_KEY = MyCEK,
             ENCRYPTION_TYPE = RANDOMIZED,
             ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256'
            ),
    SSN varchar(11) COLLATE  Latin1_General_BIN2
        ENCRYPTED WITH
            (
             COLUMN_ENCRYPTION_KEY = MyCEK,
             ENCRYPTION_TYPE = DETERMINISTIC ,
             ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256'
            ),
    Age int NULL
)
go

-- FK rules
create table A
(
    id tinyint primary key
)
go

create table B3
(
    ref_3 tinyint default -3
        constraint B3_fk
            references A on update set default on delete set default
)
go

-- routines
create function Calculate_Something (@what tinyint, @with smallint, @when int) returns bigint
as
begin
    -- calculate something
    return @what * 101 + @with * 37 + @when * 7
end
go


create procedure Do_Something @what tinyint, @with smallint, @when int
as
begin
    -- do something
    return
end
go

-- sequence
CREATE SEQUENCE sequence_b AS INT START WITH -100 INCREMENT BY 2 MAXVALUE 1000 CYCLE NO CACHE
go

-- synonym
create table tableForSynonym(a int)
go

create synonym myTableSynonym for tableForSynonym
go

-- table type
create type Table_Type_A as table
(
    A1 tinyint,
    A2 smallint,
    A3 int,
    A4 bigint
)
go

-- trigger
create table Tab1
(
    Id integer,
    Note varchar(60)
)
go

create trigger Tab1_Trim_Note_tr
    on Tab1
    after insert, update
    not for replication
as
begin
    update Tab1
    set Note = ltrim(rtrim(Note))
    where Id in (select Id from INSERTED);
end
go

-- view trigger
create view V1
as
select 33 as X
union all
select 44 as X
go


create trigger V1_trg_i
    on V1
    instead of insert
as
raiserror('Don''t dump your numbers into mine!',16,1)
go

-- all types
create table allTypes(
[image] image,
[text] text,
[uniqueidentifier] uniqueidentifier,
[date] date,
[time] time,
[datetime2] datetime2,
[datetimeoffset] datetimeoffset,
[smallint] smallint,
[int] int,
[smalldatetime] smalldatetime,
[real] real,
[money] money,
[datetime] datetime,
[float] float,
[sql_variant] sql_variant,
[ntext] ntext,
[bit] bit,
[decimal] decimal,
[numeric] numeric,
[smallmoney] smallmoney,
[bigint] bigint,
[hierarchyid] hierarchyid,
[geometry] geometry,
[geography] geography,
[varbinary] varbinary,
[varchar] varchar,
[binary] binary,
[char] char,
[timestamp] timestamp,
[nvarchar] nvarchar,
[nchar] nchar,
[xml] xml,
[sysname] sysname,
[tinyint] tinyint
)
go

create table allTypes2(
[rowversion] rowversion,
[geometry] geometry,
[geography] geography
)
go

create table allTypesDateTime(
[datetime2_0]       datetime2(0),
[datetime2_1]       datetime2(1),
[datetime2_2]       datetime2(2),
[datetime2_3]       datetime2(3),
[datetime2_4]       datetime2(4),
[datetime2_5]       datetime2(5),
[datetime2_6]       datetime2(6),
[datetime2_7]       datetime2(7),
[datetimeoffset_0]  datetimeoffset(0),
[datetimeoffset_1]  datetimeoffset(1),
[datetimeoffset_2]  datetimeoffset(2),
[datetimeoffset_3]  datetimeoffset(3),
[datetimeoffset_4]  datetimeoffset(4),
[datetimeoffset_5]  datetimeoffset(5),
[datetimeoffset_6]  datetimeoffset(6),
[datetimeoffset_7]  datetimeoffset(7),
[time_0]            time(0),
[time_1]            time(1),
[time_2]            time(2),
[time_3]            time(3),
[time_4]            time(4),
[time_5]            time(5),
[time_6]            time(6),
[time_7]            time(7)
)
go

create table allTypesWithPrecision (
[decimal_18]    decimal(18),
[decimal_2_2]   decimal(2,2),
[decimal_10_2]  decimal(10,2),
[decimal_22_10] decimal(22, 10),
[decimal_30_10] decimal(30, 10),
[decimal_38_38] decimal(38,38),
[decimal_38]    decimal(38),
[float_53] float(53),
[float_1] float(1),
[float_24] float(24),
[float_25] float(25),
[double_precision] double precision
)
go