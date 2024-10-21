import pyodbc

def db_connection():
    server = 'MI001EQAISQLDEV'
    database = 'PLT_AI'
    username = 'otnunje'
    password = 'Madurai@123#$%^'

    connection_string = (
        f'DRIVER={{ODBC Driver 17 for SQL Server}};'
        f'SERVER={server};'
        f'DATABASE={database};'
        f'UID={username};'
        f'PWD={password};'
    )

    connection = pyodbc.connect(connection_string)
    cursor = connection.cursor()
    return cursor
