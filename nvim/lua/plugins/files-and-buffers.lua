local u = require("config.utils")

return {
	{ -- :bnext & :bprevious get visual overview of buffers
		"ghillb/cybu.nvim",
		keys = {
			-- not mapping via <Plug>, since that prevents lazyloading
			-- functions names from: https://github.com/ghillb/cybu.nvim/blob/c0866ef6735a85f85d4cf77ed6d9bc92046b5a99/plugin/cybu.lua#L38
			{ "<BS>", function() require("cybu").cycle("next") end, desc = "󰽙 Next Buffer" },
			{ "<S-BS>", function() require("cybu").cycle("prev") end, desc = "󰽙 Previous Buffer" },
		},
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
			ignoreUnsavedChangesBufs = false,
			notificationOnAutoClose = true,
		},
	},
	{ -- change cwd per project
		"ahmedkhalf/project.nvim",
		event = "VimEnter",
		main = "project_nvim", -- main module name needed
		opts = {
			detection_methods = { "pattern", "lsp" }, -- prioty: pattern, then lsp root
			exclude_dirs = { "node_modules", "build", "dist" },
			datapath = u.vimDataDir,
			patterns = {
				".git",
				"Makefile",
				"manifest.json", -- node
				"info.plist", -- Alfred
				".luarc.json", -- lua
				".project-root", -- manually marked
				">com~apple~CloudDocs", -- = all subfolders of the iCloud folders
			},
		},
	},
	{ -- convenience file operations
		"chrisgrieser/nvim-genghis",
		dev = true,
		dependencies = "stevearc/dressing.nvim",
		init = function() vim.g.genghis_disable_commands = true end,
		keys = {
			-- stylua: ignore start
			{"<C-p>", function() require("genghis").copyFilepath() end, desc = " Copy filepath" },
			{"<C-n>", function() require("genghis").copyFilename() end, desc = " Copy filename" },
			{"<C-r>", function() require("genghis").renameFile() end, desc = " Rename file" },
			{"<C-d>", function() require("genghis").duplicateFile() end, desc = " Duplicate file" },
			{"<D-BS>", function() require("genghis").trashFile() end, desc = " Move file to trash" },
			{"<D-n>", function() require("genghis").createNewFile() end, desc = " Create new file" },
			{"X", function() require("genghis").moveSelectionToNewFile() end, mode = "x", desc = " Selection to new file" },
			-- stylua: ignore end
		},
	},
}
