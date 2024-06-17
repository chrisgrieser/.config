;extends

; add hlgroup `@namespace.builtin.lua`:
; - nvim: `vim` 
; - hammerspon: `hs`
((identifier) @namespace.builtin
  (#any-of? @namespace.builtin "vim" "hs"))
