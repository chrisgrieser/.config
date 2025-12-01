; extends

; INFO this requires Treesitter `comments` parser: `TSInstall comments`
; https://github.com/nvim-treesitter/nvim-treesitter#adding-queries
;───────────────────────────────────────────────────────────────────────────────
; add more comments tags -> https://github.com/nvim-treesitter/nvim-treesitter/blob/master/queries/comment/highlights.scm
; PENDING GUARD REQUIREMENTS TEMP VALIDATE
("text" @comment.todo
  (#any-of? @comment.todo "PENDING" "GUARD" "REQUIREMENTS" "TEMP" "VALIDATE"))

; CONFIG SOURCE DATA EXAMPLE IMPORTANT
("text" @comment.note
  (#any-of? @comment.note "CONFIG" "SOURCE" "DATA" "EXAMPLE" "IMPORTANT"))

; SIC CAVEAT DEPRECATION DEBUG
("text" @comment.warning
  (#any-of? @comment.warning "SIC" "CAVEAT" "DEPRECATION" "DEBUG"))

; MAKE UPPERCASE COMMENTS BOLD
; (requires defining a hlgroup `@comments.bold` in the user config)
("text" @comment.bold
  (#lua-match? @comment.bold "[%u%d%p][%u%d%p]+"))

("text" @comment.bold
  (#lua-match? @comment.bold "`.+`"))

; `inline_code` in comments is highlgihted
; caveat: not working with spaces or special characters inside ``, see https://github.com/stsewd/tree-sitter-comment/issues/34
("text" @markup.raw.markdown_inline
  (#match? @markup.raw.markdown_inline "`.+`"))
