; extends

; INFO injected languages require the TS parser name, not the vim filetype name,
; so `bash` works, but not `sh`.
;───────────────────────────────────────────────────────────────────────────────
; INJECT BASH FOR:
; - `shell_command` karabiner elements config
; - `cmd` espanso
; adapted from: https://github.com/nvim-treesitter/nvim-treesitter/blob/master/queries/yaml/injections.scm
;───────────────────────────────────────────────────────────────────────────────
(block_mapping_pair
  key: (flow_node) @_run
  (#any-of? @_run "shell_command" "cmd")
  value: (block_node
           (block_scalar) @injection.content
           (#set! injection.language "bash")
           (#offset! @injection.content 0 1 0 0)))

(block_mapping_pair
  key: (flow_node) @_run
  (#any-of? @_run "shell_command" "cmd")
  value: (flow_node
           (plain_scalar
             (string_scalar) @injection.content)
           (#set! injection.language "bash")))

(block_mapping_pair
  key: (flow_node) @_run
  (#any-of? @_run "shell_command" "cmd")
  value: (block_node
           (block_scalar) @injection.content
           (#set! injection.language "bash")
           (#offset! @injection.content 0 1 0 0)))

(block_mapping_pair
  key: (flow_node) @_run
  (#any-of? @_run "shell_command" "cmd")
  value: (block_node
           (block_sequence
             (block_sequence_item
               (flow_node
                 (plain_scalar
                   (string_scalar) @injection.content))
               (#set! injection.language "bash")))))

(block_mapping_pair
  key: (flow_node) @_run
  (#any-of? @_run "shell_command" "cmd")
  value: (block_node
           (block_sequence
             (block_sequence_item
               (block_node
                 (block_scalar) @injection.content
                 (#set! injection.language "bash")
                 (#offset! @injection.content 0 1 0 0))))))
