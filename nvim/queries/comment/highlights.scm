;extends
; EXTENDING COMMENTS TAGS https://github.com/nvim-treesitter/nvim-treesitter/blob/master/queries/comment/highlights.scm
; DOCS https://github.com/nvim-treesitter/nvim-treesitter#adding-queries
;───────────────────────────────────────────────────────────────────────────────

; added by me:
; CONFIG SIC PENDING CAVEAT DATA GUARD
; CONFIG: foo PENDING: foo

; original tags:
; FOOBAR TEST ERROR
; NOTE XXX PERF DOCS
; BUG TODO HACK
; BUG: foobar

;───────────────────────────────────────────────────────────────────────────────

("text" @text.todo (#any-of? @text.todo "PENDING" "GUARD"))
((tag (name) @text.todo ":" @punctuation.delimiter)
 (#any-of? @text.todo "PENDING" "GUARD"))

("text" @text.note (#any-of? @text.note "CONFIG"))
((tag (name) @text.note ":" @punctuation.delimiter)
 (#any-of? @text.note "CONFIG"))

("text" @text.warning (#any-of? @text.warning "SIC" "CAVEAT"))
((tag (name) @text.warning ":" @punctuation.delimiter)
 (#any-of? @text.warning "SIC" "CAVEAT"))
