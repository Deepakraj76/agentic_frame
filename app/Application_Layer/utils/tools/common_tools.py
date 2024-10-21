import os
import zipfile
from langchain.text_splitter import RecursiveCharacterTextSplitter
from app.Application_Layer.utils.common_utils import extract_table_name
import mysql.connector
import psycopg2
from app.Application_Layer.services import db_state
import pyodbc


def db_connection(db_type:str,host:str,user:str,password:str,database:str)-> any:
    db = None
    cursor = None
    if db_type == 'mysql' or db_type == 'Mysql Database':
        # Connect to MySQL
        db = mysql.connector.connect(
            host=host,
            user=user,
            password=password,
            database=database
        )
        cursor = db.cursor()
        print( "connected to impact_analysis")

    elif db_type == 'psql':
        # Connect to PostgreSQL
        db = psycopg2.connect(
            host=host,
            user=user,
            password=password,
            database=database
        )
        cursor = db.cursor()
        print( "connected to impact_analysis psql" )
    
    elif db_type == 'mssql':
        connection_string = (
            f'DRIVER={{ODBC Driver 17 for SQL Server}};'
            f'SERVER={host};'
            f'DATABASE={database};'
            f'UID={user};'
            f'PWD={password};'
        )
        db = pyodbc.connect(connection_string)
        cursor = db.cursor()
        print("connected to mssql DB...")

    db_state.db_con,db_state.db_cursor,db_state.db_type,db_state.db_name = db, cursor, db_type, database
    return  str(db_state.db_con),str(db_state.db_cursor)


def add_comments_to_schema_from_file(file_path, db_type):
    with open(file_path, 'r') as file:
        schema = file.read()

    lines = schema.splitlines()
    updated_schema = []

    for line in lines:
        # MySQL and PostgreSQL Primary Key
        if 'PRIMARY KEY' in line:
            line += "  -- Primary Key "

        # MySQL and PostgreSQL Foreign Key
        elif 'FOREIGN KEY' in line:
            line += "  -- Foreign Key constraint "

        # MySQL and PostgreSQL Unique Key
        elif 'UNIQUE' in line:
            line += "  -- Unique constraint"

        # MySQL and PostgreSQL Not NULL constraint
        elif 'NOT NULL' in line:
            line += "  -- Not NULL"

        # MySQL Auto Increment vs PostgreSQL Serial
        elif 'AUTO_INCREMENT' in line:
            line += "  -- Auto Increment"
        elif 'SERIAL' in line:
            line += "  -- Auto Increment"

        # Default values
        elif 'DEFAULT' in line:
            line += "  -- Default value specified"

        # Check constraint
        elif 'CHECK' in line:
            line += "  -- Check constraint"

        # Datetime
        elif 'DATETIME' in line:
            line += "  -- Date and time column"
        elif 'TIMESTAMP' in line:
            line += "  --  Stores date and time values"

        # Integer columns
        elif 'INT' in line:
            line += "  -- Integer column"

        elif 'INTEGER' in line:
            line += "  -- Integer column "

        # String/varchar columns
        elif 'VARCHAR'  in line or 'varying' in line or 'CHARACTER VARYING' in line or 'char' in line  or 'varchar' in line or 'nvarchar' in line:
            line += "  -- Variable-length string "

        elif 'TEXT' in line:
            line += "  -- Text column for large strings"

        # Boolean columns
        elif 'BOOLEAN' in line or 'TINYINT(1)' in line:
            line += "  -- Boolean column"

        elif 'BOOL' in line:
            line += "  -- Boolean column "

        # Indexes
        elif 'INDEX' in line or 'KEY' in line:
            line += "  -- Index added for performance"

        # Comment added at the end of the schema creation statement
        updated_schema.append(line)

    with open(file_path, 'w') as file:
        file.write('\n'.join(updated_schema))
    print(f"Updated schema saved to {file_path}")

import os

