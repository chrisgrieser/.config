return {
	{
		"chrisgrieser/nvim-justice",
		keys = {
			{ "<leader>j", function() require("justice").select() end, desc = "󰖷 Just" },
		},
		opts = {
			ignore = {
				name = { "release", "fzf", "^_" },
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
