-- Bootstrap lazy.nvim https://lazy.folke.io/installation
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out =
		vim.fn.system { "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath }
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

--------------------------------------------------------------------------------

local myPlugins = {
	{ -- install LSPs
		"williamboman/mason.nvim",
		opts = {},
		dependencies = {
			{
				"WhoIsSethDaniel/mason-tool-installer.nvim", -- auto-install LSPs
				opts = {
					ensure_installed = {
						"lua_ls",
						"tsserver",
						-- add other LSPs here, fine the names in this list: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
					},
					run_on_start = true,
				},
			},
			"williamboman/mason-lspconfig.nvim", -- make mason & lspconfig work together
		},
	},
	{ -- auto-setup LSPs
		"neovim/nvim-lspconfig",
		config = function()
			-- enable completions via nvim-cmp
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities.textDocument.completion.completionItem.snippetSupport = true

			-- run this for each LSP
			require("lspconfig").lua_ls.setup {
				capabilities = capabilities,
				settings = {},
			}
			require("lspconfig").tsserver.setup {
				capabilities = capabilities,
				settings = {},
			}
		end,
	},
	{ -- Completion Engine
		"hrsh7th/nvim-cmp",
		dependencies = "hrsh7th/cmp-nvim-lsp", -- make cmp work with LSPs
		config = function()
			local cmp = require("cmp")
			cmp.setup {
				mapping = cmp.mapping.preset.insert {
					["<CR>"] = cmp.mapping.confirm { select = true },
					["<C-e>"] = cmp.mapping.abort(),
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-p>"] = cmp.mapping.select_prev_item(),
				},
			}
		end,
	},
}

--------------------------------------------------------------------------------
-- tell lazy to load the plugins
require("lazy").setup {
	spec = myPlugins,
}
