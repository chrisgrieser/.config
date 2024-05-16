<!-- LTeX: enabled=false -->
- nvim new default theme -> light theme?
- `satellite.nvim` can now be updated.
	+ checkout whether the updated version works with neovide's multi-grid
- `yaml-ls` perhaps now supports formatting without needing to enable it in
  `lspconfig`
- `vim.lsp.get_clients` -> `vim.lsp.get_active_clients`
- lua ft: b.comments
- `vim.system` -> `vim.fn.system`
- `vim.uv` -> `vim.loop`
- ftAbbr & abbreviations.lua: `vim.keymap.set('ia', lhs, rhs, { buffer = true })`
- inlay hints setup: <https://www.reddit.com/r/neovim/comments/16tmzkh/comment/k2gpy16/?context=3>
- change lsp-signature to inlay hint
- `vim.snippet` -> remove snippet expansion for cmp
- check if `lua.vim` ftplugin includes `:---` as comment:
  <https://github.com/neovim/neovim/blob/master/runtime/ftplugin/lua.vim#L18>
- `vim.fn.getregion()`
- uninstall `lsp-inlayhints.nvim`
- load `symbol-usage.nvim` and `ray-x/lsp_signature.nvim` only on `LspAttach`
- checkout whether `lsp_workspace_symbols` now finally works in lua
- <https://github.com/monkoose/neocodeium>
- built-in comment support
- `vim.fs.root`
- https://gpanders.com/blog/whats-new-in-neovim-0.10/
