; extends

; custom text object for `nvim-treesitter-textobjects`
;───────────────────────────────────────────────────────────────────────────────
; only loop and if conditions
(while_statement
  condition: (_) @conditional.conditionOnly)

(if_statement
  condition: (_) @conditional.conditionOnly)

(guard_statement
  condition: (_) @conditional.conditionOnly)
