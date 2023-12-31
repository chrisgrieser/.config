local u = require("config.utils")
--------------------------------------------------------------------------------

return {
	{ -- harpoon with better UI
		"otavioschwanck/arrow.nvim",
		event = "VeryLazy", -- for status line component
		config = function()
			u.addToLuaLine(
				"sections",
				"lualine_a",
				require("arrow.statusline").text_for_statusline_with_icons,
				"before"
			)
			require("arrow").setup {
				show_icons = true,
				leader_key = "<D-D>", -- cmd+shift+d
				-- saved in dotfiles folder for syncing purposes
				save_path = function() return vim.fn.stdpath("config") .. "/bookmarks" end,
				save_key = function() return (vim.loop.cwd() or "") .. ".txt" end,
			}
		end,
		keys = {
			"<D-D>",
			{ "<D-CR>", function() require("arrow.persist").next() end, desc = "󱡁 Next arrow" },
			{
				"<D-d>", -- cmd+d
				function() require("arrow.persist").toggle() end,
				desc = "󱡁 Mark/Unmark as arrow",
			},
		},
	},
	{ -- auto-close inactive buffers
		"chrisgrieser/nvim-early-retirement",
		event = "VeryLazy",
		opts = {
			retirementAgeMins = 10,
			minimumBufferNum = 4, -- 3 or fewer never closed
			ignoreUnsavedChangesBufs = false,
			notificationOnAutoClose = true,
			deleteBufferWhenFileDeleted = true,
		},
	},
	{ -- :bnext & :bprevious get visual overview of buffers
		"ghillb/cybu.nvim",
		keys = {
			{ "<BS>", function() require("cybu").cycle("prev") end, desc = "󰽙 Previous Buffer" },
			{ "<S-BS>", function() require("cybu").cycle("next") end, desc = "󰽙 Next Buffer" },
		},
		dependencies = { "nvim-tree/nvim-web-devicons", "nvim-lua/plenary.nvim" },
		opts = {
			display_time = 1000,
			position = {
				anchor = "bottomcenter",
				max_win_height = 12,
				vertical_offset = 3,
			},
			style = {
				border = vim.g.myBorderStyle,
				padding = 7,
				path = "tail",
				hide_buffer_id = false,
				highlights = { current_buffer = "CursorLine", adjacent_buffers = "Normal" },
			},
			behavior = {
				mode = {
					default = { switch = "immediate", view = "paging" },
				},
			},
		},
	},
	{ -- convenience file operations
		"chrisgrieser/nvim-genghis",
		dependencies = "stevearc/dressing.nvim",
		init = function() vim.g.genghis_disable_commands = true end,
		keys = {
			-- stylua: ignore start
			{"<C-p>", function() require("genghis").copyFilepath() end, desc = " Copy filepath" },
			{"<C-t>", function() require("genghis").copyRelativePath() end, desc = " Copy relative path" },
			{"<C-n>", function() require("genghis").copyFilename() end, desc = " Copy filename" },
			{"<C-r>", function() require("genghis").renameFile() end, desc = " Rename file" },
			{"<D-m>", function() require("genghis").moveAndRenameFile() end, desc = " Move-Rename file" },
			{"<leader>x", function() require("genghis").chmodx() end, desc = " chmod +x" },
			{"<C-d>", function() require("genghis").duplicateFile() end, desc = " Duplicate file" },
			{"<D-BS>", function() require("genghis").trashFile() end, desc = " Move file to trash" },
			{"<D-n>", function() require("genghis").createNewFile() end, desc = " Create new file" },
			{"X", function() require("genghis").moveSelectionToNewFile() end, mode = "x", desc = " Selection to new file" },
			-- stylua: ignore end
		},
	},
}
