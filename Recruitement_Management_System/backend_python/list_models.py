
import requests
import json

api_key = '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'
url = "https://api.groq.com/openai/v1/models"

headers = {
    "Authorization": f"Bearer {api_key}",
    "Content-Type": "application/json"
}

try:
    print("Listing Groq models...")
    response = requests.get(url, headers=headers)
    print(f"Status Code: {response.status_code}")
    if response.status_code == 200:
        models = response.json()
        print("Available Models:")
        for model in models['data']:
            print(f"- {model['id']}")
    else:
        print("Response Body:")
        print(response.text)
except Exception as e:
    print(f"Error: {e}")
