import streamlit as st
import autogen
import os
from jinja2 import Template
from app.Application_Layer.utils.tool_reg import reg_common_tool
from app.Data_Layer.repository.paths import getPaths
from app.Application_Layer.prompts.agent_prompts import sys_message
import mysql.connector
import psycopg2
from app.Application_Layer.services import db_state
from app.paths import getPaths1

# Function to save the uploaded file
def save_uploaded_file(uploaded_file, uploads_folder):
    if not os.path.exists(uploads_folder):
        os.makedirs(uploads_folder)
    with open(os.path.join(uploads_folder, uploaded_file.name), 'wb') as f:
        f.write(uploaded_file.getbuffer())

# Main function for the Streamlit app
def start_app():
    # Load paths
    base_path, uploads_path, outputs_path = getPaths()
    base_path1, uploads_path1, outputs_path1 = getPaths1()

    # Load the configuration list from a JSON file, filtering for specific models
    config_list = autogen.config_list_from_json(
        base_path1 + "\Model_Layer\models\config\OAI_CONFIG_LIST.json",
        filter_dict={"model": [ "gpt-4o","assitant-api-poc"]},
    )

    # Single Agent for handling all tasks
    assistant = autogen.ConversableAgent(
        name="Database_Modernizer_Agent",
        system_message=sys_message(),
        llm_config={"config_list": config_list},
    )

    # Proxy Agent for auto execution
    user_proxy = autogen.ConversableAgent(
        name="User_Proxy",
        llm_config=False,
        is_termination_msg=lambda msg: msg.get("content") is not None and "TERMINATE" in msg["content"],
        human_input_mode="NEVER",
    )

    # Register common tools with the agents
    reg_common_tool.reg(assistant, user_proxy)

    st.title("Database Modernization Agent")

    # Add a selectbox for user choices
    user_choice = st.selectbox("Select an option:", 
        [
            "1. Generate TDD documentation", 
            "2. Identify tables and joins", 
            "3. Find Impact analysis", 
            "4. Generate TDD using DB Connection", 
            "5. Identify Joins using DB Connection",
            "6. Pre_deployment Scripts (for Mysql)",
            "7. Pre_deployment Scripts (for psql)",
            "8. Pre_deployment Scripts (for mssql)"
        ]
    )

    uploads_folder = uploads_path

    # Initialize session state for storing user inputs
    if 'user_inputs' not in st.session_state:
        st.session_state.user_inputs = {}

    # Display input fields based on user choice
    if user_choice in ["1. Generate TDD documentation", "2. Identify tables and joins"]:
        st.session_state.user_inputs['uploaded_file'] = st.file_uploader("Choose a file", type=['txt', 'sql', 'zip'])

    elif user_choice in ["3. Find Impact analysis", "4. Generate TDD using DB Connection", "5. Identify Joins using DB Connection"]:
        st.session_state.user_inputs['db_type'] = st.selectbox("Select database type:", ["mysql", "psql", "mssql"])
        st.session_state.user_inputs['host'] = st.text_input("Enter host name")
        st.session_state.user_inputs['user'] = st.text_input("Enter user name")
        st.session_state.user_inputs['password'] = st.text_input("Enter password", type="password")
        st.session_state.user_inputs['database'] = st.text_input("Enter database name")

        if user_choice == "3. Find Impact analysis":
            st.session_state.user_inputs['uploaded_file'] = st.file_uploader("Choose a file", type=['txt', 'sql', 'zip'])

    # Button for executing user choice
    if st.button("Proceed"):
        if user_choice in ["1. Generate TDD documentation", "2. Identify tables and joins", "3. Find Impact analysis"]:
            if st.session_state.user_inputs.get('uploaded_file') is not None:
                save_uploaded_file(st.session_state.user_inputs['uploaded_file'], uploads_folder)
                st.success(f"File {st.session_state.user_inputs['uploaded_file'].name} uploaded successfully!")

        if user_choice == "1. Generate TDD documentation":
            user_prompt = "Generate a TDD documentation from the provided SQL query, and output a TDD docx file."
        elif user_choice == "2. Identify tables and joins":
            user_prompt = "Identify the tables and joins in the provided SQL query, and output a csv file."
        elif user_choice == "3. Find Impact analysis":
            prompt_template = """Find Impact analysis from the provided SQL query, and output a csv, xlsx, doc files. 
            Database connection details : db_type={{db_type}}, host={{host}}, user={{user}}, password={{password}}, database={{database}}"""

            template = Template(prompt_template)
            user_prompt = template.render(**st.session_state.user_inputs)
        elif user_choice == "4. Generate TDD using DB Connection":
            prompt_template = """
            establish a db connection using the following connection string 
            db_type={{db_type}}, host={{host}}, user={{user}}, password={{password}}, database={{database}} 
            and extract the schema using retrieve_table_schemas from the database. 
            Then, generate a TDD documentation from the extracted tables and output a single TDD docx file.
            """
            template = Template(prompt_template)
            user_prompt = template.render(**st.session_state.user_inputs)
        elif user_choice == "5. Identify Joins using DB Connection":
            prompt_template = """
            establish a db connection using the following connection string 
            db_type={{db_type}}, host={{host}}, user={{user}}, password={{password}}, database={{database}} 
            and extract all the stored procedures using retrieve_stored_procedures tool from the database. 
            Then, identify the tables and joins in the provided SQL query and output a csv file.
            """
            template = Template(prompt_template)
            user_prompt = template.render(**st.session_state.user_inputs)
        elif user_choice == "6. Pre_deployment Scripts (for Mysql)":
            user_prompt ="Generate the pre_process deployment script by reading the data on the uploaded mysql file on uploads folder and write to the mysql file using the write to sql tool"
        elif user_choice == "7. Pre_deployment Scripts (for psql)":
            user_prompt ="Generate the pre_process deployment script by reading the data on the uploaded psql file on uploads folder and write to the psql file using the write to sql tool"
        elif user_choice == "8. Pre_deployment Scripts (for mssql)":
            user_prompt ="Generate the pre_process deployment script by reading the data on the uploaded mssql file on uploads folder and write to the mssql file using the write to sql tool"

        # Initiate chat with agent
        st.write(f"Executing task: {user_choice}")
        chat = user_proxy.initiate_chat(assistant, message=user_prompt)
        st.write("Task completed.")  # Feedback to user

    else:
        st.write("Please fill in all required fields and click 'Proceed' to execute the task.")