; extends

;-------------------------------------------------------------------------------
; add `@markdown.internal_link` to internal links
; (the highlight for `@markdown.internal_link` needs to be defined manually)

; internal markdown links
(inline_link
  (link_text) @markdown.internal_link
  (link_destination) @_
  (#lua-match? @_ "%.md$")
  (#not-lua-match? @_ "^http")
  (#set! priority 130)) ; priority to overwrite LSP highlights

; wikilinks
(inline
  "[" @markup.link ; ensures to match `[[links]]`, but not `[links]`
  (shortcut_link
    (link_text) @markdown.internal_link)
  "]" @markup.link
  (#set! priority 130)) ; priority to overwrite LSP highlights

;-----------------------------------------------------------------------------
; de-emphasize URLs in mdlinks
(inline_link
  (link_text)
  (link_destination) @comment)
