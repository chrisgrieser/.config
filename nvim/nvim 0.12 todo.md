# `vim.pack`
- [A Guide to vim.pack (Neovim built-in plugin manager) – Evgeni Chasnovski](https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack)
- [local dev with vim.pack](https://www.reddit.com/r/neovim/comments/1s8cbye/the_feature_im_missing_the_most_after_migrating/)

```lua
vim.api.nvim_create_autocmd('PackChanged', { callback = function(ev)
  local name, kind = ev.data.spec.name, ev.data.kind
  if name == 'nvim-treesitter' and kind == 'update' then
    if not ev.data.active then vim.cmd.packadd('nvim-treesitter') end
    vim.cmd('TSUpdate')
  end
end })
```

```lua
vim.pack.add({
  'https://github.com/neovim/nvim-lspconfig',
}, { load = function() end }) -- do not add package, we just need it's runtimepath

-- INFO `prepend` ensures it is loaded before the user's LSP configs, so
-- that the user's configs override nvim-lspconfig.
local lspConfigPath = vim.fn.stdpath("data") .. "/site/pack/start" .. "/nvim-lspconfig"
vim.opt.runtimepath:prepend(lspConfigPath)
```
