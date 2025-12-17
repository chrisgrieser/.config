;extends

; Highlight cases of YAML's Norway problem
; - https://www.bram.us/2022/01/11/yaml-the-norway-problem/
; - https://yamllint.readthedocs.io/en/stable/rules.html#module-yamllint.rules.truthy
(block_mapping_pair
  value: (block_node
    (block_sequence
      (block_sequence_item
        (flow_node
          (plain_scalar
            (string_scalar) @comment.error
            (#any-of? @comment.error
              "true" "false" "yes" "no" "YES" "NO" "Yes" "No" "on" "off" "ON" "OFF" "On" "Off"
              "TRUE" "FALSE" "True" "False")))))))

(block_mapping_pair
  value: (flow_node
    (plain_scalar
      (string_scalar) @comment.error
      (#any-of? @comment.error
        "true" "false" "yes" "no" "YES" "NO" "Yes" "No" "on" "off" "ON" "OFF" "On" "Off" "TRUE"
        "FALSE" "True" "False"))))
