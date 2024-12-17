return {
	"chrisgrieser/nvim-genghis",
	init = function() vim.g.whichkeyAddSpec { "<leader>f", group = "󰈔 Files" } end,
	keys = {
		-- stylua: ignore start
		{"<leader>ya", function() require("genghis").copyFilepathWithTilde() end, desc = "󰝰 Absolute path" },
		{"<leader>yr", function() require("genghis").copyRelativePath() end, desc = "󰝰 Relative path" },
		{"<leader>yn", function() require("genghis").copyFilename() end, desc = "󰈔 Name of file" },
		{"<leader>yp", function() require("genghis").copyDirectoryPath() end, desc = "󰝰 Parent path" },
		{"<leader>yf", function() require("genghis").copyFileItself() end, desc = "󰈔 File (macOS)" },
		-- stylua: ignore end

		-- stylua: ignore
		{ "<D-l>", function() require("genghis").showInSystemExplorer() end, desc = "󰀶 Reveal in Finder" },
		{ "<leader>fr", function() require("genghis").renameFile() end, desc = "󰑕 Rename" },
		{ "<leader>fn", function() require("genghis").createNewFile() end, desc = " New" },
		{ "<leader>fd", function() require("genghis").duplicateFile() end, desc = " Duplicate" },
		{ "<leader>fm", function() require("genghis").moveToFolderInCwd() end, desc = "󰪹 Move" },
		{ "<leader>f<BS>", function() require("genghis").trashFile() end, desc = "󰩹 Trash" },

		-- stylua: ignore
		{ "<leader>rx", function() require("genghis").moveSelectionToNewFile() end, mode = "x", desc = " Selection to new file" },

		{ "<leader>ex", function() require("genghis").chmodx() end, desc = "󰒃 chmod +x" },
	},
}
