; extends
; INFO this requires Treesitter `comments` parser: `TSInstall comments`
; https://github.com/nvim-treesitter/nvim-treesitter#adding-queries

;-TODO–COMMENTS-----------------------------------------------------------------

; PENDING GUARD REQUIREMENTS TEMP VALIDATE
("text" @comment.todo
  (#any-of? @comment.todo "PENDING" "GUARD" "REQUIREMENTS" "TEMP" "VALIDATE"))

; CONFIG SOURCE DATA EXAMPLE IMPORTANT
("text" @comment.note
  (#any-of? @comment.note "CONFIG" "SOURCE" "DATA" "EXAMPLE" "IMPORTANT"))

; SIC CAVEAT DEPRECATION DEBUG
("text" @comment.warning
  (#any-of? @comment.warning "SIC" "CAVEAT" "DEPRECATION" "DEBUG"))

;-BOLD COMMENTS-----------------------------------------------------------------
; (requires defining a hlgroup `@comments.bold` in the user config)

; UPPERCASE WORDS
("text" @comment.bold
  (#lua-match? @comment.bold "[%u%d%p][%u%d%p]+"))
