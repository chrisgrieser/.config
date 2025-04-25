; extends

; INFO do not inherit from `javascript` alone, since this breaks ts text objects
;───────────────────────────────────────────────────────────────────────────────
; custom text object for `nvim-treesitter-textobjects`
(call_expression
  function: (_) @call.justCaller)

; only loop and if conditions
(while_statement
  condition: (_) @conditional.conditionOnly)

(if_statement
  condition: (_) @conditional.conditionOnly)
