
def ttd_prompt():
    prompt_for_tdd = """
    I want you to create a TDD documentation and you will need to use the schema. 
    Make sure it should be returned as tabular format as JSON as follows: 

    {<table_name>:{{<content>:{{<column name>:<column commends>}}}}}
    you return only the json response and no other text should be return.
    In this case if there is no column commends in this schema just ignore the column as well.
    Make sure it should return JSON, no other string involved into the JSON.
    I will provide you with the schema and TDD document for respective contents:
    1.Implementing Primary Key & Foreign Key 
    2.Addition of New Column
    3.Replacement of Existing Columns & Data Types 
    4.Applying Null/Not Null Constraint 
    5.Retaining Existing Code Column
    6.Deletion of Existing Column 
    7.Applying Default Values 
    <schema>
    Examples:
      example 1:
        Schema:CREATE TABLE [dbo].[_GeneratorType]([generator_type_id] [int] Not NULL, -- Added Not NULL, primary key[generator_type] [varchar](20) Not NULL, -- Added Not NULL [added_by] [varchar](100) NOT NULL, -- Added new column[date_added] [datetime] NOT NULL, -- Added new column[modified_by] [varchar](100) NOT NULL,-- Added new column,add not to null[date_modified] [datetime] NOT NULL, -- Added new columnCONSTRAINT [PK_GeneratorType] PRIMARY KEY CLUSTERED ([generator_type_id])) ON [PRIMARY]GO
        response:{
                `"Implementing Primary Key & Foreign Key": {
                    "generator_type_id": "Added Not NULL, primary key"
                },
                "Addition of New Column": {
                    "added_by": "Added new column",
                    "date_added": "Added new column",
                    "modified_by": "Added new column",
                    "date_modified": "Added new column"
                },
                "Applying Null/Not Null Constraint": {
                    "generator_type_id": "Added Not NULL",
                    "generator_type": "Added Not NULL",
                    "added_by": "Added Not NULL",
                    "date_added": "Added Not NULL",
                    "modified_by": "Added Not NULL",
                    "date_modified": "Added Not NULL"
                }
            }
         example 2:
             Schema:CREATE TABLE [dbo].[_County]([county_code] [int] NOT NULL, -- Added Not NULL primary key [county_name] [varchar](30) NOT NULL, -- Added Not NULL [state] [varchar](2) NULL,[added_by] [varchar](100) NOT NULL, -- Datatype length 10 >100,Changed to NOT NULL[date_added] [datetime] NOT NULL, -- Changed to NOT NULL[modified_by] [varchar](100) NOT NULL, -- Datatype length 10 >100,Changed to NOT NULL[date_modified] [datetime] NOT NULL , -- Added default value and change to NOT NULLCONSTRAINT [PK_County] PRIMARY KEY CLUSTERED ([county_code])) ON [PRIMARY]Go
             Response: {
                "Implementing Primary Key & Foreign Key": {
                    "county_code": "Added Not NULL primary key"
                },
                "Addition of New Column": {},
                "Replacement of Existing Columns & Data Types": {
                    "added_by": "Datatype length 10 >100,Changed to NOT NULL",
                    "modified_by": "Datatype length 10 >100,Changed to NOT NULL"
                },
                "Applying Null/Not Null Constraint": {
                    "county_code": "Added Not NULL",
                    "county_name": "Added Not NULL",
                    "added_by": "Changed to NOT NULL",
                    "date_added": "Changed to NOT NULL",
                    "modified_by": "Changed to NOT NULL",
                    "date_modified": "Changed to NOT NULL"
                },
                "Retaining Existing Code Column": {},
                "Deletion of Existing Column": {},
                "Applying Default Values": {
                    "date_modified": "Added default value"
                }
            }

    """
    return prompt_for_tdd

def identify_table_prompt():
    prompt_for_identify = """
    Your task is to find the different tables' names from select queries and the different types of join operations from the below stored_procedure. 
    In case of no join operation being performed, return only the table name. The format to be returned is as follows:
    Table Names: <list of Table Names>
    Join Type: <list of Associated Join type>
    Joined Tables: <list of Joined Table Name>
    Joined Condition: <list of Joined On Condition>
    Even if the same table name is used multiple times across the procedure, they should be returned separately.
    i.e., the same information can be repeated multiple times across the response if required. Don't hallucinate if the database does not exist.
    Response should be returned as a dictionary as follows:
    [{"Stored Procedure": <Procedure Name 1>, "Table Names": <Table Name 1>, "Join Tables": <Join Table 1>, "Join Type": <Join Type 1>, "Join Condition": <Join Condition 1>},
     {"Stored Procedure": <Procedure Name 2>, "Table Names": <Table Name 2>, "Join Tables": <Join Table 2>, "Join Type": <Join Type 2>, "Join Condition": <Join Condition 2>}]
    Ensure that you retrieve all the details from the stored procedure and craft a response like the above dictionary list accordingly.
    You return only the dictionary as a response and no other text should be returned.
    examples:
        example1:
        store_procedure: "CREATE PROCEDURE GetProductsAndCategoriesCrossJoin
                            AS
                            BEGIN
                                SELECT Products.ProductID, Products.ProductName, Categories.CategoryID, Categories.CategoryName
                                FROM Products
                                CROSS JOIN Categories;
                            END;"
        response: {"Stored Procedure": "GetProductsAndCategoriesCrossJoin", "Table Names": "Products", "Join Tables": "Categories", "Join Type": "CROSS JOIN", "Join Condition": ""}

        example2:
        store_procedure: "CREATE PROCEDURE GetEmployeeSubordinates
                            AS
                            BEGIN
                                WITH EmployeeHierarchy AS (
                                    SELECT E.EmployeeID, E.EmployeeName, M.EmployeeID AS ManagerID, M.EmployeeName AS ManagerName
                                    FROM Employees E
                                    LEFT JOIN Employees M ON E.ManagerID = M.EmployeeID
                                )
                                SELECT *
                                FROM EmployeeHierarchy;
                            END;"
        response={"Stored Procedure": "GetEmployeeSubordinates", "Table Names": "Employees E", "Join Tables": "Employees M", "Join Type": "LEFT JOIN", "Join Condition": "E.ManagerID = M.EmployeeID"}
       
    The stored procedure is as follows:
    """
    return prompt_for_identify
