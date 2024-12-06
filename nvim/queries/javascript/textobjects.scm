; extends

; custom text object for `nvim-treesitter-textobjects`
;───────────────────────────────────────────────────────────────────────────────

; just the caller of a function
(call_expression function: (_) @call.caller)
