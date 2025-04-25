; extends

; custom text object for `nvim-treesitter-textobjects`
(call_expression
  function: (_) @call.justCaller)

; regard only loop and if conditions also as inner conditionals
(while_statement
  condition: (_) @conditional.conditionOnly)

(if_statement
  condition: (_) @conditional.conditionOnly)
