; extends

; custom text object for `nvim-treesitter-textobjects`
;───────────────────────────────────────────────────────────────────────────────

; just the caller of a function
(function_call name:(_) @call.caller)
