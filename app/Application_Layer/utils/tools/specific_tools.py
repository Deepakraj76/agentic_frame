from app.Model_Layer.models import autogen_ai
from app.Application_Layer.prompts import llm_prompts
from app.Application_Layer.utils.views.impact_analysis_tables import table_analysis_response
from app.Application_Layer.utils.views.impact_analysis_sp import find_sp_definition
import json


prompt_for_identify = llm_prompts.identify_table_prompt()

def identify_table_and_joins(zip_content: dict) -> dict:
    """
    Identifies tables, joins, and join conditions from the given SQL chunks.
    
    Params:
        zip_content (dict): A dictionary where keys are file names, and values contain the file content.
    
    Output:
        A dictionary where each key is a file name and the value is the analysis result for that file.
        Example:
        { 
          'file1.sql': [{'Table': 'table1', 'Join': 'INNER JOIN', 'Join Condition': '...'}],
          'file2.sql': [...]
        }
    """
    responses = {}
    for file_name, data in zip_content.items():
        prompt = f"""
        {prompt_for_identify}

        FILE NAME : {file_name}

        {data}

        """
        response = autogen_ai.autogen_main(
        assistant_name="Database Administrator (DBA)",
        assistant_sys_msg="You are a helpful AI assistant who can find what I expect",
        agent_name="Database Administrator (DBA) Agent",
        agent_sys_message="You are an expert in Database. So you could assist me.",
        prompt=prompt
        )
        responses[file_name] = response
    return responses

prompt_for_tdd = llm_prompts.ttd_prompt()

def generate_tdd(chunks:list,table_names:list)->list:
  final_response=[]
  for i in range (len(chunks)):
    s=chunks[i]
    t=table_names[i]
    prompt_with_schema = f"""
                          {prompt_for_tdd}

                          table_name : {t}

                          {s}
                          """

    response= autogen_ai.autogen_main(assistant_name="TDD_document_Writer",
          assistant_sys_msg="You are a helpful AI assistant you can find what I expect",
          agent_name="TDD_document_creating_Agent",
          agent_sys_message="You are expertise in Database. So you could assist me.",
          prompt=prompt_with_schema
          )
    final_response.append(response)
  return final_response


def table_impact_analysis(exist_table: list, proposed_script: str) -> str:
    print(exist_table,"TTTTTTTTTTTTTTTTTTTTT")
    """Compares the existing table with the proposed script to find impacted columns."""
    table_analysis = table_analysis_response(exist_table, proposed_script)
    # print("CSV file created successfully")
    return table_analysis

def impact_analysis_tool(impacted_columns_json: str, exist_table: list) -> str:
    """Generates the list of impacted stored procedures based on the impacted columns."""
    impacted_columns = json.loads(impacted_columns_json) # since data is passed as string by the agent.

    sp_list = find_sp_definition(exist_table, impacted_columns)
    print("XLSX and DOCX file created successfully...")
    return sp_list