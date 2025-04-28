; extends

; `break` and `return` statements with custom highlight, higher priority than
; LSP semantic tokens (using 125) https://neovim.io/doc/user/treesitter.html#treesitter-highlight-priority
("return" @keyword.return
  (#set! priority 130))

("guard" @keyword.return
  (#set! priority 130))

; FIX semantic highlighting of LSP overriding boolean coloring
((boolean_literal) @boolean.swift
  (#set! priority 130))

("nil" @constant.builtin.swift
  (#set! priority 130))
