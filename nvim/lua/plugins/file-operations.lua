return {
	{ -- quick file siwtcher
		"ThePrimeagen/harpoon",
		lazy = true, -- loaded by keybinds
		dependencies = "nvim-lua/plenary.nvim",
		config = function()
			-- HACK to make Harpoon marks syncable across devices by creating symlink
			-- to the `harpoon.json` that is synced
			local symlinkCmd = string.format(
				"ln -sf '%s' '%s'",
				VimDataDir .. "/harpoon.json",
				vim.fn.stdpath("data") .. "/harpoon.json" -- https://github.com/ThePrimeagen/harpoon/blob/master/lua/harpoon/init.lua#L7
			)
			vim.fn.system(symlinkCmd)

			require("harpoon").setup {
				menu = {
					borderchars = BorderChars,
					width = 50,
					height = 8,
				},
			}
		end,
	},
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
