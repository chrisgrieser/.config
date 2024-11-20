-- DOCS Snacks.notifier
-- https://github.com/folke/snacks.nvim/blob/main/docs/notifier.md#%EF%B8%8F-config
--------------------------------------------------------------------------

local function snacksConfig()
	-- OVERRIDE DEFAULT PRINT FUNCTIONS (similar to `noice.nvim`)
	_G.print = function(...)
		local msg = vim.iter({ ... }):flatten():map(tostring):join(" ")
		local opts = { title = "Print", icon = "󰐪" }
		if msg:find("^%[nvim%-treesitter%]") then
			opts = { icon = "", id = "ts-install", style = "minimal" }
		end
		vim.notify(vim.trim(msg), vim.log.levels.DEBUG, opts)
	end
	---@diagnostic disable-next-line: duplicate-set-field deliberate override
	vim.api.nvim_echo = function(chunks, _, _)
		local msg = vim.iter(chunks):map(function(chunk) return chunk[1] end):join(" ")
		local opts = { title = "Echo", icon = "" }
		local severity = "DEBUG"
		if msg:lower():find("hunk") then
			msg = msg:gsub("^Hunk (%d+) of (%d+)", "Hunk [%1/%2]") -- [] for markdown highlight
			opts = { icon = "󰊢", id = "gitsigns_nav_hunk", style = "minimal" }
			severity = "TRACE"
		end
		vim.notify(vim.trim(msg), vim.log.levels[severity], opts)
	end
	---@diagnostic disable-next-line: duplicate-set-field deliberate override
	vim.api.nvim_err_writeln = function(msg)
		vim.notify(vim.trim(msg), vim.log.levels.ERROR, { title = "Error", ft = "text" })
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
	-- (yes, all this is needed to have `cmdheight=0` & avoid the "Press Enter" prompt)

	local function notFoundNotify(query)
		local msg = ("~~%s~~"):format(query) -- add markdown strikethrough
		vim.notify(msg, vim.log.levels.TRACE, { icon = "", style = "minimal" })
	end

	local function stopNkeyOnNoMatch(key)
		local query = vim.fn.getreg("/")
		local matches = vim.fn.search(vim.fn.getreg("/"), "ncw") -- [n]o move, w/ [c]ursorword, [w]rap
		if matches == 0 then
			notFoundNotify(query)
			return
		end
		vim.cmd.normal { key, bang = true }
	end
	vim.keymap.set("n", "n", function() stopNkeyOnNoMatch("n") end, { desc = "silent n" })
	vim.keymap.set("n", "N", function() stopNkeyOnNoMatch("N") end, { desc = "silent N" })

	vim.api.nvim_create_autocmd("CmdlineEnter", {
		desc = "User: Increase cmdline-height when in cmdline (silence enter-prompt 1/2)",
		callback = function()
			if vim.fn.getcmdtype() == "/" then vim.opt.cmdheight = 1 end
		end,
	})
	vim.api.nvim_create_autocmd("CmdlineLeave", {
		desc = "User: Decrease cmdline-height after leaving (silence enter-prompt 2/2)",
		callback = function()
			if vim.fn.getcmdtype() ~= "/" then return end
			vim.defer_fn(function()
				vim.opt.cmdheight = 0
				if vim.fn.searchcount().total == 0 then
					vim.opt.hlsearch = false -- no highlight in notification win
					notFoundNotify(vim.fn.getreg("/"))
				end
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
		{ "ö", function() require("snacks").words.jump(1, true) end, desc = "󰒕 Next reference" },
		{ "<Esc>", function() require("snacks").notifier.hide() end, desc = "󰎟 Dismiss notices" },
		{
			"<D-0>",
			function() require("personal-plugins.snacks-notif-hist").full() end,
			mode = { "n", "x", "i" },
			desc = "󰎟 Notification history",
		},
		{
			"<D-9>",
			function() require("personal-plugins.snacks-notif-hist").last() end,
			mode = { "n", "x", "i" },
			desc = "󰎟 Last notification",
		},
		{
			"<D-8>",
			function() require("personal-plugins.snacks-notif-hist").messages() end,
			mode = { "n", "x", "i" },
			desc = "󰎟 :messages",
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
			bo = { modifiable = false },
			wo = { cursorline = true, colorcolumn = "", winfixbuf = true, wrap = true },
		},
		notifier = {
			timeout = 6000,
			sort = { "added" }, -- sort only by time
			width = { min = 10, max = 0.5 },
			height = { min = 1, max = 0.6 },
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
