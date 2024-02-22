return {
	{ -- convenience file operations
		"chrisgrieser/nvim-genghis",
		external_dependencies = "macos-trash",
		dependencies = "stevearc/dressing.nvim",
		init = function() vim.g.genghis_disable_commands = true end,
		keys = {
			-- stylua: ignore start
			{"<C-p>", function() require("genghis").copyFilepathWithTilde() end, desc = " Copy path (with ~)" },
			{"<C-t>", function() require("genghis").copyRelativePath() end, desc = " Copy relative path" },
			{"<C-n>", function() require("genghis").copyFilename() end, desc = " Copy filename" },
			{"<C-r>", function() require("genghis").renameFile() end, desc = " Rename file" },
			{"<D-m>", function() require("genghis").moveToFolderInCwd() end, desc = " Move file" },
			{"<leader>x", function() require("genghis").chmodx() end, desc = " chmod +x" },
			{"<C-d>", function() require("genghis").duplicateFile() end, desc = " Duplicate file" },
			{"<D-BS>", function() require("genghis").trashFile() end, desc = " Move file to trash" },
			{"<D-n>", function() require("genghis").createNewFile() end, desc = " Create new file" },
			{"X", function() require("genghis").moveSelectionToNewFile() end, mode = "x", desc = " Selection to new file" },
			-- stylua: ignore end
		},
	},
	{ -- harpoon with better UI
		"otavioschwanck/arrow.nvim",
		event = "VeryLazy", -- for status line component
		keys = {
			";", -- leader-key
			{ "<D-CR>", function() require("arrow.persist").next() end, desc = "󱡁 Next arrow" },
			{
				"<D-d>", -- cmd+d (like bookmarking in the browser)
				function() require("arrow.persist").toggle() end,
				desc = "󱡁 (Un-)Mark as arrow",
			},
		},
		opts = {
			show_icons = true,
			leader_key = ";", -- cmd+shift+d
			index_keys = "jkluiop",
			save_path = function() return vim.g.syncedData .. "/arrow-nvim-bookmarks" end,
			window = { border = vim.g.borderStyle },
		},
		config = function(_, opts)
			require("arrow").setup(opts)

			require("config.utils").addToLuaLine(
				"sections",
				"lualine_a",
				require("arrow.statusline").text_for_statusline_with_icons,
				"before"
			)
		end,
	},
}
