#!/usr/bin/env python3
# https://gist.github.com/maybemkl/d9be15bcabadaa19d2ca50c87b59a92e

# requires installation of pandocfilters
# https://pypi.org/project/pandocfilters/

from pandocfilters import toJSONFilter, Str
import re

def replace(key, value, format, meta):
	if key == 'Str':
		if '[[' in value:
			new_value = value.replace('[[', '')
			return Str(new_value)
		if ']]' in value:
			new_value = value.replace(']]', '')
			return Str(new_value)

if __name__ == '__main__':
	toJSONFilter(replace)
