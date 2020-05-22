MySQL - Commands
================

* login

::
    
    # Login with password
    mysql -u [username] -p            

    # Login with password to a database
    mysql -u [username] -p [database];

* show

::

    # show databases
    SHOW DATABASE;

    # show tables
    SHOW TABLES;

    # show variables
    show variables;

* Create/destroy

::
    # Create Database
    CREATE DATABASE [IF NOT EXISTS] database_name;

    # Use a database or change the current database
    USE database_name;

    # drop database
    DROP DATABASE [IF EXISTS] database_name;

* Tables

::

    # show tables
    show tables;

    # Create Table
    CREATE TABLE [IF NOT EXISTS] table_name(
      column_list
    );

    ALTER TABLE table ADD [COLUMN] column_name;

    ALTER TABLE table_name DROP [COLUMN] column_name;

    ALTER TABLE table ADD INDEX [name](column, ...);

    # Drop a table
    DROP TABLE [IF EXISTS] table_name;  

    # Show the columns of a table
    DESCRIBE table_name;

    Show the information of a column in a table
    DESCRIBE table_name column_name;

Sample Databases
================

* https://www.mysqltutorial.org/mysql-sample-database.aspx/

