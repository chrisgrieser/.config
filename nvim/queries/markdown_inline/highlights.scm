; extends

;-------------------------------------------------------------------------------
; INFO `@markdown.internal_link` needs to be defined manually
; internal markdown links (= not an URL)
(inline_link
  (link_text) @markdown.internal_link
  (link_destination) @_
  (#lua-match? @_ "%.md$")
  (#not-lua-match? @_ "^http"))

; wikilinks
(inline
  "[" @markup.link ; ensures to match `[[links]]`, but not `[links]`
  (shortcut_link
    (link_text) @markdown.internal_link)
  "]" @markup.link
  (#set! priority 130)) ; priority to overwrite LSP highlight

;-----------------------------------------------------------------------------
; de-emphasize URLs in mdlinks
(inline_link
  (link_text)
  (link_destination) @comment
  (#lua-match? @comment "^http"))
