; extends

; add hlgroup `@namespace.builtin.lua`:
; - nvim: `vim`
; - hammerspon: `hs`
((identifier) @namespace.builtin
  (#any-of? @namespace.builtin "vim" "hs"))

; `break` statements should get same styling as return statements
(break_statement) @keyword.return
