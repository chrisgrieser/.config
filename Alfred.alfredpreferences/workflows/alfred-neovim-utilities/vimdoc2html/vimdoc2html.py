#!/usr/bin/env python
#-*- coding: utf-8 -*-
#
# Copyright (C) 2014 xaizek <xaizek@posteo.net>
#
# This file is part of vimdoc2html.
#
# vimdoc2html is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# vimdoc2html is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with vimdoc2html.  If not, see <http://www.gnu.org/licenses/>.

"""\
Converts Vim documentation into HTML.

Output is written to <source file>.html.

As part of the process, tags file is created at the location of the source file.
"""

import argparse
import io
import os
import os.path as path
import subprocess

import vimd2h

TEMPLATE = u'''\
<html>
    <head>
        <title>{title}</title>
        <style>{style}</style>
    </head>
    <body>
        <pre>
        {html}
        </pre>
    </body>
</html>\
'''

script_dir = path.dirname(path.realpath(__file__))

# parse command-line arguments
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('-r', '--raw', dest='raw', action='store_true',
                    help="Don't wrap output into template")
parser.add_argument('vimdoc', nargs=1, help='Vim documentation file')
args = parser.parse_args()
raw_output = args.raw
src_filename = args.vimdoc[0]
src_dir = path.dirname(src_filename) or '.'

# generate tags file
subprocess.call([path.join(script_dir, 'helpztags'), src_dir])

tags_path = path.join(src_dir, 'tags')
css_path = path.join(script_dir, 'vimhelp.css')
html_path = '%s.html' % src_filename;

# read in all external files
with io.open(tags_path, 'r', encoding='utf-8') as tags_file:
    tags = tags_file.read()
with io.open(src_filename, 'r', encoding='utf-8') as doc_file:
    contents = doc_file.read()
with io.open(css_path, 'r', encoding='utf-8') as css_file:
    style = css_file.read()

# produce formatted html
html = vimd2h.VimDoc2HTML(tags).to_html(contents)

# output result
with io.open(html_path, 'w', encoding='utf-8') as html_file:
    if raw_output:
        html_file.write(html)
    else:
        html_file.write(
                TEMPLATE.format(title=path.basename(src_filename),
                                style=style,
                                html=html))
