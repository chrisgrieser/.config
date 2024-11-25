;extends

; DOCS https://github.com/nvim-treesitter/nvim-treesitter#adding-queries
;───────────────────────────────────────────────────────────────────────────────
; EXTENDING COMMENTS TAGS
; SOURCE https://github.com/nvim-treesitter/nvim-treesitter/blob/master/queries/comment/highlights.scm
; added by me: CONFIG SIC PENDING CAVEAT DATA GUARD SOURCE REQUIRED VALIDATE
; EXAMPLE TEMP
("text" @comment.todo
 (#any-of? @comment.todo "PENDING" "GUARD" "REQUIRED" "VALIDATE" "TEMP"))

("text" @comment.note
 (#any-of? @comment.note "CONFIG" "SOURCE" "DATA" "EXAMPLE" "IMPORTANT"))

("text" @comment.warning
 (#any-of? @comment.warning "SIC" "CAVEAT" "DEPRECATION"))

;───────────────────────────────────────────────────────────────────────────────
; HIGHLIGHT INLINE CODE IN COMMENTS
; CAVEAT not working with special characters inside ``, see https://github.com/stsewd/tree-sitter-comment/issues/34
("text" @markup.raw.markdown_inline
  (#match? @markup.raw.markdown_inline "`.+`"))

; MAKE UPPERCASE COMMENTS BOLD
; requires setting the hlgroup `@comments.bold`
("text" @comment.bold
  (#lua-match? @comment.bold "[%u%p][%u%p]+"))
