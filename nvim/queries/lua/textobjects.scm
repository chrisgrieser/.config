; extends

; just the caller of a function
(function_call
  name: (_) @call.justCaller)

; only loop and if conditions
(while_statement
  condition: (_) @conditional.conditionOnly)

(repeat_statement
  condition: (_) @conditional.conditionOnly)

(elseif_statement
  condition: (_) @conditional.conditionOnly)

(if_statement
  condition: (_) @conditional.conditionOnly)
