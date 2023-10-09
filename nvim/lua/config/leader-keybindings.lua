local autocmd = vim.api.nvim_create_autocmd
local bo = vim.bo
local cmd = vim.cmd
local fn = vim.fn
local u = require("config.utils")
local keymap = require("config.utils").uniqueKeymap

--------------------------------------------------------------------------------
-- META
keymap("n", "<D-;>", function()
	local pathOfThisFile = debug.getinfo(1).source:sub(2)
	vim.cmd.edit(pathOfThisFile)
end, { desc = "⌨️ Edit leader-keybindings.lua" })

--------------------------------------------------------------------------------

-- Copy Last Command
keymap("n", "<leader>lc", function()
	local lastCommand = fn.getreg(":")
	if lastCommand == "" then
		u.notify("", "No last command available", "warn")
		return
	end
	lastCommand = lastCommand:gsub("^i ", ""):gsub("^lua ?=? ", "")
	fn.setreg("+", lastCommand)
	u.notify("Copied", lastCommand)
end, { desc = "󰘳 Copy last command" })

-- [l]ast command a[g]ain
-- as opposed to `@:`, `:<Up><CR>` works across sessions
keymap("n", "<leader>lg", ":<Up><CR>", { desc = "󰘳 Run last command again", silent = true })

-- show current filetype & buftype
keymap("n", "<leader>lf", function()
	local out = {
		"filetype: " .. bo.filetype,
		"buftype: " .. bo.buftype,
		"scrolloff: " .. vim.opt_local.scrolloff:get(),
		("indent: %s (%s)"):format(bo.expandtab and "spaces" or "tabs", bo.tabstop),
		"node at cursor: " .. vim.treesitter.get_node():type(),
	}
	u.notify("Buffer Information", table.concat(out, "\n"), "trace")
end, { desc = "󰽘 Inspect Buffer Info" })

