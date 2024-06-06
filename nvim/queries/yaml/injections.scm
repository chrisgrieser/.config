; extends

; SOURCE https://github.com/Dronakurl/injectme.nvim
; INFO injected languages require the TS parser name, not the vim filetype name,
; so `bash` works, but not `sh`
;───────────────────────────────────────────────────────────────────────────────
; INJECT BASH FOR:
; - `shell_command` karabiner elements config
; - `run` GitHub actions
; - `cmd` espanso
;───────────────────────────────────────────────────────────────────────────────
;(block_mapping_pair
;  key: (flow_node) @_run
;  (#any-of? @_run "run" "shell_command" "cmd")
;  value: (block_node
;    (block_scalar) @injection.content
;    (#set! injection.language "bash")
;    (#offset! @injection.content 0 1 0 0)))
