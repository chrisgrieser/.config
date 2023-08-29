; Modification of the original highlights to add more common tags

; DOCS 
; Supposedly, this adding this file to the after directory should be enough to
; extend the query. https://github.com/nvim-treesitter/nvim-treesitter#adding-queries
;
; However, this is (currently) not the case. Instead it seems
; only possible to completely override the query. Therefore, this file is a copy
; of the comment highlights, modified to include some changes I like to have.
; https://github.com/nvim-treesitter/nvim-treesitter/blob/master/queries/comment/highlights.scm
; 
;───────────────────────────────────────────────────────────────────────────────

; FOOBAR TEST ERROR
; NOTE XXX PERF
; BUG
; TODO HACK

;───────────────────────────────────────────────────────────────────────────────

(_) @spell

((tag
  (name) @text.todo @nospell
  ("(" @punctuation.bracket (user) @constant ")" @punctuation.bracket)?
  ":" @punctuation.delimiter)
  (#any-of? @text.todo "TODO" "WIP"))

("text" @text.todo @nospell
 (#any-of? @text.todo "TODO" "WIP"))

((tag
  (name) @text.note @nospell
  ("(" @punctuation.bracket (user) @constant ")" @punctuation.bracket)?
  ":" @punctuation.delimiter)
  (#any-of? @text.note "NOTE" "INFO" "DOCS" "PERF" "TEST"))

("text" @text.note @nospell
 (#any-of? @text.note "NOTE" "INFO" "DOCS" "PERF" "TEST"))

((tag
  (name) @text.warning @nospell
  ("(" @punctuation.bracket (user) @constant ")" @punctuation.bracket)?
  ":" @punctuation.delimiter)
  (#any-of? @text.warning "HACK" "WARN" "FIX"))

("text" @text.warning @nospell
 (#any-of? @text.warning "HACK" "WARN" "FIX"))

((tag
  (name) @text.danger @nospell
  ("(" @punctuation.bracket (user) @constant ")" @punctuation.bracket)?
  ":" @punctuation.delimiter)
  (#any-of? @text.danger "BUG" "ERROR"))

("text" @text.danger @nospell
 (#any-of? @text.danger "BUG" "ERROR"))

; Issue number (#123)
("text" @number
 (#lua-match? @number "^#[0-9]+$"))

((uri) @text.uri @nospell)
