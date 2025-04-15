; extends

; custom text object for `nvim-treesitter-textobjects`
; INFO to not inheit from `javascript` alone, since this breaks ts text objects
;───────────────────────────────────────────────────────────────────────────────

; just the caller of a function
(call_expression function: (_) @call.caller)
