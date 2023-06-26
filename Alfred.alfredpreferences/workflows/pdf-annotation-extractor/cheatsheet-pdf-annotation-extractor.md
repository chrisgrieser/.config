# PDF Annotation Extractor
Use the hotkey to trigger the Annotation Extraction on the PDF file currently selected in Finder.

__Annotation Types extracted__
- Highlight ➡️ bullet point, quoting text and prepending the comment
- Underline ➡️ output to [Drafts.app](https://getdrafts.com/); they are not included in the annotations. 
- Free Comment ➡️ blockquote of the comment text
- Strikethrough ➡️ Markdown strikethrough
- Rectangle ➡️ image

## Automatic Page Number Identification
Instead of the PDF page numbers, this workflow retrieves information about the *real* page numbers from the BibTeX library and inserts them. If there is no page data in the BibTeX entry (e.g., monographies), you are prompted to enter the page number manually.
- In that case, enter the __real page number__ of your __first PDF page__.
- In case there is content before the actual text (e.g., a foreword or Table of Contents), the real page number `1` often occurs later in the PDF. In that case, you must enter a __negative page number__, reflecting the true page number the first PDF would have. *Example: Your PDF is a book which has a foreword, and uses roman numbers for it; real page number 1 is PDF page number 12. If you continued the numbering backwards, the first PDF page would have page number `-10`, you enter the value `-10` when prompted for a page number.*

## Annotation Codes
Insert these special codes at the __beginning__ of an annotation to invoke special actions on that annotation. Annotation Codes do not apply to Strikethroughs. (You can run the Alfred command `acode` to display a cheat sheet showing all the following information.)

- `+`: Merge this highlight/underline with the previous highlight/underline. Works for annotations on the same page (= skipping text in between) and for annotations across two pages.
- `? foo` __(free comments)__: Turns "foo" into a [Question Callout](https://help.obsidian.md/How+to/Use+callouts)  (`> ![QUESTION]`) and move up. (Callouts are Obsidian-specific Syntax.)
- `##`: Turns highlighted/underlined text into a __heading__ that is added at that location. The number of `#` determines the heading level. If the annotation is a free comment, the text following the `#` is used as heading instead (Space after `#` required).
- `=`: Adds highlighted/underlined text as __tags__ to the YAML-frontmatter (mostly used for Obsidian as output). If the annotation is a free comment, uses the text after the `=`. In both cases, the annotation is removed afterwards.
- `_` __(highlights only)__: Removes the `_` and creates a copy of the annotation, but with the type `underline`. This annotation code avoids having to highlight *and* underline the same text segment to have it in both places.

## Extracting Images
- The respective images is saved in the `attachments` subfolder of the output folder, and named `{citekey}_image{n}.png`.
- The images is embedded in the markdown file with the `![[ ]]` syntax, e.g. `![[filename.png|foobar]]`
- Any `rectangle` type annotation in the PDF is extracted as image.
- If the rectangle annotation has any comment, it is used as the alt-text for the image. (Note that some PDF readers like PDF Expert do not allow you to add a comment to rectangular annotations.)
