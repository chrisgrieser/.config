-- use new install dir
local root = vim.fn.fnamemodify("./repro-root", ":p")
for _, name in ipairs({ "config", "data", "state", "cache" }) do
  vim.env[("XDG_%s_HOME"):format(name:upper())] = root .. "/" .. name
end


local plugins = {
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim", opts = true },
		opts = { ensure_installed = { "lua_ls" } },
	},
	{
		"neovim/nvim-lspconfig",
		init = function() require("lspconfig")["lua_ls"].setup({}) end,
	},
	{-- lsp definitions & references count as virtual text
		"roobert/action-hints.nvim",
		config = function()
			require("action-hints").setup {
				template = {
					{ " ⊛", "ActionHintsDefinition" },
					{ " ↱%s", "ActionHintsReferences" },
				},
				use_virtual_text = true,
				definition_color = "#add8e6",
				reference_color = "#ff6666",
			}
		end,
	},
}

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	-- stylua: ignore
	vim.fn.system { "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath }
end
vim.opt.runtimepath:prepend(lazypath)
require("lazy").setup(plugins, {
	dev = {
		path = os.getenv("HOME") .. "/Repos",
		fallback = true, -- use remote repo when local repo doesn't exist
	},
})

-- base appearance to not make me crazy
vim.cmd.colorscheme("habamax")
vim.opt.guifont = "JetBrainsMonoNL Nerd Font:h25.2"
vim.opt.signcolumn = "yes:2"

--------------------------------------------------------------------------------
