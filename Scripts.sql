#Show Databses
Show Databases;

#Create Database
create database automation;

#List Databases
show databases;

#Switch Databases
use automation;

#show all tables in database
show tables;

#Delete Databse
drop database reports;

#Database field format
describe reports;

#delete table
drop table reports;

#delete all data in table
TRUNCATE TABLE table_name;

#show columns
show columns from reports;

#create table with all data types
CREATE TABLE `all_data_types` (
    `varchar` VARCHAR(20),
    `tinyint` TINYINT,
    `text` TEXT,
    `date` DATE,
    `smallint` SMALLINT,
    `mediumint` MEDIUMINT,
    `int` INT,
    `bigint` BIGINT,
    `float` FLOAT(10 , 2 ),
    `double` DOUBLE,
    `decimal` DECIMAL(10 , 2 ),
    `datetime` DATETIME,
    `timestamp` TIMESTAMP,
    `time` TIME,
    `year` YEAR,
    `char` CHAR(10),
    `tinyblob` TINYBLOB,
    `tinytext` TINYTEXT,
    `blob` BLOB,
    `mediumblob` MEDIUMBLOB,
    `mediumtext` MEDIUMTEXT,
    `longblob` LONGBLOB,
    `longtext` LONGTEXT,
    `enum` ENUM('1', '2', '3'),
    `set` SET('1', '2', '3'),
    `bool` BOOL,
    `binary` BINARY(20),
    `varbinary` VARBINARY(20)
);

#create reports table
create table reports(uid INT NOT NULL,
execution_date DATE,
environment VARCHAR(200),
triggered_by VARCHAR(200),
hostname VARCHAR(200),
start_time TIMESTAMP,
end_time TIMESTAMP,
total_tc SMALLINT,
passed SMALLINT,
failed SMALLINT,
not_executed SMALLINT,
skiped SMALLINT,
test_phase VARCHAR(200),
primary key(uid)
);

#create status table
create table status(tcid VARCHAR(200),
		tc_status VARCHAR(200),
        tc_description LONGTEXT,
        environment VARCHAR(200),
        comments LONGTEXT,
        screenshot LONGBLOB,
        browser VARCHAR(200),
        duration INT,
        start_time TIMESTAMP,
        end_time TIMESTAMP,
        site LONGTEXT,
        uid INT,
        test_phase VARCHAR(200),
        primary key(tcid,uid)
        );
        
#create userstory table
create table testcase(tc_userstory VARCHAR(200),
		tc_id VARCHAR(200),
        primary key(tc_userstory,tc_id)
        );
        
#create defect table
create table defect(defect_id VARCHAR(200),
		tc_id VARCHAR(200),
        primary key(defect_id,tc_id)
        );

#create table from other
CREATE TABLE TestTable AS SELECT customername, contactname FROM customers;

#add new column
ALTER TABLE Customers ADD Email varchar(20) AFTER name;

#remove column
ALTER TABLE Customers DROP COLUMN Email;

#update column type
ALTER TABLE Customers MODIFY COLUMN Email VARCHAR(200);

#update column values	
UPDATE Customers SET Email = 'sample@domain.com';

#update column name
ALTER TABLE Customers Change Email username varchar(20);

#insert new row
INSERT INTO table_name (column1, column2, column3) VALUES (value1, value2, value3);
INSERT INTO table_name VALUES (value1, value2, value3);

#update row
UPDATE table_name SET column1 = value1, column2 = value2 WHERE column3 = value3; 

#Delete row
DELETE FROM table_name WHERE column1 = value1;











