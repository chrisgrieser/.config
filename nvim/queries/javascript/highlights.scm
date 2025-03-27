; extends

; `break` statements should get same styling as return statements
; (though for some reason, the highlight group is combined instead of getting
; higher priority, as is the case with lua :/)
(break_statement) @keyword.return
