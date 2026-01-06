; extends

; defines locals for snacks.nvim treesitter picker
; requires `opts.picker.sources.treesitter.filter.markdown = { "Field" }`
(section) @local.scope
(atx_heading (inline) @local.definition.field)
(setext_heading (paragraph) @local.definition.field)
