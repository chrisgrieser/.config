; extends

; mdlink
(inline_link
  (link_text) @tag
  (link_destination) @dest
  (#lua-match? @dest ".*%.md$"))
