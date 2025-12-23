; extends

;-------------------------------------------------------------------------------
; INFO `@markdown.internal_link` needs to be defined manually
; internal links to Markdown files
(inline_link
  (link_text) @markdown.internal_link
  (link_destination) @_
  (#lua-match? @_ "%.md$"))

; wikilinks
(inline
  "[" ; ensures to match `[[links]]`, but not `[links]`
  (shortcut_link)
  "]"
  (#set! priority 130)) @markdown.internal_link ; priority to overwrite LSP highlight

;-----------------------------------------------------------------------------
; de-emphasize URLs in mdlinks
(inline_link
  (link_text)
  (link_destination) @comment)
