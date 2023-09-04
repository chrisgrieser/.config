local u = require("config.utils")

--------------------------------------------------------------------------------

-- https://www.reddit.com/r/neovim/comments/12lf0ke/comment/jg6idvr/
-- DOCS https://github.com/folke/noice.nvim#-routes
local routes = {
	-- write messages
	{ filter = { event = "msg_show", find = "B written$" }, view = "mini" },

	-- nvim-early-retirement
	{
		filter = {
			event = "notify",
			cond = function(msg) return msg.opts and msg.opts.title == "Auto-Closing Buffer" end,
		},
		view = "mini",
	},

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

	-- code actions, especially annoying with ruff where the fixall code action
	-- is triggered on every format
	{ filter = { event = "notify", find = "^No code actions available$" }, skip = true },

	-- DAP
	{ filter = { event = "notify", find = "^Session terminated$" }, view = "mini" },

	-- redirect to split
	{ filter = { event = "msg_show", min_height = 15 }, view = "popup" },
	{ filter = { event = "notify", min_height = 15 }, view = "popup" },
}

-- HACK requires custom wrapping setup https://github.com/rcarriga/nvim-notify/issues/129
-- replaces vim.notify = require("notify")
local function customWrap(lines, max_width)

	local function split_length(line, width)
		local text = {}
		local next_line
		while true do
			if #line == 0 then return text end
			next_line, line = line:sub(1, width), line:sub(width)
			text[#text + 1] = next_line
		end
	end

	local wrappedLines = {}
	for _, line in pairs(lines) do
		local new_lines = split_length(line, max_width)
		new_lines = new_lines
		for _, nl in ipairs(new_lines) do
			nl = nl:gsub("^%s*", ""):gsub("%s*$", "")
			table.insert(wrappedLines, " " .. nl .. " ")
		end
	end

	return wrappedLines
end

---alternative compact renderer for nvim-notify. Modified version of https://github.com/rcarriga/nvim-notify/blob/master/lua/notify/render/compact.lua
---@param bufnr number
---@param notif object
---@param highlights object
---@param config object plugin configObj
local function compactWrapRender(bufnr, notif, highlights, config)
	local base = require("notify.render.base")
	local namespace = base.namespace()
	local icon = notif.icon
	local title = notif.title[1]
	local prefix
	local max_width = config.max_width

	local defaultTitles = { "Error", "Warning", "Notify" }
	local hasValidManualTitle = type(title) == "string"
		and #title > 0
		and not vim.tbl_contains(defaultTitles, title)
	if hasValidManualTitle then
		-- has title = icon + title as header row
		prefix = string.format("%s %s", icon, title)
		table.insert(notif.message, 1, prefix)
	else
		-- no title = prefix the icon
		prefix = string.format("%s ", icon)
		notif.message[1] = string.format("%s %s", prefix, notif.message[1])
	end

	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, notif.message)

	local icon_length = vim.str_utfindex(icon)
	local prefix_length = vim.str_utfindex(prefix) + 1

	vim.api.nvim_buf_set_extmark(bufnr, namespace, 0, 0, {
		hl_group = highlights.icon,
		end_col = icon_length + 1,
		priority = 50,
	})
	vim.api.nvim_buf_set_extmark(bufnr, namespace, 0, icon_length + 1, {
		hl_group = highlights.title,
		end_col = prefix_length + 1,
		priority = 50,
	})
	vim.api.nvim_buf_set_extmark(bufnr, namespace, 0, prefix_length + 1, {
		hl_group = highlights.body,
		end_line = #notif.message,
		priority = 50,
	})
end
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
					lua = { pattern = { "^:%s*lua%s+" }, view = "cmdline_popup" }, -- show the `=`
					help = { view = "cmdline_popup" },
					numb = {
						pattern = "^:%d+$",
						view = "cmdline",
						conceal = false,
					},
					IncRename = {
						pattern = "^:IncRename ",
						icon = " ",
						conceal = true,
						view = "cmdline_popup",
						opts = {
							border = { style = u.borderStyle },
							relative = "cursor",
							size = { width = 30 }, -- `max_width` does not work, so fixed value
							position = { row = -3, col = 0 },
						},
					},
					substitute = {
						view = "cmdline_popup",
						pattern = { "^:%%? ?s ", "^:'<,'> ?s " },
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
					size = { width = 90, height = 25 },
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
			render = compactWrapRender, -- minimal|default|compact|simple|custom function
			top_down = false,
			max_width = 40,
			minimum_width = 15,
			level = 0, -- minimum severity level to display (0 = display all)
			timeout = 7500,
			stages = "fade", -- slide|fade
			icons = { DEBUG = "", ERROR = "", INFO = "", TRACE = "", WARN = "" },
			on_open = function(win)
				if not vim.api.nvim_win_is_valid(win) then return end
				vim.api.nvim_win_set_config(win, { border = u.borderStyle })
			end,
		},
		init = function()
			vim.keymap.set("n", "<leader>ln", function()
				local history = require("notify").history()
				if #history == 0 then
					vim.notify(
						"No Notification in this session.",
						vim.log.levels.TRACE,
						{ title = "nvim-notify" }
					)
					return
				end
				local msg = history[#history].message
				vim.fn.setreg("+", msg)
				vim.notify("Last Notification copied.", vim.log.levels.TRACE, { title = "nvim-notify" })
			end, { desc = "󰎟 Copy Last Notification" })
		end,
	},
}
