; extends

; internal links to Markdown files: `@tag` highlight
(inline_link
  (link_text) @tag
  (link_destination) @_dest
  (#lua-match? @_dest ".*%.md$"))

; wikilinks: `@tag` highlight (priority to overwrite LSP highlight)
((shortcut_link) @tag (#set! priority 130))

; URLs in mdlinks: `@comment` highlight
(inline_link
  (link_text)
  (link_destination) @comment)
