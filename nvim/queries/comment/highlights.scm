;extends

; INFO this requires Treesitter `comments` parser: `TSInstall comments`
; https://github.com/nvim-treesitter/nvim-treesitter#adding-queries
;───────────────────────────────────────────────────────────────────────────────
; add more comments tags -> https://github.com/nvim-treesitter/nvim-treesitter/blob/master/queries/comment/highlights.scm
; PENDING GUARD REQUIREMENTS TEMP
("text" @comment.todo
  (#any-of? @comment.todo "PENDING" "GUARD" "REQUIREMENTS" "TEMP"))

; CONFIG SOURCE DATA EXAMPLE IMPORTANT
("text" @comment.note
  (#any-of? @comment.note "CONFIG" "SOURCE" "DATA" "EXAMPLE" "IMPORTANT"))

; SIC CAVEAT DEPRECATION
("text" @comment.warning
  (#any-of? @comment.warning "SIC" "CAVEAT" "DEPRECATION"))

; MAKE UPPERCASE COMMENTS BOLD
; (requires defining a hlgroup `@comments.bold` in the user config)
("text" @comment.bold
  (#lua-match? @comment.bold "^[%u%d%p][%u%d%p]+$"))
