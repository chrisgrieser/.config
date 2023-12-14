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

-- inspect
keymap("n", "<leader>li", cmd.Inspect, { desc = " :Inspect" })
keymap("n", "<leader>lt", cmd.InspectTree, { desc = " :InspectTree" })

-- Copy Last Command
keymap("n", "<leader>lc", function()
	local lastCommand = fn.getreg(":"):gsub("^lua[ =]*", "")
	fn.setreg("+", lastCommand)
	u.notify("Copied", lastCommand)
end, { desc = "󰘳 Copy last command" })

-- [l]ast command a[g]ain
keymap("n", "<leader>lg", ":<Up><CR>", { desc = "󰘳 Last command again", silent = true })

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
keymap(
	"n",
	"<leader>f<CR>",
	function() vim.opt_local.fileformat = "unix" end,
	{ desc = "󰌑 Use Unix File Endings" }
)

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
	local title, _ = action.title, action.kind

	---@type table<string, boolean>
	local filter = {
		-- stylua: ignore
		lua = not (title:find("in this file") or title:find("in the workspace")
			or title:find("defined global") or title:find("Change to parameter")),
		javascript = not (title == "Move to a new file"),
		typescript = not (title == "Move to a new file"),
		-- stylua: ignore
		css = not (title:find("^Disable .+ for entire file: ")
			or title:find( "^Disable .+ rule inline: ")),
		markdown = title ~= "Create a Table of Contents",
	}
	local noFilterForFiletype = filter[vim.bo.filetype] == nil
	return noFilterForFiletype or filter[vim.bo.filetype]
end

keymap(
	{ "n", "x" },
	"<leader>c",
	function() vim.lsp.buf.code_action { filter = codeActionFilter } end,
	{ desc = "󰒕 Code Action" }
)
keymap("n", "<leader>h", vim.lsp.buf.hover, { desc = "󰒕 Hover" })
keymap(
	"n",
	"<leader>v",
	function() require("funcs.lsp-rename-patch").lsp_rename() end,
	{ desc = "󰒕 LSP Rename" }
)

--------------------------------------------------------------------------------
-- LOGGING

-- stylua: ignore start
keymap({ "n", "x" }, "<leader>ll", function() require("funcs.printing-press").variableLog() end, { desc = " variable log" })
keymap({ "n", "x" }, "<leader>lo", function() require("funcs.printing-press").objectLog() end, { desc = " object log" })
keymap("n", "<leader>lb", function() require("funcs.printing-press").beepLog() end, { desc = " beep log" })
keymap("n", "<leader>lm", function() require("funcs.printing-press").messageLog() end, { desc = " message log" })
keymap("n", "<leader>l1", function() require("funcs.printing-press").timeLog() end, { desc = " time log" })
keymap("n", "<leader>lr", function() require("funcs.printing-press").removeLogs() end, { desc = "󰹝 remove log" })
keymap("n", "<leader>ld", function() require("funcs.printing-press").debugLog() end, { desc = " debugger log" })
keymap("n", "<leader>la", function() require("funcs.printing-press").assertLog() end, { desc = " assert log" })
-- stylua: ignore end

--------------------------------------------------------------------------------

-- Append to / delete from EoL
local trailChars = { ",", ";", ")", "'", '"', "|", "\\", "{", ".", "}" }
for _, key in pairs(trailChars) do
	keymap("n", "<leader>" .. key, ("mzA%s<Esc>`z"):format(key), { desc = "which_key_ignore" })
end

-- MAKE
keymap("n", "<leader>r", function()
	vim.cmd("silent! update")
	vim.cmd.lmake()
end, { desc = " Make" })
keymap(
	"n",
	"<leader>R",
	function() require("funcs.quality-of-life").selectMake() end,
	{ desc = " Select Make" }
)

-- TERMINAL
keymap(
	{ "n", "x" },
	"<leader>t",
	function() require("funcs.quality-of-life").sendToWezTerm() end,
	{ desc = " Send to WezTerm" }
)

--------------------------------------------------------------------------------
-- OPTION TOGGLING

keymap("n", "<leader>on", "<cmd>set number!<CR>", { desc = " Line Numbers" })
keymap("n", "<leader>ow", "<cmd>set wrap!<CR>", { desc = "󰖶 Wrap" })
keymap("n", "<leader>ol", vim.cmd.LspRestart, { desc = "󰒕 LspRestart" })

keymap("n", "<leader>od", function()
	local change = vim.diagnostic.is_disabled(0) and "enable" or "disable"
	vim.diagnostic[change](0)
end, { desc = " Diagnostics" })
keymap("n", "<leader>oh", function()
	local enabled = vim.lsp.inlay_hint.is_enabled(0)
	vim.lsp.inlay_hint.enabled(0, not enabled)
end, { desc = "󰒕 LSP Inlay Hints" })

keymap(
	"n",
	"<leader>oc",
	function() vim.opt_local.conceallevel = vim.opt_local.conceallevel:get() == 0 and 1 or 0 end,
	{ desc = "󰈉 Conceal" }
)

-- FIX
keymap("n", "<leader>of", function() vim.opt.scrolloff = 13 end, { desc = "⇓ Fix Scrolloff" })

--------------------------------------------------------------------------------
