local u = require("config.utils")

return {
	{ -- quick file siwtcher
		"ThePrimeagen/harpoon",
		lazy = true, -- loaded by keybinds
		dependencies = "nvim-lua/plenary.nvim",
		build = function()
			-- HACK to make Harpoon marks syncable across devices by creating symlink
			-- to the `harpoon.json` that is synced
			local symlinkCmd = string.format(
				"ln -sf '%s' '%s'",
				require("config.utils").vimDataDir .. "/harpoon.json",
				vim.fn.stdpath("data") .. "/harpoon.json" -- https://github.com/ThePrimeagen/harpoon/blob/master/lua/harpoon/init.lua#L7
			)
			vim.fn.system(symlinkCmd)
		end,
		opts = {
			menu = {
				borderchars = u.borderChars,
				width = 50,
				height = 8,
			},
		},
	},
	{ -- Cycle Buffers
		"ghillb/cybu.nvim",
		event = "BufEnter", -- cannot load on <Plug> key for whatever reason
		dependencies = { "nvim-tree/nvim-web-devicons", "nvim-lua/plenary.nvim" },
		opts = {
			display_time = 1000,
			position = {
				anchor = "bottomcenter",
				max_win_height = 12,
				vertical_offset = 3,
			},
			style = {
				border = u.borderStyle,
				padding = 7,
				path = "tail",
				hide_buffer_id = true,
				highlights = {
					current_buffer = "CursorLine",
					adjacent_buffers = "Normal",
				},
			},
			behavior = {
				mode = {
					default = {
						switch = "immediate",
						view = "paging",
					},
				},
			},
		},
	},
	{ -- auto-close inactive buffers
		"chrisgrieser/nvim-early-retirement",
		dev = true,
		event = "VeryLazy",
		opts = {
			retirementAgeMins = 20,
			ignoredFiletypes = {},
			ignoreUnsavedChangesBufs = false,
		},
	},
	{ -- change cwd per project
		"ahmedkhalf/project.nvim",
		event = "VimEnter",
		main = "project_nvim", -- main module name needed
		opts = {
			detection_methods = { "pattern", "lsp" }, -- prioty: pattern, then lsp
			exclude_dirs = { "node_modules", "build", "dist" },
			datapath = u.vimDataDir,
			patterns = {
				".git",
				"manifest.json", -- node
				"info.plist", -- Alfred
				".luarc.json", -- lua
				".project-root", -- manually marked
				"=File Hub",
			},
		},
	},
	{ -- convenience file operations
		"chrisgrieser/nvim-genghis",
		lazy = true, -- loaded by keybindings
		dev = true,
		dependencies = "stevearc/dressing.nvim",
		init = function() vim.g.genghis_disable_commands = true end,
	},
}
