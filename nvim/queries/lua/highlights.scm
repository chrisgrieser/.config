; extends

; add hlgroup `@namespace.builtin.lua`:
; - nvim: `vim`
; - hammerspon: `hs`
((identifier) @namespace.builtin
              (#any-of? @namespace.builtin "vim" "hs"))

; break and continue statements should get same styling as return statements
((break_statement) @keyword.return)
((identifier) @keyword.return
              (#any-of? @keyword.return "continue"))
