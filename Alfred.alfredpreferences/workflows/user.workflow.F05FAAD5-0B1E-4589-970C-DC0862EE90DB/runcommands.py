import sys
import requests
import json
from brewinfo import get_brew_list
from brewinfo import get_info

def check_formula_and_compare_versions(formula_name, version):
    brew_list = get_brew_list()
    for item in brew_list["items"]:
        if item["arg"] == formula_name:
            installed_version = item["title"].split(' ')[2]
            if installed_version == version:
                return "Installed and version matches.", installed_version
            else:
                return "Installed but version does not match.", installed_version
    return "Formula not installed.", None

def get_commands(brewtype,formula_name):
    token = formula_name.lower()
    info_command = 'brew info '+ token
    if brewtype == 'cask':
        response = requests.get('https://formulae.brew.sh/api/cask/'+token+'.json')
        install_command = 'brew install --cask '+ token
        uninstall_command = 'brew uninstall --cask '+ token
        upgrade_command = 'brew upgrade --cask '+ token
    elif brewtype == 'formula':
        response = requests.get('https://formulae.brew.sh/api/formula/'+token+'.json')
        install_command = 'brew install '+ token
        uninstall_command = 'brew uninstall '+ token
        upgrade_command = 'brew upgrade '+ token
    data = response.json()
    if brewtype == 'cask':
        name = data['name'][0]
        version = data['version']
    elif brewtype == 'formula':
        name = data['name']
        version = data['versions']['stable']
    output_data = {
        "items": [
            {
            "title": "Back to search",
            "arg": 1,
            "icon": {"path": "icons/back.png"},
            "valid": True
            }
        ]
    }
    status, installed_version = check_formula_and_compare_versions(token, version)
    if status == "Formula not installed.":
        output_data["items"].extend([
        {
            "valid": True,
            "title": 'Not installed. Enter to install.',
            "arg": install_command,
            "subtitle": install_command,
            "icon": {"path": "icons/install.png"},
        },
        {
            "valid": True,
            "subtitle": info_command,
            "title": "Run info command of "+ name,
            "arg": info_command,
            "icon": {"path": "icons/info.png"},
        },
        ])
    elif status == "Installed and version matches.":
        output_data["items"].extend([
        {
            "valid": False,
            "title": 'Great! You are up to date.',
            "icon": {"path": "icons/uptodate.png"},
        },
        {
            "valid": True,
            "subtitle": uninstall_command,
            "title": f"Uninstall {name}, command + enter to clean uninstall.",
            "arg": uninstall_command,
            "icon": {"path": "icons/uninstall.png"},
            "mods": {
                "cmd": {
                    "valid": True,
                    "subtitle": "brew uninstall --force --zap --cask "+ name,
                    "arg": "brew uninstall --force --zap --cask "+ name,
                },
        },
        },
        ])
    elif status == "Installed but version does not match.":
        output_data["items"].extend([
        {
            "valid": True,
            "title": 'Version mismatch, installed '+ installed_version+ ' < '+ version,
            "subtitle": "Enter to force upgrade cask.",
            "icon": {"path": "icons/outdated.png"},
            "arg": upgrade_command
        },
        {
            "valid": True,
            "title": uninstall_command,
            "subtitle": "Run uninstall command of "+ name,
            "arg": uninstall_command,
            "icon": {"path": "icons/uninstall.png"},
        },
        ])
    return output_data

if __name__ == '__main__':
    output_data = {"items": []}
    if sys.argv[1] == '':
        output_data = {
        "items": [
            {
            "title": "Back to search",
            "arg": 1,
            "icon": {"path": "icons/back.png"},
            "valid": True
            }
        ]}
    else:
        try:
            output_data = get_commands('cask',sys.argv[1])
            output_data['items'].extend(get_info('cask',sys.argv[1])['items'])
        except:
            output_data = get_commands('formula',sys.argv[1])
            output_data['items'].extend(get_info('formula',sys.argv[1])['items'])
    print(json.dumps(output_data))