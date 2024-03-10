### Overview ###

This is a script to convert Vim documentation file into HTML.

### Dependencies ###

* Perl
* Python

### Description ###

The basic usage is:

```bash
./vimdoc2html.py plugin.txt
```

or if the script is somewhere in the `$PATH`:

```bash
vimdoc2html.py plugin.txt
```

The only "advanced" usage is currently enabled by `-r` or `--raw` flag, in which
case instead of outputting complete standalone HTML page only minimal output is
produced.  This way after customizing style/template only the contents can be
replaced.

### Credit ###

HTML formatting is performed via modified version of
[vimh2h.py](https://github.com/c4rlo/vimhelp/blob/master/vimh2h.py) by Carlo
Teubner <(first name) dot (last name) at gmail dot com>.  This one is simplified
to remove unused here code and a bit improved to add anchors to each tag
definition.  CSS style is from
[there too](https://github.com/c4rlo/vimhelp/blob/master/static/vimhelp.css).

Tags are extracted via `helpztags` tool written by Jakub Turski
<yacoob@chruptak.plukwa.net> and Artur R. Czechowski <arturcz@hell.pl>.  It's
supplied alongside for convenience and to provide a couple of changes, see
there.
