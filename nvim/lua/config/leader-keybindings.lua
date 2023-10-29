local autocmd = vim.api.nvim_create_autocmd
local bo = vim.bo
local cmd = vim.cmd
local fn = vim.fn
local u = require("config.utils")
local keymap = require("config.utils").uniqueKeymap

--------------------------------------------------------------------------------
-- META
local pathOfThisFile = debug.getinfo(1).source:sub(2)
keymap(
	"n",
	"<D-;>",
	function() vim.cmd.edit(pathOfThisFile) end,
	{ desc = "⌨️ Edit " .. vim.fs.basename(pathOfThisFile) }
)

--------------------------------------------------------------------------------

-- Copy Last Command
keymap("n", "<leader>lc", function()
	local lastCommand = fn.getreg(":")
	fn.setreg("+", lastCommand)
	u.notify("Copied", lastCommand)
end, { desc = "󰘳 Copy last command" })

-- [l]ast command a[g]ain
keymap("n", "<leader>lg", ":<Up><CR>", { desc = "󰘳 Run last command again", silent = true })

-- show current filetype & buftype
keymap("n", "<leader>lf", function()
	local out = {
		"filetype: " .. bo.filetype,
		"buftype: " .. bo.buftype,
		("indent: %s (%s)"):format(bo.expandtab and "spaces" or "tabs", bo.tabstop),
	}
	local ok, node = pcall(vim.treesitter.get_node)
	if ok and node then table.insert(out, "node: " .. node:type()) end
	u.notify("Buffer Information", table.concat(out, "\n"), "trace")
end, { desc = " Buffer Info" })

--------------------------------------------------------------------------------
-- REFACTORING
keymap("n", "<leader>ff", ":% s/<C-r><C-w>//g<Left><Left>", { desc = " :s (cursor word)" })
keymap("x", "<leader>ff", [["zy:% s/<C-r>z//g<Left><Left>]], { desc = " :s (selection)" })
keymap("x", "<leader>fv", ": s///g<Left><Left><Left>", { desc = " :s (inside visual)" })
keymap("n", "<leader>fd", ":g//d<Left><Left>", { desc = " delete matching" })

---@param useSpaces boolean
local function retabber(useSpaces)
	local char = useSpaces and "󱁐" or "󰌒"
	bo.expandtab = useSpaces
	bo.tabstop = 2
	cmd.retab { bang = true }
	if not useSpaces then bo.tabstop = 3 end
	u.notify("Indent", ("Now using %s"):format(char))
end
keymap("n", "<leader>f<Tab>", function() retabber(false) end, { desc = "󰌒 Use Tabs" })
keymap("n", "<leader>f<Space>", function() retabber(true) end, { desc = "󱁐 Use Spaces" })

--------------------------------------------------------------------------------
-- UNDO

keymap(
	"n",
	"<leader>ur",
	function() cmd("silent later " .. tostring(vim.opt.undolevels:get())) end,
	{ desc = "󰛒 Redo All" }
)

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
	local now = os.time()
	local secsPassed = now - vim.b.timeOpened
	cmd.earlier(tostring(secsPassed) .. "s")
end, { desc = "󰜊 Undo since last open" })

--------------------------------------------------------------------------------
-- LSP

---@param action object CodeAction https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#codeAction
---@return boolean
local function codeActionFilter(action)
	local title, kind, ft = action.title, action.kind, vim.bo.filetype

	-- in lua, ignore all quickfixes except line disables and all "move argument" actions
	local ignoreInLua = ft == "lua"
		and not (title:find("on this line"))
		and (kind == "quickfix" or kind == "refactor.rewrite")

	return not ignoreInLua
end

keymap(
	{ "n", "x" },
	"<leader>c",
	function() vim.lsp.buf.code_action { filter = codeActionFilter } end,
	{ desc = "󰒕 Code Action" }
)
keymap("n", "<leader>h", function()
	vim.lsp.buf.hover()
	vim.defer_fn(vim.lsp.buf.hover, 100) -- 2nd call = enter the hover window
end, { desc = "󰒕 Hover" })

--------------------------------------------------------------------------------

-- LOGGING
-- stylua: ignore start
keymap({ "n", "x" }, "<leader>lm", function() require("funcs.chainsaw").messageLog() end, { desc = "󰸢 message log" })
keymap({ "n", "x" }, "<leader>ll", function() require("funcs.chainsaw").variableLog() end, { desc = "󰸢 variable log" })
keymap({ "n", "x" }, "<leader>lo", function() require("funcs.chainsaw").objectLog() end, { desc = "󰸢 object log" })
keymap("n", "<leader>lb", function() require("funcs.chainsaw").beepLog() end, { desc = "󰸢 beep log" })
keymap("n", "<leader>l1", function() require("funcs.chainsaw").timeLog() end, { desc = "󰸢 time log" })
keymap("n", "<leader>lr", function() require("funcs.chainsaw").removeLogs() end, { desc = "󰸢  remove log" })
keymap("n", "<leader>ld", function() require("funcs.chainsaw").debugLog() end, { desc = "󰸢 debugger log" })
keymap("n", "<leader>la", function() require("funcs.chainsaw").assertLog() end, { desc = "󰸢 assert log" })
-- stylua: ignore end

keymap("n", "<leader>li", cmd.Inspect, { desc = " :Inspect" })
keymap("n", "<leader>lt", cmd.InspectTree, { desc = " :InspectTree" })

--------------------------------------------------------------------------------

-- Merging & Splitting Lines
keymap({ "n", "x" }, "<leader>m", "ddpkJ", { desc = "󰗈 Merge line down" })

-- Append to / delete from EoL
local trailChars = { ",", ";", ")", "'", '"', "|", "\\", "{", "." }
for _, key in pairs(trailChars) do
	keymap("n", "<leader>" .. key, "mzA" .. key .. "<Esc>`z", { desc = "which_key_ignore" })
end

-- PEEK WIN
keymap(
	"n",
	"<leader>w",
	function() require("funcs.quality-of-life").pinWin() end,
	{ desc = " Pin Window" }
)

-- MAKE
keymap("n", "<leader>r", "<cmd>lmake<CR>", { desc = " Make" })
keymap(
	"n",
	"<leader>R",
	function() require("funcs.quality-of-life").selectMake() end,
	{ desc = " Select Make" }
)

--------------------------------------------------------------------------------
-- OPTION TOGGLING

keymap("n", "<leader>on", "<cmd>set number!<CR>", { desc = " Line Numbers" })
keymap("n", "<leader>ow", "<cmd>set wrap!<CR>", { desc = "󰖶 Wrap" })
keymap("n", "<leader>ol", "<cmd>LspRestart<CR>", { desc = "󰒕 LspRestart" })
keymap("n", "<leader>oh", function() vim.lsp.inlay_hint(0, nil) end, { desc = "󰩔 Inlay Hints" })

keymap("n", "<leader>od", function() -- codespell-ignore
	local change = vim.diagnostic.is_disabled(0) and "enable" or "disable"
	vim.diagnostic[change](0)
end, { desc = " Diagnostics" })

keymap(
	"n",
	"<leader>oc",
	function() vim.opt_local.conceallevel = vim.opt_local.conceallevel:get() == 0 and 1 or 0 end,
	{ desc = "󰈉 Conceal" }
)

-- FIX
keymap("n", "<leader>of", function() vim.opt.scrolloff = 13 end, { desc = "⇓ Fix Scrolloff" })

--------------------------------------------------------------------------------
