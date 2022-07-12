#!/usr/bin/env python3

import sqlite3
import sys
from contextlib import closing
from os.path import expanduser

TAG_TO_EXCLUDE_1 = 'tasklist'
TAG_TO_EXCLUDE_2 = 'office'


def search_draft():
	str_path_db = expanduser("~") + "/Library/Group Containers/GTFQ98J4YG.com.agiletortoise.Drafts/DraftStore.sqlite"

	with closing(sqlite3.connect(str_path_db)) as connection:
		with closing(connection.cursor()) as cursor:
			rows = cursor.execute(("select ZUUID, ZFOLDER, ZCACHED_TAGS from main.ZMANAGEDDRAFT where ZFOLDER = 0 and ZCACHED_TAGS != 'ZZZ" + TAG_TO_EXCLUDE_1 + "ZZZ' and ZCACHED_TAGS != 'ZZZ" + TAG_TO_EXCLUDE_2 + "ZZZ';")).fetchall()
			return rows


INBOX_DRAFTS = search_draft()
NUMBER_OF_DRAFTS = str(len(INBOX_DRAFTS))
sys.stdout.write(NUMBER_OF_DRAFTS)
