import os
import zipfile
from langchain.text_splitter import RecursiveCharacterTextSplitter
from app.Application_Layer.utils.common_utils import extract_table_name
import mysql.connector
import psycopg2
from app.Model_Layer.models import autogen_ai
from app.Application_Layer.services import db_state

def pre_process_deployment(db_type:str,chunks:list,table_names:list)->dict:
    response_list=[]
   
# Print the result
    for exists_table_name in range (len(table_names)):
        if len(table_names[exists_table_name].split('_')) ==1:
            table_names[exists_table_name] = '_'+table_names[exists_table_name]
        print(table_names[exists_table_name])
        table_name = table_names[exists_table_name].split('_')[1]
        new_table_name = table_names[exists_table_name]
        # Columns = column_list
        if db_type == "mssql":
            prompt = f"""
            {chunks[exists_table_name]} \n
            
            Objective: Generate a MSSQL script that performs the following tasks for multiple tables:

                1.For each table, rename {table_name} to {new_table_name} and perform all necessary data transfers.
                2.Insert data from the old table ({table_name}) to the new table ({new_table_name}).
                3.If the following columns exist, ensure that when inserting data, the columns added_by, date_added, modified_by, and date_modified handle NULL values as follows:
                    COALESCE(added_by, 'SA') AS added_by
                    COALESCE(date_added, NOW()) AS date_added
                    COALESCE(modified_by, 'SA') AS modified_by
                    COALESCE(date_modified, NOW()) AS date_modified
                4.If the column rowguid exists, exclude it from the insertion.
                5.Do not generate any additional text or comments in the script.
                6.List out all columns on the old table to new table
                If there are large columns, a SQL Server script should be created.

            Table and column details:
            - Original table name: `{table_name}`
            - New table name: `{new_table_name}`
            - Column: All columns in the table
            Example script for reference:
            ```sql
            PRINT 'Load table data pre-rename'

            IF EXISTS (SELECT * FROM sys.tables WHERE name = '_Company')
            BEGIN
                DECLARE @Date DATETIME = '2000-01-01 00:00:00.000'
                INSERT INTO [dbo].[_Company]
                    ([company_id]
                    ,[company_name]
                    ,[dunn_and_bradstreet_id]
                    ,[remit_to]
                    ,[address_1]
                    ,[address_2]
                    ,[address_3]
                    ,[phone]
                    ,[fax]
                    ,[EPA_ID]
                    ,[date_added]
                    ,[added_by]
                    ,[date_modified]
                    ,[modified_by]
                    ,[insurance_surcharge_percent]
                    ,[phone_customer_service]
                    ,[next_project_id]
                    ,[payroll_company_id]
                    ,[view_on_web]
                    ,[view_invoicing_on_web]
                    ,[view_aging_on_web]
                    ,[view_survey_on_web]
                    ,[dba_name]
                    ,[JDE_company]
                    ,[AX_Dimension_1]
                    ,[invoice_template_id])
                SELECT [company_id]
                    ,[company_name]
                    ,[dunn_and_bradstreet_id]
                    ,[remit_to]
                    ,[address_1]
                    ,[address_2]
                    ,[address_3]
                    ,[phone]
                    ,[fax]
                    ,[EPA_ID]
                    ,ISNULL([date_added], @Date) AS [date_added]
                    ,'SA' AS [added_by]
                    ,ISNULL([date_modified], @Date) AS [date_modified]
                    ,'SA' AS [modified_by]
                    ,[insurance_surcharge_percent]
                    ,[phone_customer_service]
                    ,[next_project_id]
                    ,[payroll_company_id]
                    ,[view_on_web]
                    ,[view_invoicing_on_web]
                    ,[view_aging_on_web]
                    ,[view_survey_on_web]
                    ,[dba_name]
                    ,[JDE_company]
                    ,[AX_Dimension_1]
                    ,[invoice_template_id]
                FROM [dbo].[Company]
            END

            PRINT 'Rename tables post-data load'

            IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Company')
                AND EXISTS (SELECT * FROM sys.tables WHERE name = '_Company') 
            BEGIN
                IF EXISTS (SELECT * FROM dbo.Company)
                    AND EXISTS (SELECT * FROM dbo._Company)
                BEGIN
                    -- Rename table
                    EXEC sp_rename 'dbo.Company', '_Company_old'
                    EXEC sp_rename 'dbo._Company', 'Company'
                END
                ELSE
                BEGIN
                    SELECT 'Data exists Check Failed Company' AS [CheckIF]
                END
            END
            ELSE
            BEGIN
                SELECT 'Table exists Check Failed Company' AS [CheckIF]
            END
            """

