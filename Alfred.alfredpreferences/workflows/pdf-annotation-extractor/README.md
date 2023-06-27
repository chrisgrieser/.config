# PDF Annotation Extractor
![](https://img.shields.io/github/downloads/chrisgrieser/pdf-annotation-extractor-alfred/total?label=Total%20Downloads&style=plastic) ![](https://img.shields.io/github/v/release/chrisgrieser/pdf-annotation-extractor-alfred?label=Latest%20Release&style=plastic)

A [Workflow for Alfred](https://www.alfredapp.com/) to extract annotations as Markdown & insert Pandoc Citations as References.

Automatically determines correct page numbers, merges highlights across page breaks, prepends a YAML Header bibliographic information, and some more small Quality-of-Life conveniences.

## Table of Contents
<!--toc:start-->
- [Installation](#installation)
- [Usage](#usage)
	- [Requirements for the PDF](#requirements-for-the-pdf)
	- [Basics](#basics)
	- [Automatic Page Number Identification](#automatic-page-number-identification)
	- [Annotation Codes](#annotation-codes)
	- [Extracting Images](#extracting-images)
- [Troubleshooting](#troubleshooting)
- [Contribute](#contribute)
- [Credits](#credits)
	- [Thanks](#thanks)
	- [About the Developer](#about-the-developer)
	- [Buy me a Coffee](#buy-me-a-coffee)
<!--toc:end-->

## Installation
- Requirement: [Alfred 5](https://www.alfredapp.com/) with Powerpack
- Install [Homebrew](https://brew.sh/)
- Install `pdfannots2json` by pasting the following into your terminal:

  ```bash
  brew install mgmeyers/pdfannots2json/pdfannots2json
  ```

- Download the [latest release](https://github.com/chrisgrieser/pdf-annotation-extractor-alfred/releases/latest/).
- Set the hotkey by double-clicking the sky-blue field at the top left. 
- Set up the workflow configuration inside the app.

## Usage

### Requirements (for the PDF)
- The *PDF Annotation Extractor** works on any PDF that has valid annotations saved *in the PDF file*. Some PDF readers like __Skim__ or __Zotero 6__ do not store annotations in the PDF itself by default.
- The filename of the PDF must be *exactly* the citekey (without `@`), optionally followed by an underscore and some text like `{citekey}_{title}.pdf`. The citekey must not contain underscores (`_`).

> __Note__  
> You can achieve such a filename pattern with automatic renaming rules of most reference managers, for example with the [ZotFile plugin for Zotero](http://zotfile.com/#renaming-rules) or the [AutoFile feature of BibDesk](https://bibdesk.sourceforge.io/manual/BibDeskHelp_77.html#SEC140).

### Basics
Use the hotkey to trigger the Annotation Extraction on the PDF file currently selected in Finder.

__Annotation Types extracted__
- Highlight ➡️ bullet point, quoting text and prepending the comment
- Free Comment ➡️ blockquote of the comment text
- Strikethrough ➡️ Markdown strikethrough
- Rectangle ➡️ image
- Underlines ➡️ sent to [SideNotes](https://www.apptorium.com/sidenotes) (if not
  installed, they are ignored)

### Automatic Page Number Identification
Instead of the PDF page numbers, this workflow retrieves information about the *real* page numbers from the BibTeX library and inserts them. If there is no page data in the BibTeX entry (for example, monographies), you are prompted to enter the page number manually.
- In that case, enter the __real page number__ of your __first PDF page__.
- In case there is content before the actual text (for example, a foreword or Table of Contents), the real page number `1` often occurs later in the PDF. If that is the case, you must enter a __negative page number__, reflecting the true page number the first PDF would have. *Example: Your PDF is a book, which has a foreword, and uses roman numbers for it; real page number 1 is PDF page number 12. If you continued the numbering backwards, the first PDF page would have page number `-10`, you enter the value `-10` when prompted for a page number.*

### Annotation Codes
Insert these special codes at the __beginning__ of an annotation to invoke special actions on that annotation. Annotation Codes do not apply to Strikethroughs. (You can run the Alfred command `acode` to display a cheat sheet showing all the following information.)

- `+`: Merge this highlight with the previous highlight or underline. Works for annotations on the same page (= skipping text in between) and for annotations across two pages.
- `? foo` __(free comments)__: Turns "foo" into a [Question Callout](https://help.obsidian.md/How+to/Use+callouts)  (`> ![QUESTION]`) and move up. (Callouts are Obsidian-specific Syntax.)
- `##`: Turns highlighted text into a __heading__ that is added at that location. The number of `#` determines the heading level. If the annotation is a free comment, the text following the `#` is used as heading instead. (The space after the is `#` required).
- `=`: Adds highlighted text as __tags__ to the YAML frontmatter (mostly used for Obsidian as output). If the annotation is a free comment, uses the text after the `=`. In both cases, the annotation is removed afterward.
- `_`: A copy of the annotation is sent to [SideNotes](https://www.apptorium.com/sidenotes). If SideNotes is not installed, these annotations are extracted as normal.

### Extracting Images
- The respective images is saved in the `attachments` sub-folder of the output folder, and named `{citekey}_image{n}.png`.
- The images are embedded in the markdown file with the `![[ ]]` syntax, for example `![[filename.png|foobar]]`
- Any `rectangle` type annotation in the PDF is extracted as image.
- If the rectangle annotation has any comment, it is used as the alt-text for the image. (Note that some PDF readers like PDF Expert do not allow you to add a comment to rectangular annotations.)

## Troubleshooting
- Update to the latest version of `pdfannots2json` by running the following Terminal command `brew upgrade pdfannots2json` in your terminal.
- This workflow does not work with annotations that are not actually saved in the PDF file. Some PDF Readers like __Skim__ or __Zotero 6__ do this, but you can [tell those PDF readers to save the notes in the actual PDF.](https://skim-app.sourceforge.io/manual/SkimHelp_45.html)

> __Note__  
> As a fallback, you can use `pdfannots` as extraction engine, as a different PDF engine sometimes fixes issues. This requires installing [pdfannots](https://github.com/mgmeyers/pdfannots2json/issues/11) via `pip3 install pdfannots`, and switching the fallback engine via `aconf`. Note that `pdfannots` does not support image extraction or extracting only recent annotations, so generally you want to keep using `pdfannots2json`.

## Contribute

```bash
make release
```

Then enter the next version number.

## Credits
<!-- vale Google.FirstPerson = NO -->
### Thanks
- To [Andrew Baumann for pdfannots](https://github.com/0xabu/pdfannots), which caused me to develop this workflow (even though it does not use `pdfannots` anymore).
- Also, many thanks to [@mgmeyers for pdfannots2json](https://github.com/mgmeyers/pdfannots2json/), which enabled many improvements to this workflow.
- I also thank [@StPag](https://github.com/stefanopagliari/) for his ideas on annotation codes.
- <a href="https://www.flaticon.com/authors/freepik">Icons created by Freepik/Flaticon.</a>

### About the Developer
In my day job, I am a sociologist studying the social mechanisms underlying the digital economy. For my PhD project, I investigate the governance of the app economy and how software ecosystems manage the tension between innovation and compatibility. If you are interested in this subject, feel free to get in touch.

- [Academic Website](https://chris-grieser.de/)
- [Discord](https://discordapp.com/users/462774483044794368/)
- [GitHub](https://github.com/chrisgrieser/)
- [Twitter](https://twitter.com/pseudo_meta)
- [ResearchGate](https://www.researchgate.net/profile/Christopher-Grieser)
- [LinkedIn](https://www.linkedin.com/in/christopher-grieser-ba693b17a/)

### Buy me a Coffee
<a href='https://ko-fi.com/Y8Y86SQ91' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://cdn.ko-fi.com/cdn/kofi1.png?v=3' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>
