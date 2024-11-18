return {
	{
		"chrisgrieser/nvim-justice",
		keys = {
			{ "<leader>j", function() require("justice").select() end, desc = "Justice" },
		},
		opts = {
			recipes = {
				ignore = { "run-fzf", "release" }, -- for recipes that require user input
				streaming = { "run-streaming" },
				quickfix = { "check-tsc" },
			},
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
		{"<C-p>", function() require("genghis").copyFilepathWithTilde() end, desc = "󰞇 Copy absolute path" },
		{"<C-t>", function() require("genghis").copyRelativePath() end, desc = "󰞇 Copy relative path" },
		{"<C-n>", function() require("genghis").copyFilename() end, desc = "󰞇 Copy filename" },

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
