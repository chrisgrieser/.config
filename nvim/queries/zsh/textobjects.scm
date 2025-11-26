; ; extends
; instead of extending, vondering bash objects
; PENDING https://github.com/nvim-treesitter/nvim-treesitter-textobjects/pull/830
;───────────────────────────────────────────────────────────────────────────────

(function_definition) @function.outer

(function_definition
  body: (compound_statement
    .
    "{"
    _+ @function.inner
    "}"))

(case_statement) @conditional.outer

(if_statement
  (_) @conditional.inner) @conditional.outer

(for_statement
  (_) @loop.inner) @loop.outer

(while_statement
  (_) @loop.inner) @loop.outer

(comment) @comment.outer

(regex) @regex.inner

((word) @number.inner
  (#lua-match? @number.inner "^[0-9]+$"))

(variable_assignment) @assignment.outer

(variable_assignment
  name: (_) @assignment.inner @assignment.lhs)

(variable_assignment
  value: (_) @assignment.inner @assignment.rhs)

(command
  argument: (word) @parameter.inner)

;───────────────────────────────────────────────────────────────────────────────
; custom text objects for `nvim-treesitter-textobjects`

; only loop and if conditions
(while_statement
  condition: (_) @conditional.conditionOnly)

(if_statement
  condition: (_) @conditional.conditionOnly)
