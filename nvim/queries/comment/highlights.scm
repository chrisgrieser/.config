;extends
; EXTENDING COMMENTS TAGS https://github.com/nvim-treesitter/nvim-treesitter/blob/master/queries/comment/highlights.scm
; DOCS https://github.com/nvim-treesitter/nvim-treesitter#adding-queries
;───────────────────────────────────────────────────────────────────────────────

; added by me:
; CONFIG SIC PENDING CAVEAT DATA GUARD SOURCE
; CONFIG: foo PENDING: foo

; original tags:
; FOOBAR TEST ERROR
; NOTE XXX PERF DOCS
; BUG TODO HACK INFO
; BUG: foobaz

;───────────────────────────────────────────────────────────────────────────────

("text" @text.todo (#any-of? @text.todo "PENDING" "GUARD" "TODO" "WIP"))
((tag (name) @text.todo ":" @punctuation.delimiter)
 (#any-of? @text.todo "PENDING" "GUARD" "TODO" "WIP"))

("text" @text.note (#any-of? @text.note "CONFIG" "SOURCE" "DATA" "DOCS" "INFO" "PERF" "NOTE"))
((tag (name) @text.note ":" @punctuation.delimiter)
 (#any-of? @text.note "CONFIG" "SOURCE" "DATA" "DOCS" "INFO" "PERF" "NOTE"))

("text" @text.warning (#any-of? @text.warning "SIC" "CAVEAT" "WARN" "HACK" "FIX" "BUG"))
((tag (name) @text.warning ":" @punctuation.delimiter)
 (#any-of? @text.warning "SIC" "CAVEAT" "WARN" "HACK" "FIX" "ERROR"))

("text" @text.danger (#any-of? @text.danger "ERROR" "BUG"))
((tag (name) @text.danger ":" @punctuation.delimiter)
 (#any-of? @text.danger "ERROR" "BUG"))
