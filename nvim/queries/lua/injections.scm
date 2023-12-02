;extends
;system_cmd
(function_call                                  
  name: ((dot_index_expression) @_mm
    (#any-of? @_mm "vim.fn.system" "vim.system"))
  arguments: (arguments 
    ( string content:  
      (string_content) @injection.content 
      (#set! injection.language "bash"))))