def retrieve_table_schemas(cursor:str, db_type: str) -> str:
    # Ensure you use the database connection state
    cursor = db_state.db_cursor
    # Fetch all tables based on the database type
    if db_type == "mysql":
        cursor.execute("SHOW TABLES")
        tables = cursor.fetchall()
    elif db_type == "psql":
        cursor.execute("""
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_type = 'BASE TABLE';
        """)
        tables = cursor.fetchall()
    elif db_type=="mssql":
        cursor.execute("SELECT name FROM sys.tables ORDER BY name")
        tables=cursor.fetchall()

    # Ensure uploads folder exists
    uploads_folder = "app/Data_Layer/repository/uploads"
    if not os.path.exists(uploads_folder):
        os.makedirs(uploads_folder)

    # Loop through each table to retrieve and write its schema
    for table in tables:
        table_name = table[0]  # First element of the tuple is the table name

        # Retrieve schema based on database type
        if db_type == "mysql":
            cursor.execute(f"SHOW CREATE TABLE {table_name}")
            schema = cursor.fetchall()
            original_schema = schema[0][1]  # Second element contains the CREATE statement
        elif db_type == "psql":
            cursor.execute(f"""
                SELECT 
                    c.column_name, 
                    c.data_type,
                    c.is_nullable,
                    c.column_default,
                    tc.constraint_type
                FROM 
                    information_schema.columns c
                LEFT JOIN 
                    information_schema.key_column_usage kcu 
                    ON c.table_name = kcu.table_name 
                    AND c.column_name = kcu.column_name
                LEFT JOIN 
                    information_schema.table_constraints tc 
                    ON kcu.constraint_name = tc.constraint_name 
                    AND kcu.table_name = tc.table_name
                WHERE 
                    c.table_name = '{table_name}';
            """)
            columns = cursor.fetchall()
        

            # Build the CREATE TABLE statement with constraints
            column_definitions = []
            for col in columns:
                col_def = f"{col[0]} {col[1]}"  # Column name and data type
                if col[2] == 'NO':  # Check if NOT NULL
                    col_def += " NOT NULL"
                if col[3]:  # If there is a default value
                    col_def += f" DEFAULT {col[3]}"
                if col[4] == 'PRIMARY KEY':
                    col_def += " PRIMARY KEY"
                if col[4] == 'UNIQUE':
                    col_def += " UNIQUE"
                column_definitions.append(col_def)

            # Construct CREATE TABLE statement
            original_schema = f"CREATE TABLE {table_name} (\n  " + ",\n  ".join(column_definitions) + "\n);"
        elif db_type=="mssql":
            create_table_stmt = f"CREATE TABLE {table_name} (\n"
        
            cursor.execute(f"""
            DECLARE @TableName NVARCHAR(128) = '{table_name}';
            DECLARE @SchemaName NVARCHAR(128) = 'dbo';

            DECLARE @SQL NVARCHAR(MAX) = 'CREATE TABLE ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + ' (' + CHAR(13) + CHAR(10);

            -- Adding the columns
            SELECT @SQL = @SQL + '  ' + QUOTENAME(c.name) + ' ' + 
                t.name + 
                CASE 
                    WHEN t.name IN ('varchar', 'nvarchar', 'char') THEN '(' + 
                        CASE WHEN c.max_length = -1 THEN 'MAX' ELSE CAST(c.max_length AS NVARCHAR(10)) END + ')'
                    WHEN t.name IN ('decimal', 'numeric') THEN '(' + CAST(c.precision AS NVARCHAR(10)) + ',' + CAST(c.scale AS NVARCHAR(10)) + ')'
                    ELSE ''
                END + 
                CASE WHEN c.is_nullable = 0 THEN ' NOT NULL' ELSE '' END + 
                CASE WHEN c.is_identity = 1 THEN ' IDENTITY(1,1)' ELSE '' END + ',' + CHAR(13) + CHAR(10)
            FROM sys.columns c
            JOIN sys.types t ON c.user_type_id = t.user_type_id
            WHERE c.object_id = OBJECT_ID(@SchemaName + '.' + @TableName)
            ORDER BY c.column_id;

            -- Removing the last comma and closing the statement
            SET @SQL = LEFT(@SQL, LEN(@SQL) - 3) + CHAR(13) + CHAR(10) + ');';

            -- Adding primary key constraint (if exists)
            DECLARE @PK NVARCHAR(128);
            SELECT @PK = name 
            FROM sys.key_constraints
            WHERE type = 'PK' AND parent_object_id = OBJECT_ID(@SchemaName + '.' + @TableName);

            IF @PK IS NOT NULL
            BEGIN
                SET @SQL = @SQL + 'ALTER TABLE ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + ' ADD CONSTRAINT ' + QUOTENAME(@PK) + ' PRIMARY KEY (';

                SELECT @SQL = @SQL + QUOTENAME(c.name) + ', '
                FROM sys.index_columns ic
                JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
                WHERE ic.object_id = OBJECT_ID(@SchemaName + '.' + @TableName) 
                AND ic.index_id = (SELECT index_id FROM sys.key_constraints WHERE name = @PK);

                -- Remove the last comma and close the PRIMARY KEY clause
                SET @SQL = LEFT(@SQL, LEN(@SQL) - 2) + ');' + CHAR(13) + CHAR(10);
            END
            SELECT @SQL;
              """     )
            columns = cursor.fetchall()[0]
            create_table_stmt = list(columns)[0]

            original_schema = create_table_stmt
        print(original_schema)
        
        # Write the schema to a file in the uploads folder
        file_path = os.path.join(uploads_folder, f"{table_name}_schema.sql")

        with open(file_path, 'w') as file:
            file.write(original_schema)
        
        print(f"Schema for table {table_name} written to {file_path}")

        # Add comments to schema after saving
        add_comments_to_schema_from_file(file_path, db_type)

    return "Schemas are stored in the uploads folder"

