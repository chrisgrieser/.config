;extends
; INFO injected languages require the TS parser name, not the vim filetype name,
; so "bash" works, but not "sh"
;───────────────────────────────────────────────────────────────────────────────

; inject bash for `shell_command` from the karabiner elements config
(block_mapping_pair
  key: (flow_node) @_run (#any-of? @_run "run" "cmd" "shell_command")
  value: (block_node
           (block_scalar) @injection.content
           (#set! injection.language "bash")
           (#offset! @injection.content 0 1 0 0)))

(block_mapping_pair
  key: (flow_node) @_run (#any-of? @_run "run" "cmd" "shell_command")
  value: (block_node
           (block_sequence
             (block_sequence_item
               (flow_node
                 (plain_scalar
                   (string_scalar) @injection.content))
               (#set! injection.language "bash")))))

(block_mapping_pair
  key: (flow_node) @_run (#any-of? @_run "run" "cmd" "shell_command")
  value: (block_node
           (block_sequence
             (block_sequence_item
               (block_node
                 (block_scalar) @injection.content
                 (#set! injection.language "bash")
                 (#offset! @injection.content 0 1 0 0))))))
