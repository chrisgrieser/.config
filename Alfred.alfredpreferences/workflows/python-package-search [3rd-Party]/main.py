from packaging.version import parse
import urllib.request
import json
import sys
import os


COMMAND = sys.argv[1]
QUERY = sys.argv[2]

LIB, RELEASES_MODE, VERSION = QUERY.partition("/")
LIB = LIB.strip()

HEADERS = {"Accept": "application/vnd.pypi.simple.v1+json"}

FETCH_LIST_COMMAND = "pypied-fetch-pypi-list"
SEARCH_COMMAND = "pypied-search-pypi-list"


def fetch_pypi_list():
    url = "https://pypi.org/simple/"
    req = urllib.request.Request(url, headers=HEADERS)
    with urllib.request.urlopen(req) as response:
        content = response.read()
        content_str = content.decode("utf-8")

    with open("pypi-data.json", "w", encoding="utf-8") as json_file:
        json_file.write(content_str)


def search_pypi(query):
    if not os.path.exists("pypi-data.json"):
        fetch_pypi_list()

    with open("pypi-data.json", "r", encoding="utf-8") as json_file:
        data_str = json_file.read()
        data = json.loads(data_str)

    results = [
        project for project in data["projects"] if project["name"].startswith(query)
    ]
    return results[:9]


def fetch_lib(lib):
    url = f"https://pypi.org/pypi/{lib}/json"
    req = urllib.request.Request(url, headers=HEADERS)

    with urllib.request.urlopen(req) as response:
        content = response.read()
        content_str = content.decode("utf-8")
        data = json.loads(content_str)

    project_urls = data["info"].get("project_urls") or {
        "Documentation": "",
        "Homepage": "",
        "Repository": "",
    }

    lib_info = {
        "title": lib,
        "summary": data["info"].get("summary", ""),
        "latest_version": data["info"].get("version", ""),
        "project_url": data["info"].get("project_url", ""),
        "documentation_url": project_urls.get("Documentation", ""),
        "homepage_url": project_urls.get("Homepage", ""),
        "repository_url": project_urls.get("Repository", ""),
        "releases": sorted(data.get("releases", {}).keys(), key=parse, reverse=True)[
            :9
        ],
    }
    return lib_info


def get_formatted_search_results(search_results):
    formatted_results = []
    for i, item in enumerate(search_results):
        ## Only fetch details for first 3 items to avoid rate limit
        if i < 3:
            try:
                lib_info = fetch_lib(item["name"])
            except Exception:
                lib_info = {"summary": "", "latest_version": ""}
        else:
            lib_info = {"summary": "", "latest_version": ""}

        result = {
            "title": f"{item['name']} {lib_info['latest_version']}",
            "subtitle": f"{lib_info['summary']}",
            "arg": f"{item['name']}/{lib_info['latest_version']}",
            "autocomplete": item["name"],
            "icon": {"path": "./images/pypi-logo.svg"},
        }
        formatted_results.append(result)

    return formatted_results


def get_formatted_release_results(search_results):
    formatted_results = []
    for item in search_results:
        result = {
            "title": item,
            "subtitle": "",
            "arg": f"{LIB}/{item}",
            "autocomplete": item,
            "icon": {"path": "./images/pypi-logo.svg"},
        }
        formatted_results.append(result)

    return formatted_results


def get_alfred_items(search_results):
    if len(search_results) == 0:
        if COMMAND == FETCH_LIST_COMMAND:
            return [
                {
                    "title": "List of pypi packages is updated.",
                    "subtitle": "Enter in a new search term or update list of packages with 'pypi-fetch'",
                    "icon": {"path": "./images/pypi-logo.svg"},
                }
            ]
        if LIB:
            return [
                {
                    "title": "No packages found.",
                    "subtitle": "Enter in a new search term or update list of packages with 'pypi-fetch'",
                    "icon": {"path": "./images/pypi-logo.svg"},
                }
            ]
        else:
            return [
                {
                    "title": "Enter a library name ...",
                    "subtitle": "from pypi",
                    "icon": {"path": "./images/pypi-logo.svg"},
                }
            ]

    if RELEASES_MODE:
        return get_formatted_release_results(search_results)
    else:
        return get_formatted_search_results(search_results)


if __name__ == "__main__":
    if not os.path.exists("pypi-data.json"):
        fetch_pypi_list()

    search_results = []

    if COMMAND == FETCH_LIST_COMMAND:
        fetch_pypi_list()

    if COMMAND == SEARCH_COMMAND and LIB:
        search_results = search_pypi(LIB)

    if COMMAND == SEARCH_COMMAND and LIB and RELEASES_MODE:
        lib_info = fetch_lib(LIB)
        search_results = lib_info["releases"]

    alfred_json = json.dumps({"items": get_alfred_items(search_results)}, indent=2)

    sys.stdout.write(alfred_json)
