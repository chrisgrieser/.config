;extends

; highlight `return` and `exit` like return statements in other languages with
; `@keyword.return`

((word) @keyword.return
        (#any-of? @keyword.return "return" "exit"))
