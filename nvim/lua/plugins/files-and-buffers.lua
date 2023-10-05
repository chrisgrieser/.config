local u = require("config.utils")
--------------------------------------------------------------------------------

return {
	{ -- auto-save buffers
		"okuuva/auto-save.nvim",
		event = { "InsertLeave", "TextChanged" }, -- only needs to be loaded on files changes
		opts = {
			execution_message = { enabled = false },
			noautocmd = true,
			debounce_delay = 1000, -- save at most this many ms
		},
	},
	{ -- auto-close inactive buffers
		"chrisgrieser/nvim-early-retirement",
		enabled = false,
		event = "VeryLazy",
		opts = {
			retirementAgeMins = 15,
			ignoreUnsavedChangesBufs = false,
			notificationOnAutoClose = true,
			deleteBufferWhenFileDeleted = false,
		},
	},
	{ -- change cwd per project
		"ahmedkhalf/project.nvim",
		event = "VimEnter",
		main = "project_nvim",
		opts = {
			detection_methods = { "pattern", "lsp" }, -- priority: pattern, then lsp-root
			exclude_dirs = { "node_modules", "build", "dist", ".venv", "venv" },
			datapath = u.vimDataDir,
			patterns = {
				".git",
				"Makefile",
				".editorconfig",
				"pyproject.toml", -- python
				"requirements.txt", -- python
				"manifest.json", -- node
				"package.json", -- node
				"info.plist", -- Alfred
				".luarc.json", -- lua
				"selene.toml", -- lua
				"stylua.toml", -- lua
				".project-root", -- manually marked
				">com~apple~CloudDocs", -- = all subfolders of the iCloud drive
				">Repos", -- = all subfolders of the Repos folder
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
			{"<D-m>", function() require("genghis").moveAndRenameFile() end, desc = " Move & rename file" },
			{"X", function() require("genghis").moveSelectionToNewFile() end, mode = "x", desc = " Selection to new file" },
			-- stylua: ignore end
		},
	},
}
