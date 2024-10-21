
from openai import AzureOpenAI


def Generate_azure_openai(system_prompt, text):
    print("Started OPENAI")
    
    AZURE_OPENAI_API_KEY = 'ef29eaa3ecd04bc1b582e40759708c9e'
    AZURE_OPENAI_ENDPOINT = 'https://langchain-poc.openai.azure.com/'
    AZURE_MODEL = 'langchain-poc-gpt35-turbo-0125'

    endpoint = f"{AZURE_OPENAI_ENDPOINT}"
    key = f"{AZURE_OPENAI_API_KEY}"
    deployment_name = f"{AZURE_MODEL}"
    
    client = AzureOpenAI(
        azure_endpoint=endpoint, 
        api_key=key,  
        api_version="2024-02-01"
    )

    response = client.chat.completions.create(
        model=deployment_name,
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": text}
        ],
        max_tokens=4000
    )
    
    return response.choices[0].message.content