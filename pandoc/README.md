---
aliases: 
tags: pandoc, citation, css, coding
similar: 
- [[Citation Styles]]
- [[Bibliography Creation]]
obsidianUIMode: preview
---

# Pandoc
> [!INFO]
> This note is a symlink to `pandoc/README.md` in [my dotfile directory](https://github.com/chrisgrieser/dotfiles)

## Table of Contents
<!-- MarkdownTOC -->

- [Tutorials](#tutorials)
- [Tools](#tools)
- [Priority of Options](#priority-of-options)
- [How Templating works](#how-templating-works)
- [Useful Snippets](#useful-snippets)
- [Templates](#templates)
- [Filters](#filters)

<!-- /MarkdownTOC -->

## Tutorials
- [Pandoc and Obsidian - Create slideshows, PDFs and Word documents - Obsidian Publish](https://publish.obsidian.md/hub/04+-+Guides%2C+Workflows%2C+%26+Courses/Community+Talks/YT+-+Pandoc+and+Obsidian+-+Create+slideshows%2C+PDFs+and+Word+documents)

## Tools
- Most user-friendly: [docdown](https://github.com/lowercasename/docdown)
- via [Shell Commands Plugin in Obsidian](https://github.com/Taitava/obsidian-shellcommands) and this code:

```bash
export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH ; {{folder_path:absolute}}/{{file_name}} -o {{folder_path:absolute}}/{{title}}.docx --citeproc --bibliography=/Users/matt/Documents/zotero.bib --csl=/Users/matt/Documents/apa.csl --reference-doc=/Users/matt/Documents/essay-template2.docx
```

## Priority of Options
__Higher overwrites lower__
1. Direct CLI arguments
2. Arguments from the defaults-file (`--defaults`) (default location: `~/.pandoc/defaults`)
3. Another defaults file imported in the defaults file. (`defaults: entry`)
4. Metadata set as CLI argument (`--metadata`)
5. YAML of the Document (in the docs mostly referred to as "Metadata")
6. `--metadata-file` (default location: `~/.pandoc/metadata`)

> Options specified in a defaults file itself always have priority over those in another file included with a `defaults: entry`.  
> – [Pandoc Docs](https://pandoc.org/MANUAL.html#defaults-files)

> `--metadata=KEY[:VAL]`: (…) A value specified on the command line overrides a value specified in the document using YAML metadata blocks. (…)  
> `--metadata-file=FILE`: (…) Generally, the input will be handled the same as in YAML metadata blocks. This option can be used repeatedly to include multiple metadata files; values in files specified later on the command line will be preferred over those specified in earlier files. Metadata values specified inside the document, or by using -M, overwrite values specified with this option.  
> – [Pandoc Docs](https://pandoc.org/MANUAL.html#option--metadata)

## How Templating works
> yeah, the pandoc docs aren't really good in explaining templates. So for odt, pptx, and docs, pandoc calls templates "reference documents" (`--reference-doc`), where you style a docx (etc) document and when selected as reference for a docx output, the output gets styled the same way as that document.
>
> for *all* other output formats you need actual templates (`--template`), which depend on the output format (html template + css for html output, etc.). Most notoriously, for a PDF output, the type of template you need depends on the pdfengine (`--pdf-engine`) you use are using, since pandoc does not directly convert to pdf, but converts to PDf via something like an "intermediate format". In most cases, it's either a html-based pdf-engine (e.g. `wkhtmltopdf`) in which case you need a html and css template (and need to know html and css for that), or a latex-based pdf-engine (e.g. `pdflatex`), in which case the template needs to be written in latex. And to make it even more complicated, in both cases, there are some variables for the templates (e.g. margins) which can be set in the yaml-metadata of the markdown document.
>
> So if you want PDF output, you either have to learn html/css, latex, or simply export to docx (and convert the docx to a pdf), with the latter being probably the easiest approach.

__Summary__
- output format is `docx` or `pptx`, you need a reference-document in those formats, where you have pre-applied all your styling. Those mostly concern the templating of the look, the templating of content is limited.
- output format is `html`, the look of the output is determined by an `html` template (content) and a `css` file (looks)
- output format is `pdf`, you either need a `latex` template (which determines looks & content) or you need the `html-css`-combination from above. (Different PDF engines use different forms of templates.)

## Useful Snippets
```xml
<!-- will generate a pagebreak when converting md to docx
https://pandoc.org/MANUAL.html#generic-raw-attribute
or via LUA filter https://github.com/pandoc/lua-filters/tree/master/pagebreak -->
~~~{=openxml}
<w:p><w:r><w:br w:type="page"/></w:r></w:p>
~~~
```

```shell
# Insert today's date
--metadata=date:"$(date "+%e. %B %Y")"
```

```shell
# Convert Bibliography files
# https://tex.stackexchange.com/a/268305
pandoc "My Library.bib" -t csljson -o "bibtexjson.json"
```

```shell
# Batch Conversion
cd "/folder/with/your/html/files/"
for f in *.html ; do 
	pandoc ${f} -f html -t markdown -s -o ${f}.md
done
```

```shell
# read tracked changes from word, compliant with Critic Markup
pandoc "my file.docx" --track-changes=all -t markdown | grep -C3 "{\."
```

## Templates
```yaml
---
geometry: "margin=2cm"
---
```

## Filters
- [raghur/mermaid-filter: Pandoc filter for creating diagrams in mermaid syntax blocks in markdown docs](https://github.com/raghur/mermaid-filter)
-Tools for Automatic References
	- [url2cite](https://github.com/phiresky/pandoc-url2cite/) ([usage with normal citekeys](https://github.com/phiresky/pandoc-url2cite/issues/10#issuecomment-899101361))
	- [manubot](https://github.com/manubot)
- filters can be written in [[Lua]]

> [!INFO] Priority of Filters
> Filters, Lua-filters, and citeproc processing are applied in the order specified on the command line.
> – [Pandoc Docs](https://pandoc.org/MANUAL.html#option--filter)

## References without Citations
Add this to the yaml to add references without citing them in text.

```yaml
---
nocite: @one, @two
---
```
