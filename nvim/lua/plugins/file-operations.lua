return {
	{ -- quick file siwtcher
		"ThePrimeagen/harpoon",
		lazy = true,
		dependencies = "nvim-lua/plenary.nvim",
		config = function()
			require("harpoon").setup {
				menu = {
					borderchars = BorderChars,
					width = 50,
					height = 8,
				},
			}

			-- HACK to make Harpoon marks syncable across devices by creating symlink
			-- to the `harpoon.json` that is synced
			local symlinkCmd = string.format(
				"ln -sf '%s' '%s'",
				VimDataDir .. "/harpoon.json",
				vim.fn.stdpath("data") .. "/harpoon.json" -- https://github.com/ThePrimeagen/harpoon/blob/master/lua/harpoon/init.lua#L7
			)
			vim.fn.system(symlinkCmd)
		end,
	},
	{ -- change cwd per project
		"ahmedkhalf/project.nvim",
		event = "VimEnter",
		config = function()
			require("project_nvim").setup {
				detection_methods = { "pattern", "lsp" }, -- prioty: pattern, then lsp
				patterns = {
					".git",
					"package.json", -- node projects
					"=File Hub", -- my general-inbox-working-directory
					"info.plist", -- Alfred workflows
					".stylua.toml", -- lua projects
					".harpoon", -- manually mark certain folders as project roots
				},
				exclude_dirs = { "node_modules", "build", "dist" },
				datapath = VimDataDir,
			}
		end,
	},
	{ -- convenience file operations
		"chrisgrieser/nvim-genghis",
		lazy = true,
		dev = true,
		dependencies = "stevearc/dressing.nvim",
		init = function() vim.g.genghis_disable_commands = true end,
	},
}
