;extends
; inject sh for `shell_command` (karabiner elements config)
; karabiner_1
(block_mapping_pair
key: (flow_node) @_run (#any-of? @_run "run" "cmd" "shell_command")
value: (block_node
(block_scalar) @injection.content
(#set! injection.language "bash")
(#offset! @injection.content 0 1 0 0)))

; karabiner_2
(block_mapping_pair
key: (flow_node) @_run (#any-of? @_run "run" "cmd" "shell_command")
value: (block_node
(block_sequence
(block_sequence_item
(flow_node
(plain_scalar
(string_scalar) @injection.content))
(#set! injection.language "bash")))))

; karabiner_3
(block_mapping_pair
key: (flow_node) @_run (#any-of? @_run "run" "cmd" "shell_command")
value: (block_node
(block_sequence
(block_sequence_item
(block_node
(block_scalar) @injection.content
(#set! injection.language "bash")
(#offset! @injection.content 0 1 0 0))))))
