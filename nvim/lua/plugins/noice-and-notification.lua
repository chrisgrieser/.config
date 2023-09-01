local u = require("config.utils")
--------------------------------------------------------------------------------

-- https://www.reddit.com/r/neovim/comments/12lf0ke/comment/jg6idvr/
-- DOCS https://github.com/folke/noice.nvim#-routes
local routes = {
	-- write messages
	{ filter = { event = "msg_show", find = "B written$" }, view = "mini" },

	-- nvim-treesitter
	{ filter = { event = "msg_show", find = "^%[nvim%-treesitter%]" }, view = "mini" },
	{ filter = { event = "msg_show", find = "All parsers are up-to-date!" }, view = "mini" },

	-- Word added to spellfile via
	{ filter = { event = "msg_show", find = "^Word .*%.add$" }, view = "mini" },

	-- Mason
	{ filter = { event = "notify", find = "successfully u?n?installed.$" }, view = "mini" },
	{ filter = { event = "notify", find = "^%[mason%-" }, view = "mini" },

	-- Codeium.nvim
	{ filter = { event = "notify", find = "^Codeium.nvim:" }, view = "mini" },
	{ filter = { event = "notify", find = "downloading server" }, view = "mini" },
	{ filter = { event = "notify", find = "unpacking server" }, view = "mini" },

	-- unneeded info on search patterns
	{ filter = { event = "msg_show", find = "^[/?]." }, skip = true },
	{ filter = { event = "msg_show", find = "^E486: Pattern not found" }, view = "mini" },

	-- redirect to split
	{ filter = { event = "msg_show", min_height = 15 }, view = "popup" },
	{ filter = { event = "notify", min_height = 15 }, view = "popup" },
}

--------------------------------------------------------------------------------

return {
	{
		"folke/noice.nvim",
		dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
		event = "VeryLazy",
		init = function()
			-- stylua: ignore
			vim.keymap.set("n", "<Esc>", function() vim.cmd.Noice("dismiss") end, { desc = "󰎟 Clear Notifications" })

			-- Toggle Log
			vim.keymap.set({ "n", "x", "i" }, "<D-0>", function()
				vim.cmd.Noice("dismiss")
				vim.cmd.Noice("history")
			end, { desc = "󰎟 Notification Log" })
		end,
		opts = {
			routes = routes,
			cmdline = {
				view = "cmdline", -- cmdline|cmdline_popup
				format = {
					cmdline = { view = "cmdline_popup" },
					search_down = { icon = "  ", view = "cmdline" }, -- FIX needed to be set explicitly
					lua = { pattern = { "^:%s*lua%s+" }, view = "cmdline_popup"  }, -- show the `=`
					help = { view = "cmdline_popup" },
					IncRename = {
						pattern = "^:IncRename ",
						icon = " ",
						conceal = true,
						view = "cmdline_popup" ,
						opts = {
							border = { style = u.borderStyle },
							relative = "cursor",
							size = { width = 30 }, -- `max_width` does not work, so fixed value
							position = { row = -3, col = 0 },
						},
					},
					substitute = {
						view = "cmdline_popup" ,
						pattern = { "^:%%? ?s" },
						icon = " ",
						conceal = true,
					},
				},
			},
			-- https://github.com/folke/noice.nvim/blob/main/lua/noice/config/views.lua
			views = {
				cmdline_popup = {
					border = { style = u.borderStyle },
				},
				mini = { timeout = 3000 },
				hover = {
					border = { style = u.borderStyle },
					size = { max_width = 80 },
					win_options = { scrolloff = 4 },
				},
				popup = {
					border = { style = u.borderStyle },
					size = { width = 80 },
					win_options = { scrolloff = 4 },
				},
				split = {
					enter = true,
					size = "40%",
					close = { keys = { "q", "<D-w>", "<D-0>" } },
					win_options = { scrolloff = 2 },
				},
			},
			commands = {
				-- options for `:Noice history`
				history = {
					view = "split",
					filter_opts = { reverse = true }, -- show newest entries first
					opts = { enter = true },
					filter = {}, -- empty list = deactivate filter = include everything
				},
			},

			-- popupmenu = { backend = "nui" }, -- replace with nvim-cmp, since more sources

			-- DISABLED, since conflicts with existing plugins I prefer to use
			messages = { view_search = false }, -- replaced by nvim-hlslens
			lsp = {
				progress = { enabled = false }, -- replaced with nvim-dr-lsp, since this one cannot filter null-ls
				signature = { enabled = false }, -- replaced with lsp_signature.nvim

				-- ENABLED features
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
		},
	},
	{ -- Notifications
		"rcarriga/nvim-notify",
		-- does not play nice with the terminal
		cond = function() return vim.fn.has("gui_running") == 1 end,
		opts = {
			render = "minimal", -- minimal|default|compact
			top_down = false,
			max_width = 70,
			minimum_width = 15,
			level = 0, -- minimum severity level to display (0 = display all)
			timeout = 7500,
			stages = "slide",
			on_open = function(win)
				if not vim.api.nvim_win_is_valid(win) then return end
				vim.api.nvim_win_set_config(win, { border = u.borderStyle })
			end,
		},
		init = function()
			vim.keymap.set("n", "<leader>ln", function()
				local history = require("notify").history()
				if #history == 0 then
					vim.notify("No Notification in this session.", u.warn)
					return
				end
				local msg = history[#history].message
				vim.fn.setreg("+", msg)
				vim.notify("Last Notification copied.", u.trace)
			end, { desc = "󰎟 Copy Last Notification" })
		end,
	},
}
