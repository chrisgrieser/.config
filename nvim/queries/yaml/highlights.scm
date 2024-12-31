;extends

; PENDING https://github.com/nvim-treesitter/nvim-treesitter/pull/7512
; FIX for yaml's norway problem https://www.bram.us/2022/01/11/yaml-the-norway-problem/
; see also https://yamllint.readthedocs.io/en/stable/rules.html#module-yamllint.rules.truthy

(block_mapping_pair
  key: (flow_node) @_run
  (#any-of? @_run "shell_command" "cmd"))

((string_scalar) @boolean
  (#any-of? @boolean
    "yes" "no" "YES" "NO" "Yes" "No" "on" "off" "ON" "OFF" "On" "Off" "TRUE" "FALSE" "True" "False"))
