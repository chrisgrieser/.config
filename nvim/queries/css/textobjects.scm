; extends

; custom text objects for `nvim-treesitter-textobjects`
; (class_name) @selector.outer

(class_name
 
  (_) @selector.inner @selector.outer
  .
  ","? @selector.outer)

; (arguments
;   .
;   (_) @parameter.inner @parameter.outer
;   .
;   ","? @parameter.outer)
