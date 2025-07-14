; extends

; `break` and `return` statements with custom highlight, higher priority than
; LSP semantic tokens (using 125) https://neovim.io/doc/user/treesitter.html#treesitter-highlight-priority
([
  "break"
  "continue"
  "return"
  "throw"
] @keyword.return
  (#set! priority 130))
