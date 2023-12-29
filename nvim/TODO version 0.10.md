<!-- LTeX: enabled=false -->

- nvim new default theme -> light theme?
- `satellite.nvim` can now be updated.
	+ checkout whether the updated version works with neovide's multi-grid
- `biome` and `yaml-ls` now support formatting without needing to enable it in
  `lspconfig`
	+ can now format via lsp <https://github.com/neovim/nvim-lspconfig/issues/2807>
- `vim.system` instead of `vim.fn.system`
- `vim.uv` instead of `vim.loop`
- ftAbbr & abbreviations.lua: `vim.keymap.set('ia', lhs, rhs, { buffer = true })`
- inlay hints setup: <https://www.reddit.com/r/neovim/comments/16tmzkh/comment/k2gpy16/?context=3>
- change lsp-signature to inlay hint
- `vim.snippet`
	+ <https://www.reddit.com/r/neovim/comments/17cwptz/comment/k5uoswd/?context=3>
	+ <https://github.com/garymjr/nvim-snippets>
- check if `lua.vim` ftplugin includes `:---` as comment:
  <https://github.com/neovim/neovim/blob/master/runtime/ftplugin/lua.vim#L18>
