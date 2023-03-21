return {

	{ -- change cwd per project
		"ahmedkhalf/project.nvim",
		event = "VimEnter",
		config = function()
			require("project_nvim").setup {
				detection_methods = { "pattern", "lsp" }, -- prioty: pattern, then lsp
				exclude_dirs = { "node_modules", "build", "dist" },
				datapath = VimDataDir,
				patterns = {
					".git",
					"manifest.json", -- node
					"info.plist", -- Alfred
					".stylua.toml", -- lua
					".harpoon", -- manually marked
					"=File Hub", 
				},
			}
		end,
	},
	{ -- convenience file operations
		"chrisgrieser/nvim-genghis",
		lazy = true, -- loaded by keybindings
		dev = true,
		dependencies = "stevearc/dressing.nvim",
		init = function() vim.g.genghis_disable_commands = true end,
	},
}
