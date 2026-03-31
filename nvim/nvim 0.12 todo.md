# Nvim 0.12
- `vim._extui`
- `vim.net.request`
- `:Undotree`
- `vim.fs.exists`
- `vim.pack`
    - [A Guide to vim.pack (Neovim built-in plugin manager) – Evgeni Chasnovski](https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack)
    - wrapper <https://www.reddit.com/r/neovim/s/drTr1iSvPl>
    - <https://github.com/zuqini/zpack.nvim>
- [local dev with vim.pack](https://www.reddit.com/r/neovim/comments/1s8cbye/the_feature_im_missing_the_most_after_migrating/)
- `vim.json.encode` supports formatting → switch to `nvim-0.12` branch for
  `nvim-scissors`
- Renamed vim.diff to `vim.text.diff.`
- [Release 0.16.0 · neovide/neovide](https://github.com/neovide/neovide/releases/tag/0.16.0)

```lua
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind
		if name == "nvim-treesitter" and kind == "update" then vim.cmd(":TSUpdate") end
	end,
})
```
