import autogen
import os
base_path = os.path.dirname(os.path.abspath(__file__))
def autogen_configuration():
    llm_config = {
    "timeout": 600,
    "cache_seed": 44,  # change the seed for different trials
    "config_list": autogen.config_list_from_json(
        base_path+"/config/OAI_CONFIG_LIST.json",
        filter_dict={"model": ["assitant-api-poc","elsai-gpt-4-vision"]},
    ),
    "temperature": 0.5,
    "max_tokens":2000
    }
    return llm_config

def autogen_assistant(**kwargs):
    
    assistant = autogen.AssistantAgent(
    name=kwargs['assistant_name'],
    system_message=kwargs['assistant_sys_msg'],
    llm_config=kwargs['llm_config'],
    )
    
    return assistant

def autogen_agent(**kwargs):
    llm_config = autogen_configuration()
    
    user_proxy = autogen.UserProxyAgent(
    name=kwargs['agent_name'],
    human_input_mode="NEVER",
    system_message=kwargs['agent_sys_message'],
    max_consecutive_auto_reply=0,
    code_execution_config={
        "work_dir": "work_dir",
        "use_docker": False,
    },
    llm_config=llm_config
    )
    return user_proxy

def user_questions(**kwargs):
    
    assistant = autogen_assistant(assistant_name=kwargs['assistant_name'],
                                  assistant_sys_msg=kwargs['assistant_sys_msg'],
                                  llm_config = kwargs['llm_config'])
    
    proxy_agent = autogen_agent(agent_name=kwargs['agent_name']
              ,agent_sys_message=kwargs['agent_sys_message'])
    
    response  = proxy_agent.initiate_chat(assistant, message=kwargs['prompt'])
    return response


def user_prompt():
    with open('prompt.txt','r') as r:
        prompt = r.read()
    return prompt

def autogen_main(**kwargs):
    llm_config = autogen_configuration()
    
    assistant_name = kwargs['assistant_name']
    assistant_sys_msg = kwargs['assistant_sys_msg']
    llm_config = llm_config

    agent_name = kwargs['agent_name']
    agent_sys_message = kwargs['agent_sys_message']
    prompt_concat = kwargs['prompt']
    agent_response = user_questions(assistant_name=assistant_name,
                               assistant_sys_msg=assistant_sys_msg,
                               llm_config=llm_config,
                               agent_name=agent_name,
                               agent_sys_message=agent_sys_message,
                               prompt=prompt_concat)
    return agent_response.chat_history[-1]['content']

# autogen_main(assistant_name="Database Administrator (DBA)",
#         assistant_sys_msg="You are a helpful AI assistant you can find what I expect",
#         agent_name="Database Administrator (DBA) Agent",
#         agent_sys_message="You are expertise in Database. So you could assist me.",
#         prompt=prompt
        # )