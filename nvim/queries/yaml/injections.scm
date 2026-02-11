; extends

; INFO injected languages require the TS parser name, not the vim filetype name,
; so `bash` works, but not `sh`.
;───────────────────────────────────────────────────────────────────────────────
; INJECT BASH for `shell_command` in karabiner elements configs
; adapted from: https://github.com/nvim-treesitter/nvim-treesitter/blob/master/queries/yaml/injections.scm
;───────────────────────────────────────────────────────────────────────────────
(block_mapping_pair
  key: (flow_node) @_run
  (#eq? @_run "shell_command")
  value: (block_node
    (block_scalar) @injection.content
    (#set! injection.language "bash")
    (#offset! @injection.content 0 1 0 0)))

(block_mapping_pair
  key: (flow_node) @_run
  (#eq? @_run "shell_command")
  value: (flow_node
    (plain_scalar
      (string_scalar) @injection.content)
    (#set! injection.language "bash")))

(flow_pair
  key: (flow_node) @_run
  (#eq? @_run "shell_command")
  value: (flow_node
    (plain_scalar
      (string_scalar) @injection.content)
    (#set! injection.language "bash")))

(block_mapping_pair
  key: (flow_node) @_run
  (#eq? @_run "shell_command")
  value: (block_node
    (block_scalar) @injection.content
    (#set! injection.language "bash")
    (#offset! @injection.content 0 1 0 0)))

(block_mapping_pair
  key: (flow_node) @_run
  (#eq? @_run "shell_command")
  value: (block_node
    (block_sequence
      (block_sequence_item
        (flow_node
          (plain_scalar
            (string_scalar) @injection.content))
        (#set! injection.language "bash")))))

(block_mapping_pair
  key: (flow_node) @_run
  (#eq? @_run "shell_command")
  value: (block_node
    (block_sequence
      (block_sequence_item
        (block_node
          (block_scalar) @injection.content
          (#set! injection.language "bash")
          (#offset! @injection.content 0 1 0 0))))))
