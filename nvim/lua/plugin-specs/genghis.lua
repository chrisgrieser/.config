vim.pack.add { "https://github.com/chrisgrieser/nvim-genghis" }
--------------------------------------------------------------------------------

require("genghis").setup {
	navigation = { onlySameExtAsCurrentFile = false },
}

--------------------------------------------------------------------------------

vim.g.whichkeyAddSpec { "<leader>f", group = "󰈔 File" }
vim.g.whichkeyAddSpec { "<leader>y", group = "󰅍 Yank" }

-- stylua: ignore start
Keymap {"<leader>ya", function() require("genghis").copyFilepathWithTilde() end, desc = "󰝰 Absolute path" }
Keymap {"<leader>yr", function() require("genghis").copyRelativePath() end, desc = "󰝰 Relative path" }
Keymap {"<leader>yn", function() require("genghis").copyFilename() end, desc = "󰈔 Name of file" }
Keymap {"<leader>yp", function() require("genghis").copyDirectoryPath() end, desc = "󰝰 Parent path" }
Keymap {"<leader>yf", function() require("genghis").copyFileItself() end, desc = "󱉥 File (macOS)" }

Keymap { "<M-CR>", function() require("genghis").navigateToFileInFolder("next") end, desc = "󰖽 Next file in folder" }
Keymap { "<S-M-CR>", function() require("genghis").navigateToFileInFolder("prev") end, desc = "󰖿 Prev file in folder" }
Keymap { "<D-l>", function() require("genghis").showInSystemExplorer() end, desc = "󰀶 Reveal in Finder" }
-- stylua: ignore end

Keymap { "<leader>fr", function() require("genghis").renameFile() end, desc = "󰑕 Rename" }
Keymap { "<leader>fw", function() require("genghis").duplicateFile() end, desc = " Duplicate" }
Keymap { "<leader>fm", function() require("genghis").moveToFolderInCwd() end, desc = "󱀱 Move" }
Keymap { "<leader>fd", function() require("genghis").trashFile() end, desc = "󰩹 Delete" }
Keymap { "<leader>fx", function() require("genghis").chmodx() end, desc = "󰒃 chmod +x" }

Keymap {
	"<leader>fn",
	function() require("genghis").createNewFileInFolder() end,
	desc = "󰝒 New in folder",
}
Keymap {
	"<leader>fn",
	function() require("genghis").moveSelectionToNewFile() end,
	mode = "x",
	desc = "󰝒 New file from selection",
}
Keymap { "<leader>fN", function() require("genghis").createNewFile() end, desc = "󰝒 New" }
