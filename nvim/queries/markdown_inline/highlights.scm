; extends

;-------------------------------------------------------------------------------
; INFO `@markdown.internal_link` needs to be defined manually
; internal markdown links (= not an URL)
(inline_link
  (link_text) @markdown.internal_link
  (link_destination) @_
  (#not-match? @_ "^https?://"))

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
