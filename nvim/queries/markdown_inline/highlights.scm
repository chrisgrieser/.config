; extends

; internal links to Markdown files: `@markdown.internal_link` highlight
(inline_link
  (link_text) @markdown.internal_link
  (link_destination) @_dest
  (#lua-match? @_dest ".*%.md$"))

; wikilinks: `@markdown.internal_link` highlight (priority to overwrite LSP highlight)
(inline
  "["
  (shortcut_link) @markdown.internal_link
  (#set! priority 130))

; URLs in mdlinks: `@comment` highlight
(inline_link
  (link_text)
  (link_destination) @comment)