--------------------------------------------------------------------------------
-- REFACTORING
keymap("n", "<leader>ff", ":% s/<C-r><C-w>//g<Left><Left>", { desc = " :s (cursor word)" })
keymap("x", "<leader>ff", [["zy:% s/<C-r>z//g<Left><Left>]], { desc = " :s (selection)" })
keymap("x", "<leader>fv", ":s///g<Left><Left><Left>", { desc = " :s (inside visual)" })
keymap("n", "<leader>fd", ":g//d<Left><Left>", { desc = " delete matching" })

keymap("n", "<leader>f<Tab>", function()
	bo.expandtab = false
	bo.tabstop = 3
	cmd.retab { bang = true }
	u.notify("Indent", "Now using 󰌒 (width 3)")
end, { desc = "󰌒 Use Tabs" })

keymap("n", "<leader>f<Space>", function()
	bo.tabstop = 2
	bo.expandtab = true
	cmd.retab { bang = true }
	u.notify("Indent", "Now using 󱁐 (2)")
end, { desc = "󱁐 Use Spaces" })

--------------------------------------------------------------------------------

-- UNDO
keymap(
	"n",
	"<leader>ur",
	function() cmd("silent later " .. tostring(vim.opt.undolevels:get())) end,
	{ desc = "󰛒 Redo All" }
)
keymap("n", "<leader>ul", "U", { desc = "– Undo line" })

keymap(
	{ "n", "x" },
	"<leader>uc",
	function() require("funcs.alt-alt").reopenBuffer() end,
	{ desc = "󰽙 Undo buffer closing" }
)

-- save open time for each buffer
autocmd("BufReadPost", {
	---@diagnostic disable-next-line: inject-field
	callback = function() vim.b.timeOpened = os.time() end,
})

keymap("n", "<leader>uo", function()
	local now = os.time() -- saved in epoch secs
	local secsPassed = now - vim.b.timeOpened
	cmd.earlier(tostring(secsPassed) .. "s")
end, { desc = "󰜊 Undo since last open" })

--------------------------------------------------------------------------------
-- LSP

---@param action object CodeAction Object https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#codeAction
---@return boolean
local function codeActionFilter(action)
	local title, kind, ft = action.title, action.kind, vim.bo.filetype

	-- in lua, ignore all quickfixes except line disables and all "move argument" actions
	local ignoreInLua = ft == "lua"
		and not (title:find("on this line"))
		and (kind == "quickfix" or kind == "refactor.rewrite")

	-- in python, ignore ruff actions except for line disables
	local ignoreInPython = ft == "python"
		and title:find("^Ruff")
		and not (title:find("Disable for this line$"))
	return not (ignoreInLua or ignoreInPython)
end

-- INFO use `lua require('nvim-lightbulb').debug()` to inspect code action kinds
keymap(
	{ "n", "x" },
	"<leader>c",
	function() vim.lsp.buf.code_action { filter = codeActionFilter } end,
	{ desc = "󰒕 Code Action" }
)
keymap("n", "<leader>h", vim.lsp.buf.hover, { desc = "󰒕 Hover" })

--------------------------------------------------------------------------------

-- LOGGING
-- stylua: ignore start
keymap({ "n", "x" }, "<leader>lm", function() require("funcs.sawmill").messageLog() end, { desc = "󰸢 message log" })
keymap({ "n", "x" }, "<leader>ll", function() require("funcs.sawmill").variableLog() end, { desc = "󰸢 variable log" })
keymap({ "n", "x" }, "<leader>lo", function() require("funcs.sawmill").objectLog() end, { desc = "󰸢 object log" })
keymap("n", "<leader>lb", function() require("funcs.sawmill").beepLog() end, { desc = "󰸢 beep log" })
keymap("n", "<leader>l1", function() require("funcs.sawmill").timeLog() end, { desc = "󰸢 time log" })
keymap("n", "<leader>lr", function() require("funcs.sawmill").removeLogs() end, { desc = "󰸢  remove log" })
keymap("n", "<leader>ld", function() require("funcs.sawmill").debugLog() end, { desc = "󰸢 debugger log" })
keymap("n", "<leader>la", function() require("funcs.sawmill").assertLog() end, { desc = "󰸢 assert log" })
-- stylua: ignore end

keymap("n", "<leader>li", cmd.Inspect, { desc = " :Inspect" })
keymap("n", "<leader>lt", cmd.InspectTree, { desc = " :InspectTree" })

--------------------------------------------------------------------------------

-- Merging & Splitting Lines
keymap({ "n", "x" }, "<leader>m", "ddpkJ", { desc = "󰗈 Merge line down" })
keymap(
	"x",
	"<leader>s",
	[[<Esc>`>a<CR><Esc>`<i<CR><Esc>=j]],
	{ desc = "󰗈 Split around selection" }
)

-- Append to / delete from EoL
local trailChars = { ",", ";", ")", "'", '"', "|", "\\", "{", "." }
for _, key in pairs(trailChars) do
	keymap("n", "<leader>" .. key, "mzA" .. key .. "<Esc>`z", { desc = "which_key_ignore" })
end

--------------------------------------------------------------------------------
-- PEEK WIN
keymap(
	"n",
	"<leader>w",
	function() require("funcs.quality-of-life").pinWin() end,
	{ desc = " Pin Window" }
)

-- MAKE
keymap(
	"n",
	"<leader>r",
	function() require("funcs.maker").make("runFirst") end,
	{ desc = " Make First" }
)
keymap("n", "<leader>R", function() require("funcs.maker").make() end, { desc = " Select Make" })

--------------------------------------------------------------------------------
-- OPTION TOGGLING

-- stylua: ignore
keymap("n", "<leader>or", "<cmd>set relativenumber!<CR>", { desc = " Relative Line Numbers" })
keymap("n", "<leader>on", "<cmd>set number!<CR>", { desc = " Line Numbers" })
keymap("n", "<leader>ol", "<cmd>LspRestart<CR>", { desc = "󰒕 LspRestart" })
keymap("n", "<leader>oh", function() vim.lsp.inlay_hint(0, nil) end, { desc = "󰒕 Inlay Hints" })

keymap("n", "<leader>od", function() -- codespell-ignore
	if vim.diagnostic.is_disabled(0) then
		vim.diagnostic.enable(0)
	else
		vim.diagnostic.disable(0)
		vim.diagnostic.disable(0)
	end
end, { desc = " Diagnostics" })

keymap(
	"n",
	"<leader>ow",
	function() require("funcs.quality-of-life").wrap("toggle") end,
	{ desc = "󰖶 Wrap" }
)

-- FIX scrolloff
keymap("n", "<leader>of", function() vim.opt.scrolloff = 13 end, { desc = "󰘖 Fix Scrolloff" })

--------------------------------------------------------------------------------
