local u = require("config.utils")

return {
	{ -- auto-save buffers
		"okuuva/auto-save.nvim",
		event = { "InsertLeave", "TextChanged" }, -- only needs to be loaded on files changes
		opts = {
			execution_message = { enabled = false },
			noautocmd = false, -- needed for nvim-lint
			debounce_delay = 1000, -- save at most this many ms
			condition = function(buf)
				local isRegularBuffer = vim.api.nvim_buf_get_option(buf, "buftype") == ""
				return isRegularBuffer
			end,
		},
	},
	{ -- auto-close inactive buffers
		"chrisgrieser/nvim-early-retirement",
		dev = true,
		event = "VeryLazy",
		opts = {
			retirementAgeMins = 20,
			ignoreUnsavedChangesBufs = false,
			notificationOnAutoClose = false,
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
				"package.json", -- node
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
			{"<leader>x", function() require("genghis").chmodx() end, desc = " chmod +x" },
			{"<C-d>", function() require("genghis").duplicateFile() end, desc = " Duplicate file" },
			{"<D-BS>", function() require("genghis").trashFile() end, desc = " Move file to trash" },
			{"<D-n>", function() require("genghis").createNewFile() end, desc = " Create new file" },
			{"X", function() require("genghis").moveSelectionToNewFile() end, mode = "x", desc = " Selection to new file" },
			-- stylua: ignore end
		},
	},
}
