
import requests
import json

api_key = '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'
url = "https://api.groq.com/openai/v1/chat/completions"

headers = {
    "Authorization": f"Bearer {api_key}",
    "Content-Type": "application/json"
}

payload = {
    "model": "llama-3.3-70b-versatile",
    "messages": [{"role": "user", "content": "Hello, are you working?"}]
}

try:
    print("Sending request to Groq...")
    response = requests.post(url, json=payload, headers=headers)
    print(f"Status Code: {response.status_code}")
    print("Response Body:")
    print(response.text)
except Exception as e:
    print(f"Error: {e}")
