## Config structure
<a href="https://dotfyle.com/chrisgrieser/config-nvim"><img src="https://dotfyle.com/chrisgrieser/config-nvim/badges/plugins?style=flat" /></a>
<a href="https://dotfyle.com/chrisgrieser/config-nvim"><img src="https://dotfyle.com/chrisgrieser/config-nvim/badges/leaderkey?style=flat" /></a>
<a href="https://dotfyle.com/chrisgrieser/config-nvim"><img src="https://dotfyle.com/chrisgrieser/config-nvim/badges/plugin-manager?style=flat" /></a>

<!-- editorconfig-checker-disable -->
```text
├── lua
│  ├── config # keybindings, options, …
│  ├── funcs # utility functions / private plugins
│  └── plugins # plugins & their configs
├── after
│  └── ftplugin # filetype-specific configs
├── queries # modifications of treesitter queries
├── mac-helper # opener for neovide on macOS
├── snippets # VS Code Style for portability
│  ├── basic
│  └── project-specific
├── templates # skeleton files
└── tool-configs # custom configs for efm
   ├── formatters
   └── linters
```
<!-- editorconfig-checker-enable -->

```lua
print("hi")
```

The tree was generated using <https://tree.nathanfriend.io/>

## All Installed Plugins

### test
- [Aasim-A/scrollEOF.nvim](https://github.com/Aasim-A/scrollEOF.nvim)
- [EdenEast/nightfox.nvim](https://github.com/EdenEast/nightfox.nvim)
- [Exafunction/codeium.vim](https://github.com/Exafunction/codeium.vim)
- [HiPhish/rainbow-delimiters.nvim](https://github.com/HiPhish/rainbow-delimiters.nvim)
- [L3MON4D3/LuaSnip](https://github.com/L3MON4D3/LuaSnip)
- [MunifTanjim/nui.nvim](https://github.com/MunifTanjim/nui.nvim)
- [RRethy/nvim-treesitter-endwise](https://github.com/RRethy/nvim-treesitter-endwise)
- [SmiteshP/nvim-navic](https://github.com/SmiteshP/nvim-navic)
- [ThePrimeagen/refactoring.nvim](https://github.com/ThePrimeagen/refactoring.nvim)
- [Vigemus/iron.nvim](https://github.com/Vigemus/iron.nvim)
- [Vimjas/vim-python-pep8-indent](https://github.com/Vimjas/vim-python-pep8-indent)
- [Wansmer/sibling-swap.nvim](https://github.com/Wansmer/sibling-swap.nvim)
- [Wansmer/symbol-usage.nvim](https://github.com/Wansmer/symbol-usage.nvim)
- [Wansmer/treesj](https://github.com/Wansmer/treesj)
- [WhoIsSethDaniel/mason-tool-installer.nvim](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim)
- [ahmedkhalf/project.nvim](https://github.com/ahmedkhalf/project.nvim)
- [andymass/vim-matchup](https://github.com/andymass/vim-matchup)
- [chrisgrieser/cmp-nerdfont](https://github.com/chrisgrieser/cmp-nerdfont)
- [chrisgrieser/nvim-dr-lsp](https://github.com/chrisgrieser/nvim-dr-lsp)
- [chrisgrieser/nvim-early-retirement](https://github.com/chrisgrieser/nvim-early-retirement)
- [chrisgrieser/nvim-genghis](https://github.com/chrisgrieser/nvim-genghis)
- [chrisgrieser/nvim-origami](https://github.com/chrisgrieser/nvim-origami)
- [chrisgrieser/nvim-puppeteer](https://github.com/chrisgrieser/nvim-puppeteer)
- [chrisgrieser/nvim-recorder](https://github.com/chrisgrieser/nvim-recorder)
- [chrisgrieser/nvim-rulebook](https://github.com/chrisgrieser/nvim-rulebook)
- [chrisgrieser/nvim-spider](https://github.com/chrisgrieser/nvim-spider)
- [chrisgrieser/nvim-tinygit](https://github.com/chrisgrieser/nvim-tinygit)
- [chrisgrieser/nvim-various-textobjs](https://github.com/chrisgrieser/nvim-various-textobjs)
- [danielfalk/smart-open.nvim](https://github.com/danielfalk/smart-open.nvim)
- [danymat/neogen](https://github.com/danymat/neogen)
- [dkarter/bullets.vim](https://github.com/dkarter/bullets.vim)
- [dmitmel/cmp-cmdline-history](https://github.com/dmitmel/cmp-cmdline-history)
- [dnlhc/glance.nvim](https://github.com/dnlhc/glance.nvim)
- [echasnovski/mini.operators](https://github.com/echasnovski/mini.operators)
- [folke/lazy.nvim](https://github.com/folke/lazy.nvim)
- [folke/neodev.nvim](https://github.com/folke/neodev.nvim)
- [folke/noice.nvim](https://github.com/folke/noice.nvim)
- [folke/tokyonight.nvim](https://github.com/folke/tokyonight.nvim)
- [folke/which-key.nvim](https://github.com/folke/which-key.nvim)
- [gabrielpoca/replacer.nvim](https://github.com/gabrielpoca/replacer.nvim)
- [gbprod/yanky.nvim](https://github.com/gbprod/yanky.nvim)
- [ghillb/cybu.nvim](https://github.com/ghillb/cybu.nvim)
- [hail2u/vim-css3-syntax](https://github.com/hail2u/vim-css3-syntax)
- [haringsrob/nvim_context_vt](https://github.com/haringsrob/nvim_context_vt)
- [hrsh7th/cmp-buffer](https://github.com/hrsh7th/cmp-buffer)
- [hrsh7th/cmp-cmdline](https://github.com/hrsh7th/cmp-cmdline)
- [hrsh7th/cmp-emoji](https://github.com/hrsh7th/cmp-emoji)
- [hrsh7th/cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp)
- [hrsh7th/cmp-path](https://github.com/hrsh7th/cmp-path)
- [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
- [iamcco/markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim)
- [jbyuki/one-small-step-for-vimkind](https://github.com/jbyuki/one-small-step-for-vimkind)
- [jghauser/fold-cycle.nvim](https://github.com/jghauser/fold-cycle.nvim)
- [jinh0/eyeliner.nvim](https://github.com/jinh0/eyeliner.nvim)
- [johmsalas/text-case.nvim](https://github.com/johmsalas/text-case.nvim)
- [kevinhwang91/nvim-hlslens](https://github.com/kevinhwang91/nvim-hlslens)
- [kevinhwang91/nvim-ufo](https://github.com/kevinhwang91/nvim-ufo)
- [kevinhwang91/promise-async](https://github.com/kevinhwang91/promise-async)
- [kkharji/sqlite.lua](https://github.com/kkharji/sqlite.lua)
- [kylechui/nvim-surround](https://github.com/kylechui/nvim-surround)
- [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)
- [lewis6991/satellite.nvim](https://github.com/lewis6991/satellite.nvim)
- [linux-cultist/venv-selector.nvim](https://github.com/linux-cultist/venv-selector.nvim)
- [lukas-reineke/headlines.nvim](https://github.com/lukas-reineke/headlines.nvim)
- [lukas-reineke/indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim)
- [mbbill/undotree](https://github.com/mbbill/undotree)
- [mfussenegger/nvim-dap-python](https://github.com/mfussenegger/nvim-dap-python)
- [mfussenegger/nvim-dap](https://github.com/mfussenegger/nvim-dap)
- [mfussenegger/nvim-lint](https://github.com/mfussenegger/nvim-lint)
- [mg979/vim-visual-multi](https://github.com/mg979/vim-visual-multi)
- [mityu/vim-applescript](https://github.com/mityu/vim-applescript)
- [monaqa/dial.nvim](https://github.com/monaqa/dial.nvim)
- [nacro90/numb.nvim](https://github.com/nacro90/numb.nvim)
- [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
- [nmac427/guess-indent.nvim](https://github.com/nmac427/guess-indent.nvim)
- [numToStr/Comment.nvim](https://github.com/numToStr/Comment.nvim)
- [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [nvim-lualine/lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)
- [nvim-telescope/telescope-fzf-native.nvim](https://github.com/nvim-telescope/telescope-fzf-native.nvim)
- [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [nvim-tree/nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)
- [nvim-treesitter/nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects)
- [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- [okuuva/auto-save.nvim](https://github.com/okuuva/auto-save.nvim)
- [ray-x/cmp-treesitter](https://github.com/ray-x/cmp-treesitter)
- [ray-x/lsp_signature.nvim](https://github.com/ray-x/lsp_signature.nvim)
- [rcarriga/nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui)
- [rcarriga/nvim-notify](https://github.com/rcarriga/nvim-notify)
- [saadparwaiz1/cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip)
- [sindrets/diffview.nvim](https://github.com/sindrets/diffview.nvim)
- [smjonas/inc-rename.nvim](https://github.com/smjonas/inc-rename.nvim)
- [sourcegraph/sg.nvim](https://github.com/sourcegraph/sg.nvim)
- [stevearc/conform.nvim](https://github.com/stevearc/conform.nvim)
- [stevearc/dressing.nvim](https://github.com/stevearc/dressing.nvim)
- [tamago324/cmp-zsh](https://github.com/tamago324/cmp-zsh)
- [theHamsta/nvim-dap-virtual-text](https://github.com/theHamsta/nvim-dap-virtual-text)
- [tzachar/cmp-fuzzy-buffer](https://github.com/tzachar/cmp-fuzzy-buffer)
- [tzachar/fuzzy.nvim](https://github.com/tzachar/fuzzy.nvim)
- [tzachar/highlight-undo.nvim](https://github.com/tzachar/highlight-undo.nvim)
- [uga-rosa/ccc.nvim](https://github.com/uga-rosa/ccc.nvim)
- [utilyre/sentiment.nvim](https://github.com/utilyre/sentiment.nvim)
- [williamboman/mason-lspconfig.nvim](https://github.com/williamboman/mason-lspconfig.nvim)
- [williamboman/mason.nvim](https://github.com/williamboman/mason.nvim)
- [windwp/nvim-autopairs](https://github.com/windwp/nvim-autopairs)

This list was auto-generated [with this small shell script.](https://nanotipsforvim.prose.sh/list-all-your-installed-plugins). Also, you can check out [the nvim plugins I authored myself](https://github.com/chrisgrieser?tab=repositories&q=nvim&type=source&language=&sort=stargazers).
