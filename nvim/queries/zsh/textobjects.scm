; extends

; custom text objects for `nvim-treesitter-textobjects`
;───────────────────────────────────────────────────────────────────────────────

; only loop and if conditions
(while_statement
  condition: (_) @conditional.conditionOnly)

(if_statement
  condition: (_) @conditional.conditionOnly)
