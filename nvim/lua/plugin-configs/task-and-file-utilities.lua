return {
	{
		"chrisgrieser/nvim-justice",
		keys = {
			{ "<leader>j", function() require("justice").select() end, desc = "󰖷 Just" },
		},
		opts = {
			recipes = {
				ignore = {
					name = { "release", "^_" },
					comment = { "interactive" },
				},
				streaming = {
					name = { "download" },
					comment = { "streaming", "curl" },
				},
				quickfix = {
					name = { "%-qf$" },
					comment = { "quickfix" },
				},
			},
			window = { border = vim.g.borderStyle },
			keymaps = {
				closeWin = { "q", "<Esc>", "<D-w>" },
				quickSelect = { "j", "f", "d", "s", "a" },
			},
		},
	},
	{
		"chrisgrieser/nvim-genghis",
		dependencies = "stevearc/dressing.nvim",
		keys = {
		-- stylua: ignore start
		{"<leader>ya", function() require("genghis").copyFilepathWithTilde() end, desc = "󰞇 Absolute path" },
		{"<leader>yr", function() require("genghis").copyRelativePath() end, desc = "󰞇 Relative path" },
		{"<leader>yn", function() require("genghis").copyFilename() end, desc = "󰞇 Filename" },

		{"<C-r>", function() require("genghis").renameFile() end, desc = "󰞇 Rename file" },
		{"<D-n>", function() require("genghis").createNewFile() end, desc = "󰞇 Create new file" },
		{"<C-d>", function() require("genghis").duplicateFile() end, desc = "󰞇 Duplicate file" },
		{"<D-M>", function() require("genghis").moveToFolderInCwd() end, desc = "󰞇 Move file" },
		{"<leader>fx", function() require("genghis").moveSelectionToNewFile() end, mode = "x", desc = "󰞇 Selection to new file" },

		{"<D-BS>", function() require("genghis").trashFile() end, desc = "󰞇 Move file to trash" },
		{"<leader>ex", function() require("genghis").chmodx() end, desc = "󰞇 chmod +x" },
			-- stylua: ignore end
		},
	},
}
