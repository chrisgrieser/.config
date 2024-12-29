;extends

; FIX for yaml's norway problem https://www.bram.us/2022/01/11/yaml-the-norway-problem/
; see also https://yamllint.readthedocs.io/en/stable/rules.html#module-yamllint.rules.truthy
; ((string_scalar) @boolean
;   (#any-of? @boolean
;     "yes" "no" "YES" "NO" "Yes" "No" "y" "n" "Y" "N" "on" "off" "ON" "OFF" "On" "Off" "TRUE" "FALSE"
;     "True" "False"))
