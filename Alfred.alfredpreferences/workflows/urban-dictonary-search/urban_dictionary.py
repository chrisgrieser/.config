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
        thumbs_up_sign = "\U0001F44D"
        thumbs_down_sign = "\U0001F44E"
        title = f"{word}  {thumbs_up_sign} {thumbs_up_cnt}  {thumbs_down_sign} {thumbs_down_cnt}"
        wf.add_item(
            valid=True,
            title=title,
            subtitle=result["definition"],
            arg=result["permalink"],
        )

    return wf.send_feedback()


if __name__ == "__main__":
    wf = Workflow(help_url=HELP_URL)
    sys.exit(wf.run(main))
