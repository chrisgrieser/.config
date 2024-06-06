;extends

; SOURCE https://github.com/Dronakurl/injectme.nvim
;───────────────────────────────────────────────────────────────────────────────
rst_for_docstring (function_definition
  (block
    (expression_statement
      (string
        (string_content) @injection.content
        (#set! injection.language "rst")))))
