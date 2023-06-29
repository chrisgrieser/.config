import json
import sys
import http.client
from urllib.parse import quote


def get_spell_check(text):
    conn = http.client.HTTPSConnection("services.gingersoftware.com")

    conn.request(
        "GET",
        "/Ginger/correct/jsonSecured/GingerTheTextFull?clientVersion=2.0&lang=US&text="
        + quote(text)
        + "&apiKey=6ae0c3a0-afdc-4532-a810-82ded0054236",
    )

    res = conn.getresponse()
    data = res.read()
    conn.close()
    return json.loads(data.decode("utf-8"))


def process_data(text, data):
    result = text

    for suggestion in reversed(data["Corrections"]):
        start = suggestion["From"]
        end = suggestion["To"]

        if suggestion["Suggestions"]:
            suggest = suggestion["Suggestions"][0]
            result = result[:start] + suggest["Text"] + result[end + 1 :]

    return result


if __name__ == "__main__":
    ALFRED_QUERY = " ".join(sys.argv[1:])
    data = get_spell_check(ALFRED_QUERY)
    sys.stdout.write(process_data(ALFRED_QUERY, data))
