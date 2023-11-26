;bash
(block_mapping_pair
key: (flow_node) @_run (#any-of? @_run "run" "script" "shell_comment")
value: (block_node
(block_scalar) @injection.content
(#set! injection.language "bash")
(#offset! @injection.content 0 1 0 0)))
