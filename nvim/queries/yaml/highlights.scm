;extends

; adds the `@yaml-injection` highlight group to the same nodes as in
; `injections.yaml`
;───────────────────────────────────────────────────────────────────────────────

(block_mapping_pair
  key: (flow_node) @_run (#any-of? @_run "run" "shell_command")
  value: (block_node
           (block_scalar) @yaml-injection
           (#offset! @yaml-injection 0 1 0 0)))
