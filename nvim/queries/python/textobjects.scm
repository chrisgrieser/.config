; extends

; custom text objects for `nvim-treesitter-textobjects`
;───────────────────────────────────────────────────────────────────────────────
; docstring
(expression_statement
  (string
    (string_content) @docstring.inner) @docstring.outer)

; only loop and if conditions
(while_statement
  condition: (_) @conditional.conditionOnly)

(if_statement
  condition: (_) @conditional.conditionOnly)
