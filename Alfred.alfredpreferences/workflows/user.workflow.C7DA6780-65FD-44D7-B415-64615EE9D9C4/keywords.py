#!/usr/bin/python3
from Alfred3 import Items, Tools
from Workflows import Workflows

wf = Workflows()
alf = Items()
wpath = f"{Tools.getEnv('plist_path')}/info.plist"

keyword_list = wf.get_item(wpath).get('keywords')
if keyword_list:
    for k in keyword_list:
        withspace = k.get('withspace')
        keyw = k.get('keyword')
        keyword = f'{keyw} ' if withspace and keyw else keyw
        title = k.get('title')
        text = k.get('text')
        if keyword:
            alf.setItem(
                title=title,
                subtitle=f'Press \u23CE to proceed with Keyword: {keyword}',
                arg=keyword
            )
            alf.setIcon('icons/start.png', m_type='image')
            alf.addItem()
else:
    alf.setItem(
        title="This workflow has not keywords defined",
        valid=False
    )
alf.write()
