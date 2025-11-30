; extends

; custom text objects for `nvim-treesitter-textobjects`
;───────────────────────────────────────────────────────────────────────────────
; only loop and if conditions
(while_statement
  condition: (_) @conditional.conditionOnly)

(if_statement
  condition: (_) @conditional.conditionOnly)

; pipeline
(pipeline
  (command) @pipeline.inner @pipeline.outer
  "|" @pipeline.outer)
