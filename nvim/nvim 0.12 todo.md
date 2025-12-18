# nvim 0.12
- LSP color support:
    - <https://www.reddit.com/r/neovim/comments/1k7arqq/lsp_document_color_support_available_on_master/>
    - <https://www.reddit.com/r/neovim/comments/1moxwv9/hexadecimal_colors_in_v012_ootb/>
- `:restart`
- `vim._extui`
- `textDocument.onTypeFormatting`
- `:Difftool` <https://www.reddit.com/r/neovim/comments/1o4eo6s/new_difftool_command_added_to_neovim/>
- remove workaround in `after/ftplugin/query.lua`
- inline completion: <https://neovim.io/doc/user/lsp.html#lsp-inline_completion>
- incremental selection: `vim.lsp.buf.selection_range()`
- `:Undotree`
- `vim.pack` wrapper <https://www.reddit.com/r/neovim/s/drTr1iSvPl>
- `vim.fs.exists`

```lua
vim.api.nvim_create_autocmd("PackChanged", {
    callback = function(ev)
        local name, kind = ev.data.spec.name, ev.data.kind
        if name == "nvim-treesitter" and kind == "update" then
            vim.cmd(":TSUpdate")
        end
    end
})
```
