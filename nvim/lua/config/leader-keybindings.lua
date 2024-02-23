local autocmd = vim.api.nvim_create_autocmd
local bo = vim.bo
local cmd = vim.cmd

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

-- Run Last [a]gain
keymap("n", "<leader>a", ":<Up><CR>", { desc = "󰘳 Last cmd again", silent = true })

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
-- INSPECT

keymap("n", "<leader>ih", cmd.Inspect, { desc = " Highlights under Cursor" })
keymap("n", "<leader>il", cmd.LspInfo, { desc = "󰒕 :LspInfo" })

keymap("n", "<leader>it", function ()
	vim.treesitter.inspect_tree{ command = "60vnew" }
end, { desc = " :InspectTree" })

keymap("n", "<leader>ib", function()
	local out = {
		"filetype: " .. bo.filetype,
		"buftype: " .. bo.buftype,
		"cwd: " .. (vim.loop.cwd() or "n/a"),
		("indent: %s (%s)"):format(bo.expandtab and "spaces" or "tabs", bo.tabstop),
	}
	local ok, node = pcall(vim.treesitter.get_node)
	if ok and node then table.insert(out, "node: " .. node:type()) end
	u.notify("Buffer Information", table.concat(out, "\n"), "trace")
end, { desc = "󰽙 Buffer Info" })

--------------------------------------------------------------------------------
-- REFACTORING
keymap("n", "<leader>ff", vim.lsp.buf.rename, { desc = "󰒕 LSP Var Rename" })
local left3x = "<Left><Left><Left>"
keymap("n", "<leader>fs", ":%s /<C-r><C-w>//gI" .. left3x, { desc = " :s cword" })
keymap("x", "<leader>fs", '"zy:% s/<C-r>z//gI' .. left3x, { desc = " :s for selection" })
keymap("x", "<leader>fv", ":s ///gI<Left>" .. left3x, { desc = " :s inside visual" })
keymap("n", "<leader>fd", ":global // d" .. left3x, { desc = " delete matching lines" })
keymap(
	"n",
	"<leader>fg",
	function() require("funcs.nano-plugins").globalSubstitute() end,
	{ desc = " global substitute" }
)

keymap("n", "<leader>fy", function()
	-- cannot use `:g // y` because it yanks lines one after the other
	vim.ui.input({ prompt = "󰅍 yank lines matching:" }, function(input)
		local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		local matchLines = vim.tbl_filter(function(l) return l:find(input, 1, true) end, lines)
		vim.fn.setreg("+", table.concat(matchLines, "\n"))
		u.notify("Copied", tostring(#matchLines) .. " lines")
	end)
end, { desc = "󰅍 yank matching lines" })

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

---@param action {title: string, kind: string} https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#codeAction
---@return boolean
local function codeActionFilter(action)
	local title, _ = action.title, action.kind

	---@type table<string, boolean>
	local ignore = {
		-- stylua: ignore
		lua = (title:find("in this workspace") or title:find("defined global")
			or title:find("Change to parameter")) ~= nil,
		css = (
			title:find("^Disable .+ for entire file: ") or title:find("^Disable .+ rule inline: ")
		) ~= nil,
		markdown = title == "Create a Table of Contents",
		python = title == "Ruff: Fix All", -- done via formatting
	}
	local configuredToIgnore = ignore[vim.bo.ft] == true
	local noIgnoresForFiletype = ignore[vim.bo.ft] == nil
	return noIgnoresForFiletype or not configuredToIgnore
end

keymap(
	{ "n", "x" },
	"<leader>cc",
	function() vim.lsp.buf.code_action { filter = codeActionFilter } end,
	{ desc = "󰒕 Code Action" }
)

keymap("n", "<leader>h", vim.lsp.buf.hover, { desc = "󰒕 Hover" })

keymap("n", "<leader>ch", function()
	vim.diagnostic.open_float()
	vim.diagnostic.open_float() -- 2x = enter float
end, { desc = "󰒕 Diagnostic Hover" })

--------------------------------------------------------------------------------

-- Append to / delete from EoL
local trailChars = { ",", ";", ")", "'", '"', "|", "\\", "{", ".", "}", "`" }
for _, key in pairs(trailChars) do
	keymap("n", "<leader>" .. key, ("mzA%s<Esc>`z"):format(key), { desc = "which_key_ignore" })
end

-- MAKE
keymap("n", "<leader>m", "<cmd>silent update | lmake<CR>", { desc = " Make" })
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
keymap("n", "<leader>ol", function()
	u.notify("LSP", "Restarting…", "trace")
	vim.cmd.LspRestart()
end, { desc = "󰒕 LspRestart" })

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
	function() vim.wo.conceallevel = vim.wo.conceallevel == 0 and 1 or 0 end,
	{ desc = "󰈉 Conceal" }
)

-- FIX for buggy scrolloff
keymap(
	"n",
	"<leader>of",
	function() vim.opt.scrolloff = 13 end,
	{ desc = "⇓ Fix Scrolloff & Reload File" }
)

--------------------------------------------------------------------------------
