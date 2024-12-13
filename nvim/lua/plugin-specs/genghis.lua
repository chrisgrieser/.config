return {
	"chrisgrieser/nvim-genghis",
	keys = {
		-- stylua: ignore start
		{"<leader>ya", function() require("genghis").copyFilepathWithTilde() end, desc = "󰝰 Absolute path" },
		{"<leader>yr", function() require("genghis").copyRelativePath() end, desc = "󰝰 Relative path" },
		{"<leader>yn", function() require("genghis").copyFilename() end, desc = "󰈔 Filename" },
		{"<leader>yp", function() require("genghis").copyDirectoryPath() end, desc = "󰝰 Parent path" },
		{"<leader>yf", function() require("genghis").copyFileItself() end, desc = "󰈔 File (macOS)" },
		-- stylua: ignore end

		{ "<C-r>", function() require("genghis").renameFile() end, desc = "󰑕 Rename file" },
		{ "<D-n>", function() require("genghis").createNewFile() end, desc = " Create new file" },
		{ "<C-d>", function() require("genghis").duplicateFile() end, desc = " Duplicate file" },
		{ "<D-M>", function() require("genghis").moveToFolderInCwd() end, desc = "󰪹 Move file" },
		{
			"<leader>rx",
			function() require("genghis").moveSelectionToNewFile() end,
			mode = "x",
			desc = " Selection to new file",
		},

		{ "<D-BS>", function() require("genghis").trashFile() end, desc = "󰩹 Move file to trash" },
		{ "<leader>ex", function() require("genghis").chmodx() end, desc = "󰒃 chmod +x" },
	},
}
