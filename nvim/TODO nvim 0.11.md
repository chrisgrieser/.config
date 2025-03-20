- `:help ]q`, replaces `:cnext`
- `vim.diagnostic.jump()`
- `vim.lsp.buf.hover.Opts`
- `vim.lsp.buf.signature_help.Opts`
- potentially replace `nvim-ufo` with <https://www.reddit.com/r/neovim/comments/1h34lr4/neovim_now_has_the_builtin_lsp_folding_support/>
- silence "press enter to continue" messages via `messagesopt`
- `vim.lsp.enable()` and `vim.lsp.config()`
- cursor shape in `nvim-terminal`: <https://github.com/neovim/neovim/issues/3681>
- `:h vim.lsp.hover()` options set here now?

> The 0.11 version will have built-in snippet engine (`vim.snippet`)
> automatically map `<Tab>/<S-Tab>` to jump forward/backward. May require
> adjusting your config if you have those keys mapped in Insert mode.

- Replace `vim.g.borderStyle` with `vim.o.winborder`
	- in vim opts config
	- in my plugin configs
