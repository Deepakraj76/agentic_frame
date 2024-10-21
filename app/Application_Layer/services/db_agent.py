import autogen
import os
from app.Application_Layer.utils.tool_reg import reg_common_tool
from app.paths import getPaths
from app.Application_Layer.prompts.agent_prompts import sys_message
from app.Application_Layer.services import db_state
def start_app():
    # Load the configuration list from a JSON file, filtering for specific models
    base_path, uploads_path, outputs_path = getPaths()
    config_list = autogen.config_list_from_json(
        os.path.join(base_path, "Model_Layer", "models", "config", "OAI_CONFIG_LIST.json"),
        filter_dict={"model": ["gpt-4o", "assitant-api-poc"]},
    )

    # Single Agent for handling all tasks
    assistant = autogen.ConversableAgent(
        name="Database_Modernizer_Agent",
        system_message=sys_message(),
        llm_config={"config_list": config_list}, # when max_tokens are set it does not work for large files
        # human_input_mode="ALWAYS"
    )

    # Proxy Agent for auto execution
    user_proxy = autogen.ConversableAgent(
        name="User_Proxy",
        llm_config=False,
        is_termination_msg=lambda msg: msg.get("content") is not None and "TERMINATE" in msg["content"],
        human_input_mode="NEVER",
    )

    # Register the read_file function from common_tools with the assistant and user_proxy
    reg_common_tool.reg(assistant, user_proxy)

    # Loop to interact with the user and process their choices
    choice = True
    while choice:
        # Prompt the user for their choice
        user_input = input("Enter your choice \n1: generate tdd,\n2: Identify Joins,\n3: Impact analysis,\n4:TDD generation using database,\n5:Identify Table and Joins using database,\n6: Pre_deployment Scripts (for Mysql),\n7: Pre_deployment Scripts (for psql),\n6: Pre_deployment Scripts (for mssql) \nany other key to exit : ")
        
        if user_input == '1':
            # If the user chooses to read a file, initiate a chat with the assistant
            user_prompt = "Generate a TDD documentation from the provided SQL query, and output a TDD docx file."
            chat = user_proxy.initiate_chat(assistant, message=user_prompt)
            # print(f"Assistant Response: {chat}")
        elif user_input == '2':
            # If the user chooses to identify joins, initiate a chat with the assistant
            user_prompt = "Identify the tables and joins in the provided SQL query, and output a csv file."
            chat = user_proxy.initiate_chat(assistant, message=user_prompt)
            # print(f"Assistant Response: {chat}")
        elif user_input == '3':
            # If the user chooses to identify joins, initiate a chat with the assistant
            user_prompt = "Find Impact analysis from the provided SQL query, and output a csv,xlsx,doc files. (for connecting to database use these credentials : db_type='mysql', host='localhost',user='root',password='admin',database='impact_analysis')"
            chat = user_proxy.initiate_chat(assistant, message=user_prompt)
            # print(f"Assistant Response: {chat}")
        elif user_input == '4':
            user_prompt ="establish a db connection using the following connection string db_type='mysql', host='localhost',user='root',password='admin',database='impact_analysis' and extract the schemea from the database and Generate a TDD documentation from the provided SQL query, and output a single TDD docx file that contains all table and then  terminating the chat, terminate the conversation."
            chat = user_proxy.initiate_chat(assistant, message=user_prompt)
            print(db_state.db_con,db_state.db_cursor)
        elif user_input == '5':
            user_prompt ="establish a db connection using the following connection string db_type='mysql', host='localhost',user='root',password='admin@',database='impact_analysis' and extract all the store_procedure using retrieve_stored_procedures tool from the database and then Identify the tables and joins in the provided SQL query, and output a csv file. then  terminating the chat, terminate the conversation."
            chat = user_proxy.initiate_chat(assistant, message=user_prompt)
            print(db_state.db_con,db_state.db_cursor)
        elif user_input == '6':
            user_prompt ="Generate the pre_process deployment script by reading the data on the uploaded mysql file on uploads folder and write to the mysql file using the write to sql tool"
            chat = user_proxy.initiate_chat(assistant, message=user_prompt)
        elif user_input == '7':
            user_prompt ="Generate the pre_process deployment script by reading the data on the uploaded psql file on uploads folder and write to the psql file using the write to sql tool"
            chat = user_proxy.initiate_chat(assistant, message=user_prompt)
        elif user_input == '8':
            user_prompt ="Generate the pre_process deployment script by reading the data on the uploaded mssql file on uploads folder and write to the mssql file using the write to sql tool"
            chat = user_proxy.initiate_chat(assistant, message=user_prompt)
        else:
            break

       
