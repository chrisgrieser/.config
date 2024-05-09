local autocmd = vim.api.nvim_create_autocmd
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

keymap(
	"n",
	"<leader>pd",
	function() vim.fn.system { "open", vim.fn.stdpath("data") } end,
	{ desc = " Package Dirs" }
)

--------------------------------------------------------------------------------
-- INSPECT

-- Copy Last Command
keymap("n", "<leader>lc", function()
	local lastCommand = vim.fn.getreg(":"):gsub("^lua[ =]*", "")
	vim.fn.setreg("+", lastCommand)
	u.notify("Copied", lastCommand)
end, { desc = "󰘳 Copy last command" })

keymap("n", "<leader>il", vim.cmd.LspInfo, { desc = "󰒕 :LspInfo" })

keymap("n", "<leader>it", function()
	-- setting command to always open in the right, regardless of `splitright`
	vim.treesitter.inspect_tree { command = "vertical botright new" }
end, { desc = " :InspectTree" })

--------------------------------------------------------------------------------
-- REFACTORING
local function left(num) return ("<Left>"):rep(num) end

keymap("n", "<leader>ff", vim.lsp.buf.rename, { desc = "󰒕 LSP Var Rename" })
keymap("n", "<leader>fs", ":%s /<C-r><C-w>//gI" .. left(3), { desc = " :s cword" })
keymap("x", "<leader>fs", '"zy:% s/<C-r>z//gI' .. left(3), { desc = " :s for selection" })
keymap("x", "<leader>fv", ":s ///gI" .. left(4), { desc = " :s inside visual" })
keymap("n", "<leader>fd", ":global // d _" .. left(5), { desc = " delete matching lines" })
keymap(
	"n",
	"<leader>fg",
	function() require("funcs.nano-plugins").globalSubstitute() end,
	{ desc = " global substitute" }
)

keymap("n", "<leader>fq", function()
	local line = vim.api.nvim_get_current_line()
	line = line:gsub("[\"']", function(quote) return (quote == [["]] and [[']] or [["]]) end)
	vim.api.nvim_set_current_line(line)
end, { desc = " Switch Quotes in current line." })

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
	function() vim.cmd("silent later " .. tostring(vim.opt.undolevels:get())) end,
	{ desc = "󰛒 Redo All" }
)

-- save open time for each buffer
autocmd("BufReadPost", {
	callback = function() vim.b["timeOpened"] = os.time() end,
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
local trailChars = { ",", ";", ")", "'", '"', "|", "\\", "{", ".", "}", "`" }
for _, key in pairs(trailChars) do
	keymap("n", "<leader>" .. key, ("mzA%s<Esc>`z"):format(key), { desc = "which_key_ignore" })
end

-- MAKE
keymap("n", "<leader>m", "<cmd>update | lmake<CR>", { desc = " Make" })
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

keymap(
	"n",
	"<leader>oc",
	function() vim.wo.conceallevel = vim.wo.conceallevel == 0 and 1 or 0 end,
	{ desc = "󰈉 Conceal" }
)

-- FIX for buggy scrolloff
keymap("n", "<leader>of", function() vim.opt.scrolloff = 13 end, { desc = "⇓ Fix Scrolloff" })

--------------------------------------------------------------------------------
