local u = require("config.utils")

return {
	{ -- auto-save buffers
		"okuuva/auto-save.nvim",
		event = { "InsertLeave", "TextChanged" }, -- only needs to be loaded on files changes
		opts = {
			execution_message = { enabled = false },
			noautocmd = true, -- false would be buggy with :FormatWrite
			debounce_delay = 1000, -- save at most this many ms
			condition = function(buf)
				local isRegularBuffer = vim.api.nvim_buf_get_option(buf, "buftype") == ""
				return isRegularBuffer
			end,
		},
	},
	{
		"rgroli/other.nvim",
		keys = {
			{ "<D-CR>", "<cmd>Other<cr>", desc = " Open Other File" },
		},
		opts = {
			-- by default there are no mappings enabled
				mappings = {},

				-- Should the window show files which do not exist yet based on
				-- pattern matching. Selecting the files will create the file.
				showMissingFiles = true,

				-- When a mapping requires an initial selection of the other file, this setting controls,
				-- wether the selection should be remembered for the current user session.
				-- When this option is set to false reference between the two buffers are never saved.
				-- Existing references can be removed on the buffer with :OtherClear
				rememberBuffers = true,

				keybindings = {
					["<cr>"] = "open_file()",
					["<esc>"] = "close_window()",
					t = "open_file_tabnew()",
					o = "open_file()",
					q = "close_window()",
					v = "open_file_vs()",
					s = "open_file_sp()",
				},

				hooks = {
					-- This hook which is executed when the file-picker is shown.
					-- It could be used to filter or reorder the files in the filepicker.
					-- The function must return a lua table with the same structure as the input parameter.
					--
					-- The input parameter "files" is a lua table with each entry containing:
					-- @param table (filename (string), context (string), exists (boolean))
					-- @return table
					filePickerBeforeShow = function(files)
						return files
					end,

					-- This hook is called whenever a file is about to be opened.
					-- One example how this can be used: a non existing file needs to be opened by another plugin, which provides a template.
					--
					-- @param filename (string) the full-path of the file
					-- @param exists (boolean) doess the file already exist
					-- @return (boolean) When true (default) the plugin takes care of opening the file, when the function returns false this indicated that opening of the file is done in the hook.
					onOpenFile = function(filename, exists)
						return true
					end,
				},

				style = {
					-- How the plugin paints its window borders
					-- Allowed values are none, single, double, rounded, solid and shadow
					border = "solid",

					-- Column seperator for the window
					seperator = "|",

					-- Indicator showing that the file does not yet exist
					newFileIndicator = "(* new *)",

					-- width of the window in percent. e.g. 0.5 is 50%, 1 is 100%
					width = 0.7,

					-- min height in rows.
					-- when more columns are needed this value is extended automatically
					minHeight = 2,
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
			notificationOnAutoClose = false,
		},
	},
	{ -- change cwd per project
		"ahmedkhalf/project.nvim",
		event = "VimEnter",
		main = "project_nvim", -- main module name needed
		opts = {
			detection_methods = { "pattern", "lsp" }, -- prioty: pattern, then lsp root
			exclude_dirs = { "node_modules", "build", "dist", "venv" },
			datapath = u.vimDataDir,
			patterns = {
				".git",
				"Makefile",
				"pyproject.toml", -- python
				"requirements.txt", -- python
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
