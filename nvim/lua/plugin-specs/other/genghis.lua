---@module "lazy.types"
---@type LazyPluginSpec
return {
	"chrisgrieser/nvim-genghis",
	init = function()
		vim.g.whichkeyAddSpec { "<leader>f", group = "󰈔 File" }
		vim.g.whichkeyAddSpec { "<leader>y", group = "󰅍 Yank" }
	end,
	opts = {
		navigation = {
			onlySameExtAsCurrentFile = true,
		},
	},
	keys = {
		-- stylua: ignore start
		{"<leader>ya", function() require("genghis").copyFilepathWithTilde() end, desc = "󰝰 Absolute path" },
		{"<leader>yr", function() require("genghis").copyRelativePath() end, desc = "󰝰 Relative path" },
		{"<leader>yn", function() require("genghis").copyFilename() end, desc = "󰈔 Name of file" },
		{"<leader>yp", function() require("genghis").copyDirectoryPath() end, desc = "󰝰 Parent path" },
		{"<leader>yf", function() require("genghis").copyFileItself() end, desc = "󱉥 File (macOS)" },

		{ "<M-CR>", function() require("genghis").navigateToFileInFolder("next") end, desc = "󰖽 Next file in folder" },
		{ "<S-M-CR>", function() require("genghis").navigateToFileInFolder("prev") end, desc = "󰖿 Prev file in folder" },
		-- stylua: ignore end

		{ "<leader>fr", function() require("genghis").renameFile() end, desc = "󰑕 Rename" },
		{ "<leader>fn", function() require("genghis").createNewFile() end, desc = "󰝒 New" },
		{ "<leader>fw", function() require("genghis").duplicateFile() end, desc = " Duplicate" },
		{ "<leader>fm", function() require("genghis").moveToFolderInCwd() end, desc = "󱀱 Move" },
		{ "<leader>fd", function() require("genghis").trashFile() end, desc = "󰩹 Delete" },
		{ "<leader>fx", function() require("genghis").chmodx() end, desc = "󰒃 chmod +x" },

		{
			"<leader>rx",
			function() require("genghis").moveSelectionToNewFile() end,
			mode = "x",
			desc = "󰝒 Selection to new file",
		},
		-- stylua: ignore
		{ "<D-l>", function() require("genghis").showInSystemExplorer() end, desc = "󰀶 Reveal in Finder" },
	},
}
