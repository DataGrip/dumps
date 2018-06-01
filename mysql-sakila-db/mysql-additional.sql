-- additional database objects
-- clustered index
create table additional_country (
  country_id int not null primary key
);
create table vat_group_source_country (
  vat_group_source_country_id int not null primary key
);
create TABLE vat_group_source_country_linker (
  vat_group_source_country_id int unsigned NOT NULL,
  country_id int NOT NULL,
  PRIMARY KEY (vat_group_source_country_id,country_id),
  UNIQUE KEY FK_vat_group_source_country_linker_country_id (country_id),
  CONSTRAINT FK_vat_group_source_country_linker_country_id FOREIGN KEY (country_id) REFERENCES additional_country (country_id) ON UPDATE CASCADE #,
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- index types
create table host (
    id   int primary key not null,
    name varchar(20)
);
create index b_index on host(name) using btree;
create index h_index on host(name) using hash;
create unique index ub_index on host(name) using btree;
create unique index uh_index on host(name) using hash;

create table host_mem (
    id   int primary key not null,
    name varchar(20)
) engine=memory;
create index b_index_mem on host_mem(name) using btree;
create index h_index_mem on host_mem(name) using hash;
create unique index ub_index_mem on host_mem(name) using btree;
create unique index uh_index_mem on host_mem(name) using hash;

-- events
CREATE EVENT myevent
    ON SCHEDULE AT '2030-12-24' + INTERVAL 1 HOUR
    DO
      SELECT 1;
CREATE EVENT myevent2
    ON SCHEDULE EVERY concat('1', '2') HOUR
    STARTS '2030-12-24' + INTERVAL concat('1', '2') HOUR
    ENDS '2030-12-24' + INTERVAL concat('9', '2') HOUR
    DO
      SELECT 1

-- table options
CREATE TABLE `sessions` (
  `id`              BIGINT(20) UNSIGNED NOT NULL,
  `account_id`      BIGINT(20) UNSIGNED NOT NULL  COMMENT 'accounts accounts.id',
  `app_id`          TINYINT(4) UNSIGNED NOT NULL,
  `start_lts`       BIGINT(14) UNSIGNED NOT NULL,
  `end_lts`         BIGINT(14) UNSIGNED DEFAULT NULL,
  `remote_host`     VARCHAR(45)         NOT NULL,
  `instance_id`     VARCHAR(64)         DEFAULT NULL,
  `timezone_offset` INT(11)             DEFAULT NULL,
  `user_agent`      VARCHAR(255)        NOT NULL,

  PRIMARY KEY (`id`),
  KEY `account_id` (`account_id`),
  KEY `app_id` (`app_id`)
)  ENGINE = InnoDB  DEFAULT CHARSET = utf8  COMMENT = 'WS sessions';

-- trigger
create table table_for_trigger (
a int,
b int,
c int
);

create trigger t_before_insert before insert on table_for_trigger
  for each row set @sum = @sum + NEW.a;
;
create trigger t_after_update after update on table_for_trigger
  for each row set @sum = @sum + NEW.b;
;
create trigger t_before_delete before delete on table_for_trigger
  for each row set @sum = 0;
;

-- all types
CREATE TABLE primitives
(
  `bit`               BIT,
  `tinyint`           TINYINT ZEROFILL,
  `boolean`           BOOLEAN,
  `smallint`          SMALLINT UNSIGNED ZEROFILL,
  `mediumint`         MEDIUMINT,
  `int`               INT,
  `integer`           INTEGER,
  `bigint`            BIGINT,
  `real`              REAL,
  `double`            DOUBLE,
  `float`             FLOAT,
  `decimal`           DECIMAL,
  `numeric`           NUMERIC,
  `date`              DATE,
  `time`              TIME,
  `timestamp`         TIMESTAMP,
  `datetime`          DATETIME,
  `year`              YEAR,

  `char`              CHAR,
  `char binary`       CHAR BINARY CHARACTER SET latin1
  COLLATE latin1_swedish_ci,
  `varchar`           VARCHAR(1),
  `varchar binary`    VARCHAR(1) BINARY,

  `binary`            BINARY,
  `varbinary`         VARBINARY(1),
  `tinyblob`          TINYBLOB,
  `blob`              BLOB(1),
  `mediumblob`        MEDIUMBLOB,
  `longblob`          LONGBLOB,

  `tinytext`          TINYTEXT,
  `tinytext binary`   TINYTEXT BINARY CHARACTER SET latin1
  COLLATE latin1_swedish_ci,
  `text`              TEXT,
  `text binary`       TEXT BINARY CHARACTER SET latin1
  COLLATE latin1_swedish_ci,
  `mediumtext`        MEDIUMTEXT,
  `mediumtext binary` MEDIUMTEXT BINARY,
  `longtext`          LONGTEXT,

  `enum`              ENUM ('value1', 'value2'),
  `set`               SET ('value1', 'value2'),
  `json`              JSON,
  `geometry`          GEOMETRY,
  `point`             POINT,
  `linestring`        LINESTRING,
  `polygon`           POLYGON
)
  DEFAULT CHARSET = latin1 COLLATE latin1_swedish_ci
;