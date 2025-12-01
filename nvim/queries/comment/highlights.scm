; extends

; requires Treesitter `comments` parser (`:TSInstall comments`)
;
;-TODO_COMMENTS-----------------------------------------------------------------
; PENDING GUARD REQUIRED TEMP VALIDATE
("text" @comment.todo
  (#any-of? @comment.todo "PENDING" "GUARD" "REQUIRED" "TEMP" "VALIDATE"))

; CONFIG SOURCE DATA EXAMPLE IMPORTANT
("text" @comment.note
  (#any-of? @comment.note "CONFIG" "SOURCE" "DATA" "EXAMPLE" "IMPORTANT"))

; SIC CAVEAT DEPRECATION DEBUG
("text" @comment.warning
  (#any-of? @comment.warning "SIC" "CAVEAT" "DEPRECATION" "DEBUG"))

;-BOLD UPPERCASE COMMENTS-------------------------------------------------------
; (requires defining a hlgroup `@comments.bold` in the user config)
("text" @comment.bold
  (#lua-match? @comment.bold "^%u[%u%d][%u%d]+$")) ; at least 3 uppercase chars, to avoid words like `PR`