### MySQL Script Generation

        elif db_type.lower() == 'mysql':
            prompt = f"""
            {chunks[exists_table_name]} \n
            Objective: Generate a MySQL script that performs the following tasks for multiple tables:

                1.For each table, rename {table_name} to {new_table_name} and perform all necessary data transfers.
                2.Insert data from the old table ({table_name}) to the new table ({new_table_name}).
                3.If the following columns exist, ensure that when inserting data, the columns added_by, date_added, modified_by, and date_modified handle NULL values as follows:
                    COALESCE(added_by, 'SA') AS added_by
                    COALESCE(date_added, NOW()) AS date_added
                    COALESCE(modified_by, 'SA') AS modified_by
                    COALESCE(date_modified, NOW()) AS date_modified
                4.If the column rowguid exists, exclude it from the insertion.
                5.Do not generate any additional text or comments in the script.
                If there are large columns, a SQL Server script should be created.
            
            Table and column details:
            - Original table name: `{table_name}`
            - New table name: `{new_table_name}`
             - Columns: Find the columns from the sql script.
         
            Example:
                DROP PROCEDURE IF EXISTS RenameAndTransferTableEmployees;
                DELIMITER //

                CREATE PROCEDURE RenameAndTransferTableEmployees()
                BEGIN
                    DECLARE msg_message VARCHAR(100);

                    -- Procedure for Employees
                    IF EXISTS (SELECT * FROM information_schema.tables WHERE table_name = 'Employees') THEN
                        SET msg_message = 'Employees exists, proceeding to load data.';
                        SELECT msg_message AS Message;

                        CREATE TABLE `New_Employees` LIKE `Employees`;
                        INSERT INTO `New_Employees` 
                            (`employee_id`, `first_name`, `last_name`, 
                            `added_by`, `date_added`, `modified_by`, `date_modified`)
                        SELECT 
                            `employee_id`, `first_name`, `last_name`, 
                            COALESCE(`added_by`, 'SA') AS `added_by`, 
                            COALESCE(`date_added`, NOW()) AS `date_added`, 
                            COALESCE(`modified_by`, 'SA') AS `modified_by`, 
                            COALESCE(`date_modified`, NOW()) AS `date_modified`
                        FROM `Employees`;
                        
                        IF EXISTS (SELECT * FROM information_schema.columns WHERE table_name = 'Employees' AND column_name = 'rowguid') THEN
                            ALTER TABLE `New_Employees` DROP COLUMN `rowguid`;
                        END IF;

                        RENAME TABLE `Employees` TO `Employees_old`, `New_Employees` TO `Employees`;
                    END IF;

                    -- Procedure for Products
                    IF EXISTS (SELECT * FROM information_schema.tables WHERE table_name = 'Products') THEN
                        SET msg_message = 'Products exists, proceeding to load data.';
                        SELECT msg_message AS Message;

                        CREATE TABLE `New_Products` LIKE `Products`;
                        INSERT INTO `New_Products` 
                            (`product_id`, `product_name`, `price`, 
                            `added_by`, `date_added`, `modified_by`, `date_modified`)
                        SELECT 
                            `product_id`, `product_name`, `price`, 
                            COALESCE(`added_by`, 'SA') AS `added_by`, 
                            COALESCE(`date_added`, NOW()) AS `date_added`, 
                            COALESCE(`modified_by`, 'SA') AS `modified_by`, 
                            COALESCE(`date_modified`, NOW()) AS `date_modified`
                        FROM `Products`;
                        
                        IF EXISTS (SELECT * FROM information_schema.columns WHERE table_name = 'Products' AND column_name = 'rowguid') THEN
                            ALTER TABLE `New_Products` DROP COLUMN `rowguid`;
                        END IF;

                        RENAME TABLE `Products` TO `Products_old`, `New_Products` TO `Products`;
                    END IF;

                    -- Procedure for Orders
                    IF EXISTS (SELECT * FROM information_schema.tables WHERE table_name = 'Orders') THEN
                        SET msg_message = 'Orders exists, proceeding to load data.';
                        SELECT msg_message AS Message;

                        CREATE TABLE `New_Orders` LIKE `Orders`;
                        INSERT INTO `New_Orders` 
                            (`order_id`, `customer_id`, `order_date`, 
                            `added_by`, `date_added`, `modified_by`, `date_modified`)
                        SELECT 
                            `order_id`, `customer_id`, `order_date`, 
                            COALESCE(`added_by`, 'SA') AS `added_by`, 
                            COALESCE(`date_added`, NOW()) AS `date_added`, 
                            COALESCE(`modified_by`, 'SA') AS `modified_by`, 
                            COALESCE(`date_modified`, NOW()) AS `date_modified`
                        FROM `Orders`;
                        
                        IF EXISTS (SELECT * FROM information_schema.columns WHERE table_name = 'Orders' AND column_name = 'rowguid') THEN
                            ALTER TABLE `New_Orders` DROP COLUMN `rowguid`;
                        END IF;

                        RENAME TABLE `Orders` TO `Orders_old`, `New_Orders` TO `Orders`;
                    END IF;

                END //

                DELIMITER ;

                -- Call the procedure
                CALL RenameAndTransferTableEmployees();

    """

