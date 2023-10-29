local u = require("config.utils")
--------------------------------------------------------------------------------

return {
	{ -- automatically set correct indent for file
		"nmac427/guess-indent.nvim",
		event = "BufReadPre",
		opts = {
			-- due to code blocks and bullets often having spaces or tabs
			filetype_exclude = { "markdown" },
		},
	},
	{ -- auto-save buffers
		"okuuva/auto-save.nvim",
		event = { "InsertLeave", "TextChanged" }, -- only needs to be loaded on files changes
		opts = {
			execution_message = { enabled = false },
			noautocmd = true, -- performance & conflicts with nvim-lint
			debounce_delay = 1000, -- save at most this many ms
		},
	},
	{ -- auto-close inactive buffers
		"chrisgrieser/nvim-early-retirement",
		event = "VeryLazy",
		opts = {
			retirementAgeMins = 10,
			ignoreUnsavedChangesBufs = false,
			notificationOnAutoClose = true,
			deleteBufferWhenFileDeleted = true,
		},
	},
	{ -- :bnext & :bprevious get visual overview of buffers
		"ghillb/cybu.nvim",
		keys = {
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
				highlights = { current_buffer = "CursorLine", adjacent_buffers = "Normal" },
			},
			behavior = {
				mode = {
					default = { switch = "immediate", view = "paging" },
				},
			},
		},
	},
	{ -- change cwd per project
		"ahmedkhalf/project.nvim",
		event = "VimEnter",
		main = "project_nvim",
		opts = {
			detection_methods = { "pattern" },
			patterns = {
				".git", -- git root
				"info.plist", -- Alfred workflows
				">.config", -- all subfolders of the dotfile directory
			},
		},
	},
	{ -- convenience file operations
		"chrisgrieser/nvim-genghis",
		dependencies = "stevearc/dressing.nvim",
		init = function() vim.g.genghis_disable_commands = true end,
		keys = {
			-- stylua: ignore start
			{"<C-p>", function() require("genghis").copyFilepath() end, desc = " Copy filepath" },
			{"<C-n>", function() require("genghis").copyFilename() end, desc = " Copy filename" },
			{"<C-r>", function() require("genghis").renameFile() end, desc = " Rename file" },
			{"<leader>x", function() require("genghis").chmodx() end, desc = " chmod +x" },
			{"<C-d>", function() require("genghis").duplicateFile() end, desc = " Duplicate file" },
			{"<D-BS>", function() require("genghis").trashFile() end, desc = " Move file to trash" },
			{"<D-n>", function() require("genghis").createNewFile() end, desc = " Create new file" },
			{"X", function() require("genghis").moveSelectionToNewFile() end, mode = "x", desc = " Selection to new file" },
			-- stylua: ignore end
		},
	},
}
