return {
	{ -- convenience file operations
		"chrisgrieser/nvim-genghis",
		external_dependencies = "macos-trash",
		dependencies = "stevearc/dressing.nvim",
		cmd = "Genghis",
		keys = {
			-- stylua: ignore start
			{"<C-p>", function() require("genghis").copyFilepath() end, desc = "󰞇 Copy path" },
			{"<C-t>", function() require("genghis").copyRelativePath() end, desc = "󰞇 Copy relative path" },
			{"<C-n>", function() require("genghis").copyFilename() end, desc = "󰞇 Copy filename" },
			{"<C-r>", function() require("genghis").renameFile() end, desc = "󰞇 Rename file" },

			{"<D-n>", function() require("genghis").createNewFile() end, desc = "󰞇 Create new file" },
			{"<C-d>", function() require("genghis").duplicateFile() end, desc = "󰞇 Duplicate file" },
			{"<D-M>", function() require("genghis").moveToFolderInCwd() end, desc = "󰞇 Move file" },
			{"<leader>fx", function() require("genghis").moveSelectionToNewFile() end, mode = "x", desc = "󰞇 Selection to new file" },

			{"<D-BS>", function() require("genghis").trashFile() end, desc = "󰞇 Move file to trash" },
			{"<leader>x", function() require("genghis").chmodx() end, desc = "󰞇 chmod +x" },
			-- stylua: ignore end
		},
	},
}
