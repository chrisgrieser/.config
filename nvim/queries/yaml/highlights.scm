;extends

; PENDING https://github.com/nvim-treesitter/nvim-treesitter/pull/7512
; FIX for yaml's norway problem https://www.bram.us/2022/01/11/yaml-the-norway-problem/
; see also https://yamllint.readthedocs.io/en/stable/rules.html#module-yamllint.rules.truthy
;───────────────────────────────────────────────────────────────────────────────
(block_mapping_pair
  value: (block_node
    (block_sequence
      (block_sequence_item
        (flow_node
          (plain_scalar
            (string_scalar) @boolean
            (#any-of? @boolean
              "yes" "no" "YES" "NO" "Yes" "No" "on" "off" "ON" "OFF" "On" "Off" "TRUE" "FALSE"
              "True" "False")))))))

(block_mapping_pair
  value: (flow_node
    (plain_scalar
      (string_scalar) @boolean
      (#any-of? @boolean
        "yes" "no" "YES" "NO" "Yes" "No" "on" "off" "ON" "OFF" "On" "Off" "TRUE" "FALSE" "True"
        "False"))))
