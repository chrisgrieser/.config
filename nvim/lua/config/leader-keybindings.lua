local autocmd = vim.api.nvim_create_autocmd
local u = require("config.utils")
local keymap = require("config.utils").uniqueKeymap

--------------------------------------------------------------------------------
-- META

local pathOfThisFile = debug.getinfo(1).source:sub(2)
local desc = "⌨️ Edit " .. vim.fs.basename(pathOfThisFile)
keymap("n", "<D-;>", function() vim.cmd.edit(pathOfThisFile) end, { desc = desc })

keymap("n", "<leader>pd", function()
	local pluginPath = vim.fn.stdpath("data") ---@cast pluginPath string
	vim.ui.open(pluginPath)
end, { desc = " Open Package Directory" })

--------------------------------------------------------------------------------
-- INSPECT

-- Copy Last Command
keymap("n", "<leader>lc", function()
	local lastCommand = vim.fn.getreg(":"):gsub("^lua[ =]*", "")
	u.copyAndNotify(lastCommand)
end, { desc = "󰘳 Copy last command" })

keymap("n", "<leader>ih", vim.cmd.Inspect, { desc = " Highlights under cursor" })
keymap("n", "<leader>il", vim.cmd.LspInfo, { desc = "󰒕 :LspInfo" })

keymap("n", "<leader>ib", function()
	local out = {
		"filetype: " .. vim.bo.filetype,
		"buftype: " .. (vim.bo.buftype == "" and '""' or vim.bo.buftype),
		"cwd: " .. (vim.uv.cwd() or "n/a"):gsub("/Users/%w+", "~"),
		("indent: %s (%s)"):format(vim.bo.expandtab and "spaces" or "tabs", vim.bo.tabstop),
	}
	local ok, node = pcall(vim.treesitter.get_node)
	if ok and node then table.insert(out, "node: " .. node:type()) end
	u.notify("Buffer Information", table.concat(out, "\n"), "trace")
end, { desc = "󰽙 Buffer Info" })

--------------------------------------------------------------------------------
-- REFACTORING

keymap("n", "<leader>ff", vim.lsp.buf.rename, { desc = "󰒕 LSP Var Rename" })
keymap("n", "<leader>fd", ":global //d<Left><Left>", { desc = " delete matching lines" })

keymap("n", "<leader>fy", function()
	-- cannot use `:g // y` because it yanks lines one after the other
	vim.ui.input({ prompt = "󰅍 yank lines matching:" }, function(input)
		if not input then return end
		local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		local matchLines = vim.tbl_filter(function(l) return l:find(input, 1, true) end, lines)
		vim.fn.setreg("+", table.concat(matchLines, "\n"))
		u.notify("Copied", tostring(#matchLines) .. " lines")
	end)
end, { desc = "󰅍 yank matching lines" })

---@param use "spaces"|"tabs"
local function retabber(use)
	vim.bo.expandtab = use == "spaces"
	vim.bo.shiftwidth = 2
	vim.bo.tabstop = 3
	vim.cmd.retab { bang = true }
	u.notify("Indent", "Now using " .. use)
end
keymap("n", "<leader>f<Tab>", function() retabber("tabs") end, { desc = "󰌒 Use Tabs" })
keymap("n", "<leader>f<Space>", function() retabber("spaces") end, { desc = "󱁐 Use Spaces" })

--------------------------------------------------------------------------------
-- UNDO

keymap(
	"n",
	"<leader>ur",
	function() vim.cmd.later(vim.opt.undolevels:get()) end,
	{ desc = "󰛒 Redo All" }
)

keymap("n", "<leader>u1", function() vim.cmd.earlier("1h") end, { desc = "󰜊 Undo 1h" })
keymap("n", "<leader>u8", function() vim.cmd.earlier("8h") end, { desc = "󰜊 Undo 8h" })

-- save open time for each buffer
autocmd("BufReadPost", {
	callback = function() vim.b.timeOpened = os.time() end,
})

keymap("n", "<leader>uo", function()
	local now = os.time()
	local secsPassed = now - vim.b.timeOpened
	vim.cmd.earlier(tostring(secsPassed) .. "s")
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
		lua = (title:find("in the workspace") or title:find("on this line")
			or title:find("defined global") or title:find("Change to parameter")) ~= nil,
		markdown = title == "Create a Table of Contents",
		python = title == "Ruff: Fix All", -- done via formatting
		javascript = title == "Move to a new file", -- annoyance since always moved to top
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
local trailChars = { ",", ";", ")", "'", '"', "|", "\\", "{", ".", "}", "`", ":" }
for _, key in pairs(trailChars) do
	keymap("n", "<leader>" .. key, ("mzA%s<Esc>`z"):format(key), { desc = "which_key_ignore" })
end

-- JUST
keymap(
	"n",
	"<leader>j",
	function() require("funcs.nano-plugins").justRecipe("first") end,
	{ desc = " 1st Just recipe" }
)
keymap(
	"n",
	"<leader>J",
	function() require("funcs.nano-plugins").justRecipe() end,
	{ desc = " Just recipes" }
)

--------------------------------------------------------------------------------
-- OPTION TOGGLING

keymap("n", "<leader>on", "<cmd>set number!<CR>", { desc = " Line Numbers" })
keymap("n", "<leader>ow", "<cmd>set wrap!<CR>", { desc = "󰖶 Wrap" })

keymap("n", "<leader>ol", function()
	u.notify("LSP", "Restarting…", "trace")
	vim.cmd.LspRestart()
end, { desc = "󰒕 :LspRestart" })

keymap("n", "<leader>oh", function()
	local isEnabled = vim.lsp.inlay_hint.is_enabled { bufnr = 0 }
	vim.lsp.inlay_hint.enable(not isEnabled, { bufnr = 0 })
end, { desc = "󰒕 Inlay Hints" })

keymap("n", "<leader>od", function()
	local isEnabled = vim.diagnostic.is_enabled { bufnr = 0 }
	vim.diagnostic.enable(not isEnabled, { bufnr = 0 })
end, { desc = " Diagnostics" })

keymap(
	"n",
	"<leader>oc",
	function() vim.wo.conceallevel = vim.wo.conceallevel == 0 and 2 or 0 end,
	{ desc = "󰈉 Conceal" }
)

--------------------------------------------------------------------------------
