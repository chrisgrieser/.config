local u = require("config.utils")
--------------------------------------------------------------------------------

local function getReplBinary()
	-- INFO using bypthon, since other REPLs have issues
	-- with docstrings & indentation when paired with iron.nvim
	local alternativeRepl = "bpython" -- CONFIG
	local venvPython = vim.env.VIRTUAL_ENV .. "/bin/python"

	-- if no venv, fallback to system python/repl
	if not venvPython then
		local altAvailable = vim.fn.executable(alternativeRepl) == 1
		local binary = altAvailable and alternativeRepl or "python3"
		return { binary }
	end

	local venvAltRepl = venvPython:gsub("python$", alternativeRepl)
	local altAvailable = vim.fn.executable(venvAltRepl) == 1
	local binary = altAvailable and venvAltRepl or venvPython
	return { binary }
end

--------------------------------------------------------------------------------

return {
	"Vigemus/iron.nvim",
	init = function() u.leaderSubkey("r", "󱠤 Iron") end,
	keys = {
		{ "<leader>rt", vim.cmd.IronRepl, desc = "󱠤 Toggle" },
		{
			"<leader>rR",
			function() -- FIX :IronRestart Bug
				require("iron.core").close_repl()
				vim.defer_fn(vim.cmd.IronRepl, 100)
			end,
			desc = "󱠤 Restart",
		},
		{ "<leader>rr", function() require("iron.core").send_line() end, desc = "󱠤 Run Line" },
		{
			"<leader>rc",
			function() require("iron.core").send_until_cursor() end,
			desc = "󱠤 Run to Cursor",
		},
		-- HACK to be able to set everything in `keys`, using the raw functions
		-- provided by iron instead of mapping via opts.keymaps from iron
		{
			"<leader>ri",
			function() require("iron.core").send(nil, string.char(03)) end,
			desc = "󱠤 Interrupt",
		},
		{
			"<leader>rk",
			function() require("iron.core").send(nil, string.char(12)) end,
			desc = "󱠤 Clear",
		},
	},
	config = function()
		require("iron.core").setup {
			config = {
				repl_open_cmd = require("iron.view")("35%", { winhighlight = "Normal:NormalFloat" }),
				repl_definition = {
					sh = { command = { "zsh" } },
					lua = { command = { "luajit" } }, -- luajit already instead as nvim-dependency
					typescript = { command = { "node" } },
					javascript = { command = { "osascript", "-i", "-l", "JavaScript" } }, -- JXA
					applescript = { command = { "osascript", "-i", "-l", "AppleScript" } },
					python = { command = getReplBinary },
				},
			},
		}
	end,
}
