; extends

; add hlgroup `@namespace.builtin.lua`:
; - nvim: `vim`
; - hammerspon: `hs`
((identifier) @namespace.builtin
  (#any-of? @namespace.builtin "vim" "hs"))

;;;─────────────────────────────────────────────────────────────────────────────

; `break` and `return` statements with custom highlight, higher priority than
; LSP semantic tokens (using 125) https://neovim.io/doc/user/treesitter.html#treesitter-highlight-priority
((break_statement) @keyword.return (#set! priority 200))
("return" @keyword.return (#set! priority 200))
