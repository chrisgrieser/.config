; extends

; custom text object for `nvim-treesitter-textobjects`
;───────────────────────────────────────────────────────────────────────────────
; just the caller of a function
(function_call
  name: (_) @call.caller)

; regard loop conditions also as inner conditionals
(while_statement
  condition: (_) @conditional.inner)

(repeat_statement
  condition: (_) @conditional.inner)
