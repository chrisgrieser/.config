;extends
; INFO injected languages require the TS parser name, not the vim filetype name,
; so "bash" works, but not "sh"
;───────────────────────────────────────────────────────────────────────────────

;system_cmd
(function_call                                  
  name: ((dot_index_expression) @_mm
                                (#any-of? @_mm "vim.fn.system" "vim.system"))
  arguments: (arguments 
               ( string content:  
                        (string_content) @injection.content 
                        (#set! injection.language "bash"))))

;markdown in comments
(comment
  (comment_content) @injection.content (#set! injection.language "markdown"))
