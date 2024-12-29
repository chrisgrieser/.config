;extends

; highlight `yes` and `no` as booleans, since yaml treats them as such
((string_scalar) @boolean
  (#any-of? @boolean "yes" "no" "y" "n"))
