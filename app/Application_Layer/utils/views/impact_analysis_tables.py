from app.Model_Layer.models.autogen_ai import autogen_main
import json
import pandas as pd
from app.Application_Layer.services import db_state
from jinja2 import Template

def generate_table_analysis(existing_table_name, proposed_script):
    db, cursor = db_state.db_con, db_state.db_cursor

    # MsSQL server table definition
    # SELECT s.name as schema_name, t.name as table_name, c.* FROM sys.columns AS c
    # INNER JOIN sys.tables AS t ON t.object_id = c.object_id
    # INNER JOIN sys.schemas AS s ON s.schema_id = t.schema_id
    # WHERE t.name = '{existing_table_name[0]}' AND s.name = 'dbo';
    table_definition_template_string="""
    {% if db_type == 'mysql' %}
    SELECT TABLE_SCHEMA AS schema_name, TABLE_NAME AS table_name, COLUMN_NAME, DATA_TYPE
    FROM information_schema.COLUMNS
    WHERE TABLE_NAME = '{{existing_table_name}}'
    AND TABLE_SCHEMA = '{{db_name}}';
    {% elif db_type == 'mssql' %}
    SELECT s.name as schema_name, t.name as table_name, c.* FROM sys.columns AS c
    INNER JOIN sys.tables AS t ON t.object_id = c.object_id
    INNER JOIN sys.schemas AS s ON s.schema_id = t.schema_id
    WHERE t.name ={{existing_table_name}} AND s.name = 'dbo';
    {% elif db_type == 'psql' %}
    select * from employees;
    {% endif %}
    """
    db_type = db_state.db_type
    template1=Template(table_definition_template_string)

    existing_table_script = []

    for existing_table_name in existing_table_name:
        table_definition = template1.render(db_type=db_type, existing_table_name=existing_table_name, db_name = db_state.db_name)
        cursor.execute(table_definition)
        existing_table_script.append(cursor.fetchall())

    print("Table definition from db: ", existing_table_script)

    prompt = f"""
    Your task is to find the impact from the proposed script. Ensure that all column changes are detected.
    It should return the response as JSON in the following format:
    [{{"Table_name": "<table_name>","Impact_column": "<column_name>", "Description": "<Changes description>"}}]



    -------------------------------------

    Proposed_script = {proposed_script}
    """
    
    return autogen_main(assistant_name="Database Administrator (DBA)",
        assistant_sys_msg="You are a helpful AI assistant you can find what I expect",
        agent_name="Database Administrator (DBA) Agent",
        agent_sys_message="You are expertise in Database. So you could assist me.",
        prompt=prompt)

def table_analysis_response(existing_table_name, proposed_script):
    autogen_response = generate_table_analysis(existing_table_name, proposed_script)
    print(autogen_response.replace('```', '').replace('json', '').replace('```', ''))
    
    autogen_json = json.loads(autogen_response.replace('```', '').replace('json', '').replace('```', ''))
    if type(autogen_json) != list:
        autogen_json = [autogen_json]

    return autogen_json
