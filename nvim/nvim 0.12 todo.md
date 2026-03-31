# `vim.pack`
- [A Guide to vim.pack (Neovim built-in plugin manager) – Evgeni Chasnovski](https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack)
- [local dev with vim.pack](https://www.reddit.com/r/neovim/comments/1s8cbye/the_feature_im_missing_the_most_after_migrating/)

```lua
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind
		if name == "nvim-treesitter" and kind == "update" then vim.cmd(":TSUpdate") end
	end,
})
```

---

- [Release 0.16.0 · neovide/neovide](https://github.com/neovide/neovide/releases/tag/0.16.0)
