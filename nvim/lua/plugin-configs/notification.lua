-- DOCS Snacks.notifier
-- https://github.com/folke/snacks.nvim/blob/main/docs/notifier.md#%EF%B8%8F-config
--------------------------------------------------------------------------

---highlight via markdown filetype
---@param msg string
local function highlightErrors(msg)
	return msg
		:gsub("E%d+", "[%1]") -- error numbers
		:gsub(".+/.-%.%w+", "[%1]") -- filenames
end

local function snacksConfig()
	-- OVERRIDE DEFAULT PRINT FUNCTIONS
	_G.print = function(...)
		local msg = vim.iter({ ... }):flatten():map(tostring):join(" ")
		local opts = { title = "Print", icon = "󰐪" }
		if msg:find("^%[nvim%-treesitter%]") then
			opts = { title = "Treesitter", icon = "", id = "ts-install" }
		end
		vim.notify(vim.trim(msg), vim.log.levels.DEBUG, opts)
	end
	---@diagnostic disable-next-line: duplicate-set-field deliberate override
	vim.api.nvim_echo = function(chunks, _, _)
		local msg = vim.iter(chunks):map(function(chunk) return chunk[1] end):join(" ")
		local opts = { title = "Echo", icon = "" }
		if msg:lower():find("hunk") then
			msg = msg:gsub("^Hunk (%d+) of (%d+)", "Hunk [%1/%2]")
			opts = { icon = "󰊢", id = "gitsigns_nav_hunk", style = "minimal" }
		end
		vim.notify(vim.trim(msg), vim.log.levels.DEBUG, opts)
	end
	---@diagnostic disable-next-line: duplicate-set-field deliberate override
	vim.api.nvim_err_writeln = function(msg)
		msg = highlightErrors(msg)
		vim.notify(vim.trim(msg), vim.log.levels.ERROR, { title = "Error", ft = "markdown" })
	end
	-----------------------------------------------------------------------------

	-- HACK SILENCE SOME MESSAGES by overriding snacks' override
	vim.notify = function(msg, ...) ---@diagnostic disable-line: duplicate-set-field
		-- PENDING https://github.com/artempyanykh/marksman/issues/348
		if msg:find("^Client marksman quit with exit code 1") then return end
		require("snacks").notifier.notify(msg, ...)
	end

	-----------------------------------------------------------------------------
	-- SILENCE "E486: PATTERN NOT FOUND"
	-- (SIC yes, all this is needed to have `cmdheight=0` and avoid "Press Enter" prompt)

	local function notFoundNotify(query)
		local msg = ("%s"):format(query)
		vim.notify(msg .. " ", vim.log.levels.TRACE, { icon = "", style = "minimal", ft = "text" })
	end

	local function silenceSearch(key)
		local query = vim.fn.getreg("/")
		local matches = vim.fn.search(vim.fn.getreg("/"), "ncw") -- [n]o move, w/ [c]ursorword, [w]rap
		if matches > 0 then
			vim.cmd.normal { key, bang = true }
		else
			notFoundNotify(query)
		end
	end
	vim.keymap.set("n", "n", function() silenceSearch("n") end, { desc = "silent n" })
	vim.keymap.set("n", "N", function() silenceSearch("N") end, { desc = "silent N" })

	vim.api.nvim_create_autocmd("CmdlineEnter", {
		desc = "User: Change cmdline-height to silence Enter-prompt (1/2)",
		callback = function()
			if vim.fn.getcmdtype():find("[/?]") then vim.opt.cmdheight = 1 end
		end,
	})
	vim.api.nvim_create_autocmd("CmdlineLeave", {
		desc = "User: Change cmdline-height to silence Enter-prompt (2/2)",
		callback = function()
			if vim.fn.getcmdtype() ~= "/" then return end
			vim.defer_fn(function()
				vim.opt.cmdheight = 0
				if vim.fn.searchcount().total > 0 then return end
				vim.opt.hlsearch = false
				notFoundNotify(vim.fn.getreg("/"))
			end, 1)
		end,
	})
end

--------------------------------------------------------------------------------

return {
	"folke/snacks.nvim",
	event = "VeryLazy",
	config = function(_, opts)
		require("snacks").setup(opts)
		snacksConfig()
	end,
	keys = {
		{ "<Esc>", function() require("snacks").notifier.hide() end, desc = "󰎟 Dismiss notices" },
		{ "ö", function() require("snacks").words.jump(1, true) end, desc = "󰒕 Next reference" },
		{
			desc = "󰎟 Notification history",
			"<D-0>",
			function()
				local lines = {}
				local history = require("snacks").notifier.get_history()
				if #history == 0 then return end
				require("snacks").notifier.hide() -- dismiss open notifications
				vim
					.iter(require("snacks").notifier.get_history())
					:rev() -- move recent notifications to the top
					:each(function(notif)
						local msg = vim.split(notif.msg, "\n")
						local title = (notif.title and notif.title ~= "") and notif.title or "ﱢ"
						msg[1] = ("[%s] %s"):format(title, msg[1])
						vim.list_extend(lines, msg)
					end)
				local bufnr = vim.api.nvim_create_buf(false, true)
				vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
				vim.bo[bufnr].modifiable = false
				require("snacks").win {
					position = "bottom",
					ft = "markdown",
					buf = bufnr,
					height = 0.6,
					keys = { ["<D-0>"] = "close" },
				}
			end,
		},
		{
			desc = "󰎟 Last notification",
			"<D-9>",
			function()
				local history = require("snacks").notifier.get_history()
				local last = history[#history]
				if not last then return end
				require("snacks").notifier.hide(last.id) -- when opening last notif, dismiss it

				local bufnr = vim.api.nvim_create_buf(false, true)
				vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(last.msg, "\n"))
				vim.bo[bufnr].modifiable = false
				local title = vim.trim((last.icon or "") .. " " .. (last.title or ""))
				require("snacks").win {
					position = "float",
					ft = last.ft,
					buf = bufnr,
					height = 0.75,
					width = 0.75,
					title = vim.trim(title) ~= "" and " " .. title .. " " or nil,
					keys = { ["<D-9>"] = "close" },
				}
			end,
		},
		{
			desc = "󰎟 :messages",
			"<D-8>",
			function()
				local messages = highlightErrors(vim.fn.execute("messages"))
				if messages == "" then return end
				local lines = vim.split(messages, "\n", { trimempty = true })
				local bufnr = vim.api.nvim_create_buf(false, true)
				vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
				vim.bo[bufnr].modifiable = false
				require("snacks").win {
					position = "float",
					buf = bufnr,
					height = 0.75,
					width = 0.75,
					keys = { ["<D-8>"] = "close" },
					title = " :messages ",
					ft = "markdown", -- for error message highlights
				}
			end,
		},
	},
	opts = {
		words = {
			notify_jump = true,
			modes = { "n" },
			debounce = 300,
		},
		win = {
			keys = { q = "close", ["<Esc>"] = "close" },
			border = vim.g.borderStyle,
			wo = { cursorline = true, colorcolumn = "", winfixbuf = true },
		},
		notifier = {
			timeout = 6000,
			width = { min = 10, max = 0.45 },
			height = { min = 1, max = 0.4 },
			icons = { error = "", warn = "", info = "", debug = "", trace = "󰓘" },
			top_down = false,
		},
		styles = {
			notification = {
				border = vim.g.borderStyle,
				wo = { wrap = true, winblend = 0, cursorline = false },
			},
		},
	},
}
