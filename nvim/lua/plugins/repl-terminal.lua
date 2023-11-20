--# selene: allow(mixed_table) -- lazy.nvim uses them
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
	{ -- Notebook Emulation
		"GCBallesteros/NotebookNavigator.nvim",
		dependencies = "Vigemus/iron.nvim", -- repl provider
		init = function() u.leaderSubkey("n", " Notebook") end,
		keys = {
			-- stylua: ignore start
			{ "gn", function() require("notebook-navigator").move_cell("d") end, desc = " Next cell" },
			{ "gN", function() require("notebook-navigator").move_cell("u") end, desc = " Prev cell" },
			{ "<leader>ns", function ()
				local marker = vim.bo.commentstring:format("%%")
				local ln = vim.api.nvim_win_get_cursor(0)[1]
				vim.api.nvim_buf_set_lines(0, ln, ln, false, { marker })
			end, desc = " Split cell" },
			{ "<leader>nb", function() require("notebook-navigator").add_cell_after() end, desc = " New cell below" },
			{ "<D-CR>", function() require("notebook-navigator").run_cell() end, desc = "  Run cell" },
			-- stylua: ignore end
		},
		opts = { syntax_highlight = true }, -- hl of cell markers
	},
	{ -- REPL Provider
		"Vigemus/iron.nvim",
		keys = {
			{ "<leader>nn", vim.cmd.IronRepl, desc = "󱠤 Toggle" },
			{
				"<leader>nr",
				function() -- FIX :IronRestart Bug
					require("iron.core").close_repl()
					vim.defer_fn(vim.cmd.IronRepl, 100)
				end,
				desc = "󱠤 Restart",
			},
			{ "<leader>nl", function() require("iron.core").send_line() end, desc = "󱠤 Run Line" },
			{
				"<leader>nc",
				function() require("iron.core").send_until_cursor() end,
				desc = "󱠤 Run to Cursor",
			},
			-- HACK to be able to set everything in `keys`, using the raw functions
			-- provided by iron instead of mapping via opts.keymaps from iron
			-- stylua: ignore start
			{ "<leader>ni", function() require("iron.core").send(nil, string.char(03)) end, desc = "󱠤 Interrupt" },
			{ "<leader>nk", function() require("iron.core").send(nil, string.char(12)) end, desc = "󱠤 Clear" },
			-- stylua: ignore end
		},
		config = function()
			local view = require("iron.view")
			require("iron.core").setup {
				config = {
					repl_open_cmd = view.split("35%", { winhighlight = "Normal:NormalFloat" }),
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
	},
}
