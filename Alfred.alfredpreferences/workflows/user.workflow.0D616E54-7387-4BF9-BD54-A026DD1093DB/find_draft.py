#!/usr/bin/env python3

import sqlite3
import sys
import time
import json
import re
import unicodedata as ud
from contextlib import closing
from os.path import expanduser
import os

# tags not to display in search
TAG_TO_EXCLUDE = os.getenv('tagToExcludeFromSearch')


def search_draft(str_search):
	str_path_db = expanduser("~") + "/Library/Group Containers/GTFQ98J4YG.com.agiletortoise.Drafts/DraftStore.sqlite"

	with closing(sqlite3.connect(str_path_db)) as connection:
		with closing(connection.cursor()) as cursor:
			rows = cursor.execute(("select ZUUID, ZCONTENT, ZCREATED_AT, ZCHANGED_AT, ZCACHED_TAGS, ZFOLDER, ZFLAGGED from main.ZMANAGEDDRAFT where ZCONTENT like '%{}%' and ZFOLDER = 0 and ZCACHED_TAGS != 'ZZZ" + TAG_TO_EXCLUDE + "ZZZ';").format(str_search)).fetchall()  # type: ignore
			return rows

# draft ZFOLDER codes: Inbox = 0, Archive = 1, Trash = 10000
# the condition at the end of line "rows = cursor.execute" filters for drafts in the Inbox not being a tasklist.
# draft ZFLAGGED codes: unflagged = 0, flagged = 1


STR_ARG = ' '.join(sys.argv[1:])
# Normalise any decomposed UTF-8 text from Alfred to composed UTF-8 test to use with SQLite
STR_ARG = ud.normalize('NFC', STR_ARG)

INT_SQLLITE_EPOCH = 978307200
draftMatch = search_draft(STR_ARG)
arr_items = []
for x in draftMatch:
	json_item = {}

	# flagged status
	is_flagged = x[6]
	if is_flagged == 1:
		DRAFT_FLAGGED = "🟠 "
	else:
		DRAFT_FLAGGED = ""

	# remove markdown from title for readability
	draftTitle = x[1].partition('\n')[0]
	draftTitle = re.sub(r'(^#* |\*\*|^- )', '', draftTitle, 0)

	# edit the ZCACHED_TAGS for readability
	draft_tags = x[4][3:-3]
	# draft_tags = draft_tags.replace("ZZZ ZZZ", ", ")
	tags_arr = draft_tags.split("ZZZ ZZZ")

	# title
	json_item['title'] = DRAFT_FLAGGED + draftTitle

	# subtitle construction
	# use "%e. %b %Y %H:%M" for date and time
	json_item['subtitle'] = time.strftime('%e %b', time.localtime(x[3] + INT_SQLLITE_EPOCH))
	if len(draft_tags) != 0:
		json_item['subtitle'] += " ◼︎ #" + "  #".join(tags_arr)

	# UUID
	json_item['arg'] = x[0]
	json_item['uid'] = x[0]
	arr_items.append(json_item)

# new draft option
newdraft = {}
newdraft['title'] = "new Draft with title: '" + STR_ARG + "'"
newdraft['arg'] = STR_ARG
newdraft['icon'] = {"path": "new draft.png"}
newdraft['uid'] = 'newdraft'
arr_items.append(newdraft)

# jsonfy
obj_output = {"items": arr_items}
sys.stdout.write(json.dumps(obj_output))
