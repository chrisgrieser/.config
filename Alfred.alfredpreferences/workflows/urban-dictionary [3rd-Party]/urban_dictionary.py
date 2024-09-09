#!/usr/bin/env python3
#
# Copyright © 2018 Arthur Pinheiro
#
# MIT Licence. See http://opensource.org/licenses/MIT

""""Alfred workflow aimed to search Urban Dictionary."""

import sys

from workflow import Workflow, web

HELP_URL = "https://github.com/xilopaint/alfred-urban-dictionary"


def main(wf):  # pylint: disable=redefined-outer-name
    """Run workflow."""
    query = wf.args[0]
    param = {"term": query}
    url = "http://api.urbandictionary.com/v0/define"
    r = web.get(url, params=param)
    r.raise_for_status()
    data = r.json()

    results = data["list"]

    for result in results:
        word = result["word"]
        thumbs_up_cnt = result["thumbs_up"]
        thumbs_down_cnt = result["thumbs_down"]
        upvote_char = chr(9650)
        downvote_char = chr(9660)
        title = f"{word}  {upvote_char} {thumbs_up_cnt}  {downvote_char} {thumbs_down_cnt}"
        definition = result["definition"].replace("[", "").replace("]", "")
        permalink = result["permalink"]

        item = wf.add_item(
            valid=True,
            title=title,
            subtitle=definition,
            arg=permalink,
        )

        item.add_modifier(
            key="cmd",
            subtitle="Show Definition in Large Type",
            arg=definition,
        )

    return wf.send_feedback()


if __name__ == "__main__":
    wf = Workflow(help_url=HELP_URL)
    sys.exit(wf.run(main))
