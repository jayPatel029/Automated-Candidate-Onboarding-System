import fitz # PyMuPDF
import os
from typing import List, Dict
from datetime import datetime
import logging
import textwrap
import requests
from groq import Groq
from dotenv import load_dotenv

load_dotenv()
logger = logging.getLogger(__name__)
client = Groq(api_key=os.getenv("groc_api_key"))


    
    



def call_groq(chunk:str, context_url:str) -> List[Dict[str,str]]:
    try:
        chat_completion = client.chat.completions.create(
            model="llama3-70b-8192",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": f"Source: {context_url}\n\n{chunk}"}
            ],
            temperature=0.3,
            max_completion_tokens=1024,
            response_format={"type": "text"}
        )
        content = chat_completion.choices[0].message.content.strip()
        # return [extract_fields(block, context_url) for block in content.split("\n\n")]

    except Exception as e:
        logger.exception(f"groq call failed for chunk: {e}")
        return []


system_prompt = """
You are a credit card data extraction assistant.

Extract credit card details from the following text and return each card using this format:

Card Name: ...
Bank: ...
Joining Fee: ...
Annual Fee: ...
Rewards: ...
Cashback: ...
Other Features: ...

Use 'N/A' if any detail is missing. Don't return explanations. Just list cards, each as a block of key-value lines.
"""
