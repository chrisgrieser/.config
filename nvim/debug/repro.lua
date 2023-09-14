-- DO NOT change the paths and don't remove the colorscheme
local root = vim.fn.fnamemodify("./.repro", ":p")

-- set stdpaths to use .repro
for _, name in ipairs { "config", "data", "state", "cache" } do
	vim.env[("XDG_%s_HOME"):format(name:upper())] = root .. "/" .. name
end

-- bootstrap lazy
local lazypath = root .. "/plugins/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system {
		"git",
		"clone",
		"--filter=blob:none",
		"--single-branch",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	}
end
vim.opt.runtimepath:prepend(lazypath)

-- install plugins
local plugins = {
	"folke/tokyonight.nvim",
	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup {
				log_level = vim.log.levels.DEBUG,
				formatters_by_ft = {
					["*"] = { "codespell" },
				},

				-- custom formatters
				formatters = {
					codespell = {
						command = "codespell",
						stdin = false,
						args = { "$FILENAME", "--write-changes", "--quiet-level=16" },
					},
				},
			}
		end,
	},
	-- add any other plugins here
}
require("lazy").setup(plugins, {
	root = root .. "/plugins",
})

vim.cmd.colorscheme("tokyonight")
-- add anything else here

--------------------------------------------------------------------------------

vim.opt.guifont = "JetBrainsMonoNL Nerd Font:h25.2"
vim.keymap.set("<D-s>", function() require("conform").format { lsp_fallback = true } end)
vim.opt.swap = false