def stored_procedure_retriver(cursor: str, database: str, db_type: str) -> str:

    """Retrieves and prints all stored procedures in the specified database along with their full definitions."""
    cursor = db_state.db_cursor

    if db_type.lower() == 'mysql':
        cursor.execute(f"""
            SELECT 
                ROUTINE_NAME, 
                ROUTINE_SCHEMA, 
                CREATED, 
                LAST_ALTERED 
            FROM 
                information_schema.ROUTINES
            WHERE 
                ROUTINE_TYPE = 'PROCEDURE'
                AND ROUTINE_SCHEMA = '{database}';
        """)
        
        procedures = cursor.fetchall()
        
        if procedures:
            uploads_folder = "app/Data_Layer/repository/uploads"
            if not os.path.exists(uploads_folder):
                 os.makedirs(uploads_folder)
            with open(os.path.join(uploads_folder, 'stored_procedures.sql'), 'w') as file:
                for proc in procedures:
                    proc_name = proc[0]
                    proc_schema = proc[1]
                    created = proc[2]
                    last_altered = proc[3]

                    # Fetch the full definition of the stored procedure
                    cursor.execute(f"SHOW CREATE PROCEDURE `{proc_schema}`.`{proc_name}`;")
                    create_statement = cursor.fetchone()
                    definition = create_statement[2]
                   # Print to console
                    file.write(f"{definition}\n\n")  # Write to file
            print("Stored procedures written to stored_procedures.sql")
        else:
            print("No stored procedures found in the database.")

    elif db_type.lower() == 'psql':
        cursor.execute(f"""
            SELECT 
                proname AS procedure_name, 
                n.nspname AS routine_schema, 
                pg_get_functiondef(p.oid) AS definition
            FROM 
                pg_proc p
            JOIN 
                pg_namespace n ON n.oid = p.pronamespace
            WHERE 
                n.nspname NOT IN ('pg_catalog', 'information_schema')
                AND proname IS NOT NULL;
        """)
        
        procedures = cursor.fetchall()

        if procedures:
            uploads_folder = "app/Data_Layer/repository/uploads"
            if not os.path.exists(uploads_folder):
                 os.makedirs(uploads_folder)
            with open(os.path.join(uploads_folder, 'stored_procedures.sql'), 'w') as file:
                for proc in procedures:
                    proc_name = proc[0]
                    proc_schema = proc[1]
                    definition = proc[2]
                    print(definition)  # Print to console
                    file.write(f"{definition}\n\n")  # Write to file
            print("Stored procedures written to postgresql_stored_procedures.sql")
        else:
            print("No stored procedures found in the database.")
    elif db_type.lower() == 'mssql':
         cursor.execute("""
            SELECT 
                m.definition AS ProcedureDefinition
            FROM 
                sys.procedures p
            JOIN 
                sys.sql_modules m ON p.object_id = m.object_id
            WHERE 
                p.is_ms_shipped = 0 -- Exclude system stored procedures
        """)
         procedures = cursor.fetchall()
         if procedures:
            uploads_folder = "app/Data_Layer/repository/uploads"
            if not os.path.exists(uploads_folder):
                 os.makedirs(uploads_folder)
            with open(os.path.join(uploads_folder, 'stored_procedures.sql'), 'w') as file:
                for proc in procedures:
                    definition = proc[0]
                    print(definition)  # Print to console
                    file.write(f"{definition}\n\n")  # Write to file
            print("Stored procedures written to microsoft_stored_procedures.sql")
        
    return "Stored procedures are saved in the uploads folder"

