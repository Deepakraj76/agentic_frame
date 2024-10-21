from autogen import register_function
from app.Application_Layer.utils.tools import common_tools,specific_tools,output_tools,pre_deployment_tools


def reg(assistant, user_proxy):
    register_function(
    common_tools.file_read,
    caller=assistant,
    executor=user_proxy,
    name="file_read",
    description="Reads SQL, text, or ZIP files from the uploads directory and returns a dictionary with file names as keys and their content as values."
    )

    register_function(
    common_tools.chunking_tool,
    caller=assistant,
    executor=user_proxy,
    name="chunking_tool",
    description="Splits file content into chunks and extracts table names. Input is a file content dictionary(give with the parameter of 'file_data'), output is a dictionary with chunked data and table names."
    )

    register_function(
    specific_tools.identify_table_and_joins,
    caller=assistant,
    executor=user_proxy,
    name="identify_table_and_joins",
    description="Identifies tables, join types, and join conditions from SQL chunks. Input is zip_content(dictionary of file name and data as key and value pair), output is a dictionary with the analysis results for each file."
    )

    generate_tdd_reg = """
    Generates TDD documentation for the given table names and chunks.
    
    Params :
        chunks (list) : A list consisting of all the chunks.
        table_names (list) : A list of all the table names.

    Output :
        A List of json responses

    """
    register_function(
    specific_tools.generate_tdd,
    caller=assistant,
    executor=user_proxy,
    name="generate_tdd",
    description=generate_tdd_reg
    )

    # register_function(
    # output_tools.output_tool,
    # caller=assistant,
    # executor=user_proxy,
    # name="output_tool",
    # description="Generates output in CSV or DOCX format. Input is the data list and output format ('csv' or 'docx'). Returns the file path of the generated output."
    # )

    table_impact_analysis_reg = """
    Compares existing table with the proposed script to find impacted columns and automatically saves a CSV file
    Before using this tool initiate the DB connection using db_connection tool.
    
    Params : 
            exist_table (list): list of table names
            proposed_script (str): proposed script
    output :
            CSV file created succesfully

    """

    register_function(
    specific_tools.table_impact_analysis,
    caller=assistant,
    executor=user_proxy,
    name="table_impact_analysis",
    description=table_impact_analysis_reg
    )

    impact_analysis_tool_reg = """
    **DO NOT CALL THIS TOOL BEFORE THE OUTPUT FROM table_impact_analysis tool gets generated**
    Generates the impacted stored procedure list based on impacted columns and automatically saves a docx,xlsx file
    Params : 
            impact_table_json (json): output of the impacted columns json from table_impact_analysis tool.
            exist_table (list): selected table list
    output :
            docx and xlsx file created succesfully.
    """

    register_function(
    specific_tools.impact_analysis_tool,
    caller=assistant,
    executor=user_proxy,
    name="impact_analysis_tool",
    description=impact_analysis_tool_reg
    )

    db_connection_msg = """
    Establishes a connection to the database.

    Params:
        db_type:str ---> says which type of database (mysql, postgresql, mssql, etc.)
        host:str --> host of the database,
        user:str --->user name who can connect to the database,
        password:str ---> password for the user,
        database:str  ---> name of the database
    output :
        stores the db and cursor objects in the global scope
    Returns:
        str: message indicating successful connection or failure
        """

    register_function(
    common_tools.db_connection,
    caller=assistant,
    executor=user_proxy,
    name="db_connection",
    description=db_connection_msg
    )

    register_function(
        common_tools.retrieve_table_schemas,
        caller=assistant,
        executor=user_proxy,
        name="retrieve_table_schemas",
        description="Retrieves table schemas from the database."
    )

    

    register_function(
        output_tools.csv_generator,
        caller=assistant,
        executor=user_proxy,
        name="csv_generator",
        description="To generate a csv file by receiving a list of data"
    )
    register_function(
        output_tools.docx_generator,
        caller=assistant,
        executor=user_proxy,
        name="doc_generator",
        description="To generate a doc file by receiving a list of data"
    )
    register_function(
        output_tools.TDD_doc_generator,
        caller=assistant,
        executor=user_proxy,
        name="TDD_doc_generator",
        description="To generate a TDD doc file by receiving a list of data.It is triggered only in condition where TDD document generation is needed."
    )

    register_function(
        common_tools.stored_procedure_retriver,
        caller=assistant,
        executor=user_proxy,
        name="retrieve_stored_procedure",
        description="Retrieves stored procedures from the database."
    )
    register_function(
        pre_deployment_tools.pre_process_deployment,
        caller=assistant,
        executor=user_proxy,
        name="pre_process_deployment",
        description="Get the chuncked data from the chunking tool and process it and then return a response list."
    )
    register_function(
        pre_deployment_tools.write_to_sql,
        caller=assistant,
        executor=user_proxy,
        name="write_to_csv",
        description="Receive a response list from the pre_process_deployment and chunked data from the chunking tool and write it to the CSV file"
    )
    return