### PostgreSQL Script Generation

        elif db_type.lower() == 'psql':
            prompt = f"""
            {chunks[exists_table_name]} \n


            Here's the updated prompt for generating a PostgreSQL script based on your specified tasks:

            Objective: Generate a PostgreSQL script that performs the following tasks for multiple tables:

            1.For each table, rename {table_name} to {new_table_name} and perform all necessary data transfers.
            2.Insert data from the old table ({table_name}) to the new table ({new_table_name}).
            3.If the following columns exist, ensure that when inserting data, the columns added_by, date_added, modified_by, and date_modified handle NULL values as follows:
            COALESCE(added_by, 'SA') AS added_by
                COALESCE(date_added, NOW()) AS date_added
                COALESCE(modified_by, 'SA') AS modified_by
                COALESCE(date_modified, NOW()) AS date_modified
            4.If the column rowguid exists, exclude it from the insertion.
            5.Do not generate any additional text or comments in the script.
            Table and column details:
            - Original table name: `{table_name}`
            - New table name: `{new_table_name}`
            - Columns: Find the columns from the SQL script.
            
            Example:
            -- Drop the function if it already exists
                DROP FUNCTION IF EXISTS RenameAndTransferTableemployees();
                CREATE OR REPLACE FUNCTION RenameAndTransferTableemployees() RETURNS VOID AS $$
                DECLARE
                    msg_message TEXT;
                BEGIN
                    -- Procedure for Employees
                    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'employees') THEN
                        msg_message := 'Employees table exists, proceeding to load data.';
                        RAISE NOTICE '%', msg_message;

                        -- Create new table with specified columns
                        EXECUTE 'CREATE TABLE new_employees (
                            employee_id SERIAL PRIMARY KEY,
                            first_name VARCHAR(255),
                            last_name VARCHAR(255),
                            added_by VARCHAR(255),
                            date_added TIMESTAMP,
                            modified_by VARCHAR(255),
                            date_modified TIMESTAMP
                        )';

                        EXECUTE 'INSERT INTO new_employees (employee_id, first_name, last_name, added_by, date_added, modified_by, date_modified) 
                                SELECT employee_id, first_name, last_name, 
                                COALESCE(added_by, ''Admin''), 
                                COALESCE(date_added, NOW()), 
                                COALESCE(modified_by, ''Admin''), 
                                COALESCE(date_modified, NOW())
                                FROM employees';

                        -- Rename tables
                        EXECUTE 'ALTER TABLE employees RENAME TO employees_old';
                        EXECUTE 'ALTER TABLE new_employees RENAME TO employees';
                    END IF;

                    -- Procedure for Departments
                    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'departments') THEN
                        msg_message := 'Departments table exists, proceeding to load data.';
                        RAISE NOTICE '%', msg_message;

                        -- Create new table with specified columns
                        EXECUTE 'CREATE TABLE new_departments (
                            department_id SERIAL PRIMARY KEY,
                            department_name VARCHAR(255),
                            added_by VARCHAR(255),
                            date_added TIMESTAMP,
                            modified_by VARCHAR(255),
                            date_modified TIMESTAMP
                        )';

                        EXECUTE 'INSERT INTO new_departments (department_id, department_name, added_by, date_added, modified_by, date_modified) 
                                SELECT department_id, department_name, 
                                COALESCE(added_by, ''Admin''), 
                                COALESCE(date_added, NOW()), 
                                COALESCE(modified_by, ''Admin''), 
                                COALESCE(date_modified, NOW())
                                FROM departments';

                        -- Rename tables
                        EXECUTE 'ALTER TABLE departments RENAME TO departments_old';
                        EXECUTE 'ALTER TABLE new_departments RENAME TO departments';
                    END IF;

                    -- Procedure for Projects
                    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'projects') THEN
                        msg_message := 'Projects table exists, proceeding to load data.';
                        RAISE NOTICE '%', msg_message;

                        -- Create new table with specified columns
                        EXECUTE 'CREATE TABLE new_projects (
                            project_id SERIAL PRIMARY KEY,
                            project_name VARCHAR(255),
                            start_date DATE,
                            end_date DATE,
                            added_by VARCHAR(255),
                            date_added TIMESTAMP,
                            modified_by VARCHAR(255),
                            date_modified TIMESTAMP
                        )';

                        EXECUTE 'INSERT INTO new_projects (project_id, project_name, start_date, end_date, added_by, date_added, modified_by, date_modified) 
                                SELECT project_id, project_name, start_date, end_date, 
                                COALESCE(added_by, ''Admin''), 
                                COALESCE(date_added, NOW()), 
                                COALESCE(modified_by, ''Admin''), 
                                COALESCE(date_modified, NOW())
                                FROM projects';

                        -- Rename tables
                        EXECUTE 'ALTER TABLE projects RENAME TO projects_old';
                        EXECUTE 'ALTER TABLE new_projects RENAME TO projects';
                    END IF;

                END $$ LANGUAGE plpgsql;

                -- Call the function to rename and transfer tables
                SELECT RenameAndTransferTableemployees();


            """

        response = autogen_ai.autogen_main(
            assistant_name="Database Administrator (DBA)",
                assistant_sys_msg="You are a helpful AI assistant who can find what I expect",
                agent_name="Database Administrator (DBA) Agent",
                agent_sys_message="You are an expert in Database. So you could assist me.",
                prompt=prompt
                )
        response=response.replace("```sql","").replace("```mysql","").replace("```psql","").replace("```","")
        response_list.append(response)
    return response_list
    

def write_to_sql(table_names:list,response_list:list)->str:
    for exists_table_name in range (len(table_names)):
        
        output_file_path = os.path.join("app/Data_Layer/repository/outputs", f"{table_names[exists_table_name]}.sql")
        # Write the generated prompt (SQL script) to the .sql file
        with open(output_file_path, "w") as sql_file:
            sql_file.write(response_list[exists_table_name])
    return "Files are created"
    