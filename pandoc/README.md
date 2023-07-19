---
aliases: 
tags: pandoc, citation, coding
similar:
- "[[Citation Styles]]"
- "[[Bibliography Creation]]"
---

> [!INFO]  
> This note is a symlink to `pandoc/README.md` in [my dotfile directory](https://github.com/chrisgrieser/dotfiles)

## Tutorials
- [Pandoc and Obsidian - Create slideshows, PDFs and Word documents - Obsidian Publish](https://publish.obsidian.md/hub/04+-+Guides%2C+Workflows%2C+%26+Courses/Community+Talks/YT+-+Pandoc+and+Obsidian+-+Create+slideshows%2C+PDFs+and+Word+documents)

__Lingo__
> defaults = configs  
> extensions = filetype-specific settings  
> reference-docs = templates  

## Extensions
```bash
# list default extensions for a file format
# (+: enabled, -: disabled)
pandoc --list-extensions=markdown
```

- [Pandoc: Extensions](https://pandoc.org/MANUAL.html#extensions)
- [Pandoc: Non-Default Extensions](https://pandoc.org/MANUAL.html#non-default-extensions)

## Tools
- Most user-friendly: [docdown](https://github.com/lowercasename/docdown)
- [Shell Commands Plugin in Obsidian](https://github.com/Taitava/obsidian-shellcommands) with this code:

```bash
export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH ; {{folder_path:absolute}}/{{file_name}} -o {{folder_path:absolute}}/{{title}}.docx --citeproc --bibliography=/Users/matt/Documents/zotero.bib --csl=/Users/matt/Documents/apa.csl --reference-doc=/Users/matt/Documents/essay-template2.docx
```

## Handling Bibliography
```yaml
# list in bibliography without citing them in text
---
nocite: @one, @two
---
```

```yaml
# generate only bibliography without content
---
nocite: '@*'
---
```

```yaml
# Generate text without bibliography
---
suppress-bibliography: true
---
```

```sh
# Convert Bibliography files
# https://tex.stackexchange.com/a/268305
pandoc "My Library.bib" -t csljson -o "bibtexjson.json"
```

## Resolving Citations
Use Pandoc solely as citation resolver, without changing the format (i.e. markdown as input and output file):

```bash
# https://superuser.com/a/1161832
# https://stackoverflow.com/a/68933915/22114136
pandoc --citeproc --bibliography="$HOME/.pandoc/bibliography.bib" input.md -o output.md --to=markdown-citations --metadata="suppress-bibliography:true"
```

## Priority of Options
__Higher overwrites lower__
1. Direct CLI arguments
2. Arguments from the defaults-file (`--defaults`) (default location: `~/.pandoc/defaults`)
3. Another defaults file imported in the defaults file. (`defaults: entry`)
4. Metadata set as CLI argument (`--metadata`)
5. YAML of the Document (in the docs referred to as "Metadata")
6. `--metadata-file` (default location: `~/.pandoc/metadata`)

> Options specified in a defaults file itself always have priority over those in another file included with a `defaults: entry`.  
> –[Pandoc Docs](https://pandoc.org/MANUAL.html#defaults-files)

> `--metadata=KEY[:VAL]`: (…) A value specified on the command line overrides a value specified in the document using YAML metadata blocks. (…)  
> `--metadata-file=FILE`: (…) Generally, the input will be handled the same as in YAML metadata blocks. This option can be used repeatedly to include multiple metadata files; values in files specified later on the command line will be preferred over those specified in earlier files. Metadata values specified inside the document, or by using -M, overwrite values specified with this option.  
> –[Pandoc Docs](https://pandoc.org/MANUAL.html#option--metadata)

## How Templating works
> yeah, the pandoc docs aren't really good in explaining templates. For odt, pptx, and docs, pandoc calls templates "reference documents" (`--reference-doc`), where you style a docx (etc) document and when selected as reference for a docx output, the output gets styled the same way as that document.
> 
> for *all* other output formats you need actual templates (`--template`), which depend on the output format (html template + css for html output, etc.). Most notoriously, for a PDF output, the type of template you need depends on the pdf-engine (`--pdf-engine`) you use are using, since pandoc does not directly convert to pdf, but converts to PDF via something like an "intermediate format". In most cases, it's either a html-based pdf-engine (e.g. `wkhtmltopdf`) in which case you need a html and css template (and need to know html and css for that), or a latex-based pdf-engine (e.g. `pdflatex`), in which case the template needs to be written in latex. And to make it even more complicated, in both cases, there are some variables for the templates (e.g., margins) __which__ can be set in the yaml-metadata of the markdown document.
> 
> So if you want PDF output, you either have to learn html/css, latex, or simply export to docx (and convert the docx to a pdf), with the latter being probably the easiest approach.

__Summary__
- output format is `docx` or `pptx`, you need a reference-document in those formats, where you have pre-applied all your styling. Those concern the templating of the look, the templating of content is limited.
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

```sh
# Insert today's date
--metadata=date:"$(date "+%e. %B %Y")"
```

```sh
# Batch Conversion
cd "/folder/with/your/html/files/"
for f in *.html ; do 
	pandoc ${f} -f html -t markdown -s -o ${f}.md
done
```

```sh
# read tracked changes from word, compliant with Critic Markup
pandoc "my file.docx" --track-changes=all -t markdown | grep -C3 "{\."
```

## Templates
- [GitHub - Wandmalfarbe/pandoc-latex-template: A pandoc LaTeX template to convert markdown files to PDF or LaTeX.](https://github.com/Wandmalfarbe/pandoc-latex-template)
- [GitHub - kjhealy/pandoc-templates: Some templates for Pandoc.](https://github.com/kjhealy/pandoc-templates)

```yaml
---
geometry: "margin=2cm"
---
```

## Filters
- [raghur/mermaid-filter: Pandoc filter for creating diagrams in mermaid syntax blocks in markdown docs](https://github.com/raghur/mermaid-filter)
- Tools for Automatic References
	- [url2cite](https://github.com/phiresky/pandoc-url2cite/) ([usage with normal citekeys](https://github.com/phiresky/pandoc-url2cite/issues/10#issuecomment-899101361))
	- [manubot](https://github.com/manubot)
- filters can be written in [[Lua]]

> [!INFO] Priority of Filters  
> Filters, Lua-filters, and citeproc processing are applied in the order specified on the command line.  
> –[Pandoc Docs](https://pandoc.org/MANUAL.html#option--filter)

__Why Lua Filters?__
> Although traditional filters are very flexible, they have a couple of disadvantages. First, there is some overhead in writing JSON to stdout and reading it from stdin (twice, once on each side of the filter). Second, whether a filter will work will depend on details of the user's environment. A filter may require an interpreter for a certain programming language to be available, as well as a library for manipulating the pandoc AST in JSON form. One cannot simply provide a filter that can be used by anyone who has a certain version of the pandoc executable.
> 
> Starting with version 2.0, pandoc makes it possible to write filters in Lua without any external dependencies at all. A Lua interpreter (version 5.3) and a Lua library for creating pandoc filters is built into the pandoc executable. Pandoc data types are marshaled to Lua directly, avoiding the overhead of writing JSON to stdout and reading it from stdin.
- [Pandoc - Pandoc Lua Filters](https://pandoc.org/lua-filters.html)

