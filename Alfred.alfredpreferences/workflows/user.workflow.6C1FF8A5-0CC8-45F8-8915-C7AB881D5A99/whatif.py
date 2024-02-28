# encoding: utf-8

import sys
import os
from workflow import Workflow3, ICON_WEB, ICON_INFO, web

GITHUB_SLUG = 'zjn0505/xkcd-alfred'
VERSION = open(os.path.join(os.path.dirname(__file__),
                            'version')).read().strip()

def get_suggestions():
    global query
    if query == None or query == "":
        url = 'https://api.jienan.xyz/xkcd/what-if-top?size=10&sortby=thumb-up'
    else:
        url = 'https://api.jienan.xyz/xkcd/what-if-suggest?size=10&q=' + query

    url = url.replace(" ", "%20")
    r = web.get(url)
    log.debug(url)

    # throw an error if request failed
    # Workflow will catch this and show it to the user
    r.raise_for_status()

    # Parse the JSON returned by pinboard and extract the posts
    return r.json()

def get_latest():
    url = 'https://api.jienan.xyz/xkcd/what-if-list?start=0&reversed=1&size=5'
    r = web.get(url)

    # throw an error if request failed
    # Workflow will catch this and show it to the user
    r.raise_for_status()

    # Parse the JSON returned by pinboard and extract the posts
    return r.json()

def main(wf):
    global query

    if len(wf.args):
        query = wf.args[0]
    else:
        query = None

    posts = wf.cached_data('what-if-'+query, get_suggestions, 86400)

    if query == None or query == "":
        newPosts = wf.cached_data('new-what-if', get_latest, 3600)
        for item in posts:
            if item not in newPosts:
                newPosts.append(item)
        posts = newPosts
    
    # Loop through the returned posts and add an item for each to
    # the list of results for Alfred
    for post in posts:
        wf.add_item(title=("%d - %s" % (post['num'], post['title'])),
                # subtitle=post['alt'],
                arg="https://what-if.xkcd.com/%d" % post['num'],
                valid=True,
                # quicklookurl=post['img'],
                autocomplete=post['title'],
                icon=ICON_WEB)

    # Send the results to Alfred as XML
    wf.send_feedback()

if __name__ == u"__main__":
    update_settings = {'github_slug': GITHUB_SLUG, 'version': VERSION}
    wf = Workflow3(update_settings=update_settings)
    log = wf.logger
    if wf.update_available:
        wf.add_item(u'New version available',
                    u'Action this item to install the update',
                    autocomplete=u'workflow:update',
                    icon=ICON_INFO)
    sys.exit(wf.run(main))
