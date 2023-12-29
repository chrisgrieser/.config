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

-- Copy Last Command
keymap("n", "<leader>lc", function()
	local lastCommand = fn.getreg(":"):gsub("^lua[ =]*", "")
	fn.setreg("+", lastCommand)
	u.notify("Copied", lastCommand)
end, { desc = "󰘳 Copy last command" })

-- [l]ast command a[g]ain
keymap("n", "<leader>lg", ":<Up><CR>", { desc = "󰘳 Last command again", silent = true })

-- inspect
keymap("n", "<leader>li", cmd.Inspect, { desc = " :Inspect" })
keymap("n", "<leader>lf", function()
	local out = {
		"filetype: " .. bo.filetype,
		"buftype: " .. bo.buftype,
		"cwd: " .. (vim.loop.cwd() or "n/a"),
		("indent: %s (%s)"):format(bo.expandtab and "spaces" or "tabs", bo.tabstop),
	}
	local ok, node = pcall(vim.treesitter.get_node)
	if ok and node then table.insert(out, "node: " .. node:type()) end
	u.notify("Buffer Information", table.concat(out, "\n"), "trace")
end, { desc = " Buffer Info" })

-- view internal directories
keymap(
	"n",
	"<leader>pv",
	function() vim.fn.system { "open", vim.o.viewdir } end,
	{ desc = " View Dir" }
)
keymap(
	"n",
	"<leader>pd",
	function() vim.fn.system { "open", vim.fn.stdpath("data") } end,
	{ desc = " Package Dirs" }
)

--------------------------------------------------------------------------------
-- REFACTORING
local left3x = "<Left><Left><Left>"
keymap("n", "<leader>ff", vim.lsp.buf.rename, { desc = "󰒕 Var Rename" })
keymap("n", "<leader>fs", ":%s /<C-r><C-w>//gI" .. left3x, { desc = " :s cword" })
keymap("x", "<leader>fs", '"zy:% s/<C-r>z//gI' .. left3x, { desc = " :s for selection" })
keymap("x", "<leader>fv", ":s ///gI<Left>" .. left3x, { desc = " :s inside visual" })
keymap("n", "<leader>fd", ":g // d" .. left3x, { desc = " delete matching" })
keymap(
	"n",
	"<leader>fq",
	function() require("funcs.nano-plugins").cdoSubstitute() end,
	{ desc = " :s quickfix" }
)

---@param use "spaces"|"tabs"
local function retabber(use)
	bo.expandtab = use == "spaces"
	bo.shiftwidth = 2
	bo.tabstop = 3
	cmd.retab { bang = true }
	u.notify("Indent", "Now using " .. use)
end
keymap("n", "<leader>f<Tab>", function() retabber("tabs") end, { desc = "󰌒 Use Tabs" })
keymap("n", "<leader>f<Space>", function() retabber("spaces") end, { desc = "󱁐 Use Spaces" })

--------------------------------------------------------------------------------
-- UNDO

keymap(
	"n",
	"<leader>ur",
	function() cmd("silent later " .. tostring(vim.opt.undolevels:get())) end,
	{ desc = "󰛒 Redo All" }
)

-- save open time for each buffer
autocmd("BufReadPost", {
	callback = function() vim.b["timeOpened"] = os.time() end,
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
	local ignore = {
		-- stylua: ignore
		lua = (title:find("in this file") or title:find("in the workspace")
			or title:find("defined global") or title:find("Change to parameter")) ~= nil,
		javascript = (title == "Move to a new file"),
		typescript = (title == "Move to a new file"),
		-- stylua: ignore
		css = (title:find("^Disable .+ for entire file: ")
			or title:find( "^Disable .+ rule inline: ")) ~= nil,
		markdown = title == "Create a Table of Contents",
	}
	return ignore[vim.bo.ft] == false -- not `nil`, so unset filetypes all pass
end

keymap(
	{ "n", "x" },
	"<leader>dd",
	function() vim.lsp.buf.code_action { filter = codeActionFilter } end,
	{ desc = "󰒕 Code Action" }
)
keymap("n", "<leader>dh", function()
	vim.diagnostic.open_float()
	vim.diagnostic.open_float() -- 2x = enter float
end, { desc = "󰒕 Diagnostic Hover" })

keymap("n", "<leader>h", vim.lsp.buf.hover, { desc = "󰒕 Hover" })

--------------------------------------------------------------------------------
-- LOGGING

-- stylua: ignore start
keymap({ "n", "x" }, "<leader>ll", function() require("funcs.chainsaw").variableLog() end, { desc = "󰸢 variable log" })
keymap({ "n", "x" }, "<leader>lo", function() require("funcs.chainsaw").objectLog() end, { desc = "󰸢 object log" })
keymap({ "n", "x" }, "<leader>la", function() require("funcs.chainsaw").assertLog() end, { desc = "󰸢 assert log" })
keymap("n", "<leader>lb", function() require("funcs.chainsaw").beepLog() end, { desc = "󰸢 beep log" })
keymap("n", "<leader>lm", function() require("funcs.chainsaw").messageLog() end, { desc = "󰸢 message log" })
keymap("n", "<leader>l1", function() require("funcs.chainsaw").timeLog() end, { desc = "󰸢 time log" })
keymap("n", "<leader>ld", function() require("funcs.chainsaw").debugLog() end, { desc = "󰸢 debugger log" })
keymap("n", "<leader>lr", function() require("funcs.chainsaw").removeLogs() end, { desc = "󰹝 remove logs" })
-- stylua: ignore end

--------------------------------------------------------------------------------

-- Append to / delete from EoL
local trailChars = { ",", ";", ")", "'", '"', "|", "\\", "{", ".", "}", "`" }
for _, key in pairs(trailChars) do
	keymap("n", "<leader>" .. key, ("mzA%s<Esc>`z"):format(key), { desc = "which_key_ignore" })
end

-- MAKE
keymap("n", "<leader>m", function()
	vim.cmd("silent! update")
	vim.cmd.lmake()
end, { desc = " Make" })
keymap(
	"n",
	"<leader>M",
	function() require("funcs.nano-plugins").selectMake() end,
	{ desc = " Select Make" }
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
