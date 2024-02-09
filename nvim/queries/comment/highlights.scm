;extends
; EXTENDING COMMENTS TAGS https://github.com/nvim-treesitter/nvim-treesitter/blob/master/queries/comment/highlights.scm
; DOCS https://github.com/nvim-treesitter/nvim-treesitter#adding-queries
;───────────────────────────────────────────────────────────────────────────────

; added by me:
; CONFIG SIC PENDING CAVEAT DATA GUARD SOURCE REQUIRED VALIDATE
; CONFIG: foo PENDING: foo

; original tags:
; FOOBAR TEST ERROR
; NOTE XXX PERF DOCS
; BUG TODO HACK
; BUG: foobaz

;───────────────────────────────────────────────────────────────────────────────

("text" @comment.todo (#any-of? @comment.todo "PENDING" "GUARD" "REQUIRED" "VALIDATE"))
((tag (name) @comment.todo ":" @punctuation.delimiter)
 (#any-of? @comment.todo "PENDING" "GUARD" "REQUIRED" "VALIDATE"))

("text" @comment.note (#any-of? @comment.note "CONFIG" "SOURCE" "DATA"))
((tag (name) @comment.note ":" @punctuation.delimiter)
 (#any-of? @comment.note "CONFIG" "SOURCE" "DATA"))

("text" @comment.warning (#any-of? @comment.warning "SIC" "CAVEAT"))
((tag (name) @comment.warning ":" @punctuation.delimiter)
 (#any-of? @comment.warning "SIC" "CAVEAT"))
