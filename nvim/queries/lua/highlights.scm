; extends

; add hlgroup `@namespace.builtin.lua` to "vim" (nvim) and "hs" (hammerspoon)
((identifier) @namespace.builtin
  (#any-of? @namespace.builtin "vim" "hs"))

;-------------------------------------------------------------------------------
; `break` and `return` statements with custom highlight, higher priority than
; LSP semantic tokens, which use 125 https://neovim.io/doc/user/treesitter.html#treesitter-highlight-priority
((break_statement) @keyword.return
  (#set! priority 130))

("return" @keyword.return
  (#set! priority 130))

((identifier) @keyword.return
  (#eq? @keyword.return "assert")
  (#set! priority 130))

;-------------------------------------------------------------------------------
; highlight string concatenation with `+` as error
; (error: "attempt to perform arithmetic on string")
(binary_expression
  "+" @comment.error
  (string))

(binary_expression
  (string)
  "+" @comment.error)
