"""This is a test file."""

import requests

files = [("file", ("file", Path.open("/path/to/file.pdf", "rb"), "application/octet-stream"))]
headers = {"x-api-key": "sec_xxxxxx"}

response = requests.post(
    "https://api.chatpdf.com/v1/sources/add-file", headers=headers, files=files,
)

if response.status_code == 200:
    print("Source ID:", response.json()["sourceId"])
else:
    print("Status:", response.status_code)
    print("Error:", response.text)
