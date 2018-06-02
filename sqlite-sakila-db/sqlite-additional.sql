-- additional database objects
-- all types
create table all_types(
int               INT,
integer           INTEGER,
tinyint           TINYINT,
smallint          SMALLINT,
mediumint         MEDIUMINT,
bigint            BIGINT,
u_bigint          UNSIGNED BIG INT,
int2              INT2,
int8              INT8,
char_20           CHARACTER(20),
varchar_255       VARCHAR(255),
varchar2_255      VARYING CHARACTER(255),
nchar_55          NCHAR(55),
nchar_70          NATIVE CHARACTER(70),
nvarchar_100      NVARCHAR(100),
text              TEXT,
clob              CLOB,
blob              BLOB,
real              REAL,
double            DOUBLE,
double_precision  DOUBLE PRECISION,
float             FLOAT,
numeric           NUMERIC,
decimal_10_5      DECIMAL(10,5),
boolean           BOOLEAN,
date              DATE,
datetime          DATETIME
)
;

-- constraints
create table table_with_checks
(
  a int check (a < 2),
  b int constraint c1 check (b < 2),
  check (a + b != -1),
  constraint c2 check (a + b != 2)
)
;

-- keys
create table table1
(
  a integer primary key autoincrement,
  b int unique,
  c int constraint u1 unique,
  unique (a, b),
  constraint u2 unique (a, c)
);
create table table2
(
  a int constraint pk1 primary key unique
);