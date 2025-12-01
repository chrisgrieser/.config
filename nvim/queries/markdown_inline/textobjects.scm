; extends

; custom text objects for `nvim-treesitter-textobjects`
(inline_link) @mdlink.outer

(link_text) @mdlink.inner

(emphasis) @emphasis.outer

;-------------------------------------------------------------------------------
((strong_emphasis) @emphasis.inner
  (#lua-match? @emphasis.inner "^[a-z]+$"))

(strong_emphasis) @emphasis.outer
