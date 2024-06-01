;extends
; extending comments tags https://github.com/nvim-treesitter/nvim-treesitter/blob/master/queries/comment/highlights.scm
; DOCS https://github.com/nvim-treesitter/nvim-treesitter#adding-queries
;───────────────────────────────────────────────────────────────────────────────

; added by me:
; CONFIG SIC PENDING CAVEAT DATA GUARD SOURCE REQUIRED VALIDATE EXAMPLE
; CONFIG: foo PENDING: foo

; original tags:
; FOOFOO TEST ERROR
; NOTE XXX PERF DOCS
; BUG TODO HACK
; BUG: foobaz

;───────────────────────────────────────────────────────────────────────────────

("text" @comment.todo (#any-of? @comment.todo "PENDING" "GUARD" "REQUIRED" "VALIDATE"))
((tag (name) @comment.todo ":" @punctuation.delimiter)
 (#any-of? @comment.todo "PENDING" "GUARD" "REQUIRED" "VALIDATE"))

("text" @comment.note (#any-of? @comment.note "CONFIG" "SOURCE" "DATA" "EXAMPLE"))
((tag (name) @comment.note ":" @punctuation.delimiter)
 (#any-of? @comment.note "CONFIG" "SOURCE" "DATA" "EXAMPLE"))

("text" @comment.warning (#any-of? @comment.warning "SIC" "CAVEAT"))
((tag (name) @comment.warning ":" @punctuation.delimiter)
 (#any-of? @comment.warning "SIC" "CAVEAT"))

;──────────────────────────────────────────────────────────────────────────────

; not working with special characters in `here`,
; see https://github.com/stsewd/tree-sitter-comment/issues/34
("text" @markup.raw.markdown_inline
 (#match? @markup.raw.markdown_inline "`.+`"))
