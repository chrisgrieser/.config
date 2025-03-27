; extends

; `break` statements should get same styling as return statements
((identifier) @typescript.keyword
  (#any-of? @typescript.keyword "break" "continue"))