def file_read() -> dict:
    """
    Reads SQL, text, or ZIP files from the uploads directory and returns their content as a dictionary.
    
    Params:
        None
    
    Output:
        A dictionary with file names as keys and their respective content as values.
        Example: { 'file1.sql': 'SELECT * FROM table1;', 'file2.sql': 'CREATE TABLE table2 (...);' }
    """
    from app.Data_Layer.repository.paths import getPaths

    base_path, uploads_path, outputs_path = getPaths()
    
    file_data = {}
    for file_name in os.listdir(uploads_path):
        if file_name.endswith('.zip'):
            zip_path = os.path.join(uploads_path, file_name)
            with zipfile.ZipFile(zip_path, 'r') as zip_ref:
                for filename in zip_ref.namelist():
                    if filename.endswith(".sql") or filename.endswith(".txt"):
                        with zip_ref.open(filename) as file:
                            content = file.read()
                            try:
                                file_data[filename] = content.decode('utf-8')
                            except:
                                file_data[filename] = content.decode('utf-16')
        elif file_name.endswith('.txt') or file_name.endswith('.sql'):
            file_path = os.path.join(uploads_path, file_name)
            with open(file_path, 'r', encoding='utf-8') as file:
                content = file.read()
            content=content.replace("\n"," ").replace("\t","")
            file_data[file_name] = content
    return file_data




def chunking_tool(file_data: dict) -> dict:
    """
    Splits the file content into smaller chunks and extracts table names. 
    
    Params:
        file_data (dict): A dictionary with file names as keys and their content as values.
    
    Output:
        A dictionary where the keys are file names and values are lists containing:
        - chunks: The divided SQL content chunks
        - table_names: Extracted table names from each chunk
        
        Example:
        { 
          'file1.sql': { 'chunks': [...], 'table_names': ['table1', 'table2'] },
          'file2.sql': { 'chunks': [...], 'table_names': ['table3'] }
        }
    """
    chunked_data = {}
    splitter = RecursiveCharacterTextSplitter(
        chunk_size=100, chunk_overlap=20, length_function=len,
        separators=[" CREATE TABLE [dbo]", "CREATE TABLE [dbo]","create table ","CREATE TABLE"]
        # ["create table [dbo].","create table dbo.","create table"] previously used seperators for impact_analysis
    )
    
    for file_name, content in file_data.items():
        chunks = splitter.split_text(content)
        
        # Extract table names from each chunk
        table_names = []
        for chunk in chunks:
            try:
                before = chunk.split(".[_")[1]
                table_name = before.split(']')[0]
                table_names.append(table_name)
            except Exception:
                try:
                    if chunk:
                        table_name = extract_table_name(chunk)
                        table_names.append(table_name)
                except IndexError:
                    return f"Table name not found in chunk: {chunk}"
                
        chunked_data[file_name] = {'chunks': chunks, 'table_names': table_names}
    
    return chunked_data



