; extends

; internal links to Markdown files: `@tag` highlight
(inline_link
  (link_text) @tag
  (link_destination) @_dest
  (#lua-match? @_dest ".*%.md$"))

; wikilinks: `@tag` highlight
((shortcut_link) @tag)

; URLs in mdlinks: `@comment` highlight
(inline_link
  (link_text)
  (link_destination) @comment)
