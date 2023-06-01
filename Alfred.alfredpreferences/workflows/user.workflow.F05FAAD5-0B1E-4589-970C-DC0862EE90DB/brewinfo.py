import requests
import json
import sys
import subprocess

def get_outdated_list(brewtype='all'):
    if brewtype == 'cask':
        output = subprocess.run(['brew', 'outdated', '--cask', '--json'], capture_output=True, text=True)
    elif brewtype == 'formula':
        output = subprocess.run(['brew', 'outdated', '--json'], capture_output=True, text=True)
    else:
        output = subprocess.run(['brew', 'outdated', '--json'], capture_output=True, text=True)

    outdated_list = json.loads(output.stdout)
    result = {"items": []}
    if 'formulae' in outdated_list:
        for package in outdated_list['formulae']:
            name = package['name']
            installed_version = package['installed_versions'][0]
            current_version = package['current_version']

            result["items"].append({
                "title": f'{name} ({installed_version}) < {current_version}',
                "subtitle": f'Enter to run "brew upgrade {name}"',
                "icon": {
                    "path": "icons/formula_outdated.png" 
                },
                "arg": 'brew upgrade ' + name,
                "autocomplete": name,
                "quicklookurl": f'https://formulae.brew.sh/formula/{name}#default'
            })

    if 'casks' in outdated_list:
        for package in outdated_list['casks']:
            name = package['name']
            installed_version = package['installed_versions'][0]
            current_version = package['current_version']

            result["items"].append({
                "title": f'{name} ({installed_version}) < {current_version}',
                "subtitle": f'Enter to run "brew upgrade --cask {name}"',
                "icon": {
                    "path": "icons/cask_outdated.png" 
                },
                "arg": 'brew upgrade --cask ' + name,
                "autocomplete": name,
                "quicklookurl": f'https://formulae.brew.sh/cask/{name}#default'
            })
    if not result["items"]:
        result["items"].append({
            "title": "Everything is up to date",
            "icon": {
                "path": "icons/check.png"
            },
            "valid": False
        })
    else:
        result["items"].append({
            "title": "Upgrade all",
            "icon": {
                "path": "icons/update_all.png"
            },
            "arg": "brew update && brew upgrade",
            "autocomplete": "Upgrade all",
            "valid": True
        })
    return result

def get_brew_leaves():
    output = subprocess.run(['brew', 'leaves'], capture_output=True, text=True)
    lines = output.stdout.split('\n')
    result = {"items": []}
    for line in lines:
        if not line:
            continue
        result["items"].append({
            "title": line,
            "icon": {
                "path": "icons/leaves.png"
            },
            "arg": line,
            "autocomplete": line,
            "quicklookurl": f'https://formulae.brew.sh/formula/{line}#default'
        })
    return result

def get_brew_list(brewtype='all'):
    if brewtype == 'cask':
        output = subprocess.run(['brew', 'list', '--versions', '--cask'], capture_output=True, text=True)
    elif brewtype == 'formula':
        output = subprocess.run(['brew', 'list', '--versions', '--formula'], capture_output=True, text=True)
    else:
        output = subprocess.run(['brew', 'list', '--versions'], capture_output=True, text=True)
    lines = output.stdout.split('\n')
    result = {"items": []}
    for line in lines:
        if not line:
            continue
        name, version = line.split(' ', 1)

        result["items"].append({
            "title": f'{name} - {version}',
            "icon": {
                "path": "icons/check.png"
            },
            "arg": name,
            "autocomplete": name
        })
    return result

def get_all_formula_names(brewtype):
    if brewtype == 'cask':
        response = requests.get('https://formulae.brew.sh/api/cask.json')
        icon_path = {"path": "icons/cask.png"}
    elif brewtype == 'formula':
        response = requests.get('https://formulae.brew.sh/api/formula.json')
        icon_path = {"path": "icons/brew.png"}
    data = response.json()

    items = []
    for item in data:
        if brewtype == 'cask':
            name = item['name'][0]
            token = item['token']
            try:
                subtitle = name + '  ℹ️ '+ item['desc']
            except:
                subtitle = name
        elif brewtype == 'formula':
            token = item['name']
            subtitle =  item['desc']
        formula = {
            "valid": True,
            "title": token,
            "subtitle": subtitle,
            "arg": token, 
            "icon": icon_path,
            "autocomplete": token,
            "quicklookurl": f'https://formulae.brew.sh/{brewtype}/{token}#default',
            "match": brewtype + ' ' + token
        }
        items.append(formula)
    return items


def get_info(brewtype,formula_name):
    output_data = {"items": []}
    token = formula_name.lower()
    response = requests.get(f'https://formulae.brew.sh/api/{brewtype}/{token}.json')
    info_page = f'https://formulae.brew.sh/{brewtype}/{token}#default'
    data = response.json()
    if brewtype == 'cask':
        version = data['version']
        auto_update = '\t🔄 Auto updates = ✅' if data['auto_updates'] == True else '\t🔄 Auto updates = ❌'
        version_info = f'Newest version: {version}, {auto_update}'
    elif brewtype == 'formula':
        if data['versions']['bottle'] == True:
            version = data['versions']['stable'] + ' (bottle)'
        else:  
            version = data['versions']['stable']
        version_info = f'Newest version: {version}'
    output_data['items'].extend([
        {
            "valid": True,
            "title": data['homepage'],
            "subtitle": "Open homepage",
            "arg": data['homepage'],
            "icon": {"path": "icons/homepage.png"},
        },
        {
            "valid": True,
            "title": info_page,
            "subtitle": "Open brew.sh info page",
            "arg": info_page,
        },
        {
            "valid": False,
            "title": f"Installs (30 days): {data['analytics']['install']['30d'][token]}\t(90 days): {data['analytics']['install']['90d'][token]}\t (365 days): {data['analytics']['install']['365d'][token]}",
            "icon": {"path": "icons/hot.png"},
        },
        {
            "valid": False,
            'title': version_info,
            "icon": {"path": "icons/version.png"},
        }
    ])
    return output_data


if  __name__ == '__main__':
    output_data = {"items": []}
    if sys.argv[1] == 'all':
        output_data['items'].extend(get_all_formula_names(brewtype='cask'))
        output_data['items'].extend(get_all_formula_names(brewtype='formula'))
    elif sys.argv[1] == 'list':
        output_data = get_brew_list()
    elif sys.argv[1] == 'leaves':
        output_data = get_brew_leaves()
    elif sys.argv[1] == 'get_info':
        try:
            output_data = get_info('cask',sys.argv[2])
        except:
            output_data = get_info('formula',sys.argv[2])
    if sys.argv[1] == 'outdated':
        output_data = get_outdated_list()
        
    print(json.dumps(output_data))