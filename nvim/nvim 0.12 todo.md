# Nvim 0.12
- LSP color support:
    - <https://www.reddit.com/r/neovim/comments/1k7arqq/lsp_document_color_support_available_on_master/>
    - <https://www.reddit.com/r/neovim/comments/1moxwv9/hexadecimal_colors_in_v012_ootb/>
- `:restart` <https://github.com/neovide/neovide/discussions/1713>
- `vim._extui`
- `textDocument.onTypeFormatting`
- `:Difftool`
  <https://www.reddit.com/r/neovim/comments/1o4eo6s/new_difftool_command_added_to_neovim/>
- `vim.net.request`
- remove workaround in `after/ftplugin/query.lua`
- inline completion: <https://neovim.io/doc/user/lsp.html#lsp-inline_completion>
- incremental selection: `vim.lsp.buf.selection_range()`
- `:Undotree`
- `vim.fs.exists`
- `vim.pack`
    - [A Guide to vim.pack (Neovim built-in plugin manager) – Evgeni Chasnovski](https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack)
    - wrapper <https://www.reddit.com/r/neovim/s/drTr1iSvPl>
    - <https://github.com/zuqini/zpack.nvim>
- [local dev with vim.pack](https://www.reddit.com/r/neovim/comments/1s8cbye/the_feature_im_missing_the_most_after_migrating/)
- `vim.json.encode` supports formatting → switch to `nvim-0.12` branch for
  `nvim-scissors`
- `vim.fs.read`
- [Release 0.16.0 · neovide/neovide](https://github.com/neovide/neovide/releases/tag/0.16.0)

```lua
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind
		if name == "nvim-treesitter" and kind == "update" then vim.cmd(":TSUpdate") end
	end,
})
```
