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

-- highlight groups
keymap("n", "<leader>pg", function() cmd.Telescope("highlights") end, { desc = " Highlight Groups" })

-- Plugins
keymap("n", "<leader>pp", require("lazy").sync, { desc = " Lazy Update" })
keymap("n", "<leader>ph", require("lazy").home, { desc = " Lazy Overview" })
keymap("n", "<leader>pi", require("lazy").install, { desc = " Lazy Install" })

keymap("n", "<leader>pm", cmd.Mason, { desc = " Mason Overview" })

-- Theme Picker
-- stylua: ignore
keymap("n", "<leader>pc", function() cmd.Telescope("colorscheme") end, { desc = "  Change Colorschemes" })

--------------------------------------------------------------------------------

-- copy Last Command
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

-- search command history
-- stylua: ignore
keymap("n", "<leader>lh", function() cmd.Telescope("command_history") end, { desc = "󰘳  Command History" })

-- show current filetype & buftype
keymap("n", "<leader>lf", function()
	local out = "filetype: " .. bo.filetype
	if bo.buftype ~= "" then out = out .. "\nbuftype: " .. bo.buftype end
	u.notify("", out, "trace")
end, { desc = "󰽘 Inspect FileType & BufType" })

--------------------------------------------------------------------------------
-- REFACTORING

keymap("n", "<leader>ff", ":% s/<C-r><C-w>//g<Left><Left><Left>", { desc = " :s (cursor word)" })
keymap("x", "<leader>ff", [["zy:%s /<C-r>z//g<Left><Left>]], { desc = " :s (selection)" })
keymap("x", "<leader>fv", ":s ///g<Left><Left><Left>", { desc = " :s (inside visual)" })

keymap("n", "<leader>fd", ":g //d<Left><Left>", { desc = " delete matching" })
keymap("n", "<leader>fy", ":g //y<Left><Left>", { desc = " yank matching" })

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
keymap("n", "<leader>uh", "<cmd>Gitsigns reset_hunk<CR>", { desc = "󰊢 Reset Hunk" })
keymap("n", "<leader>ub", "<cmd>Gitsigns reset_buffer<CR>", { desc = "󰊢 Reset Buffer" })

-- save open time for each buffer
autocmd("BufReadPost", {
	---@diagnostic disable-next-line: inject-field
	callback = function() vim.b.timeOpened = os.time() end,
})

keymap("n", "<leader>uo", function()
	local now = os.time() -- saved in epoch secs
	local secsPassed = now - vim.b.timeOpened
	cmd.earlier(tostring(secsPassed) .. "s")
end, { desc = "󰜊 Undo since last open", silent = true })

--------------------------------------------------------------------------------
-- LSP

---@param action object CodeAction Object https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#codeAction
---@return boolean
local function codeActionFilter(action)
	local title, kind, ft = action.title, action.kind, vim.bo.ft

	-- in lua, ignore all quickfixes except line disables and all rewrites
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

keymap(
	"n",
	"<leader>d",
	function() require("config.diagnostics").ruleSearch() end,
	{ desc = "󰒕 Lookup Diagnostic Rule" }
)

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
keymap("n", "<leader>li", cmd.Inspect, { desc = " :Inspect" })
keymap("n", "<leader>lt", cmd.InspectTree, { desc = " :InspectTree" })
-- stylua: ignore end

--------------------------------------------------------------------------------

-- Merging & Splitting Lines
keymap({ "n", "x" }, "<leader>m", "ddpkJ", { desc = "󰗈 Merge line down" })
keymap("x", "<leader>s", [[<Esc>`>a<CR><Esc>`<i<CR><Esc>=j]], { desc = "󰗈 Split around selection" })

-- Append to / delete from EoL
for _, key in pairs { ",", ";", ")", '"' } do
	keymap("n", "<leader>" .. key, "mzA" .. key .. "<Esc>`z", { desc = "which_key_ignore" })
end

--------------------------------------------------------------------------------

keymap(
	"n",
	"<leader>r",
	function() require("funcs.maker").make("runFirst") end,
	{ desc = " Make First" }
)
keymap("n", "<leader>R", function() require("funcs.maker").make() end, { desc = " Select Make" })

--------------------------------------------------------------------------------
-- GIT

-- Gitsigns
keymap("n", "<leader>ga", "<cmd>Gitsigns stage_hunk<CR>", { desc = "󰊢 Add Hunk" })
keymap("n", "<leader>gA", "<cmd>Gitsigns stage_buffer<CR>", { desc = "󰊢 Add Buffer" })
keymap("n", "<leader>gv", "<cmd>Gitsigns preview_hunk<CR>", { desc = "󰊢 Preview Hunk Diff" })
keymap("n", "<leader>g?", "<cmd>Gitsigns blame_line<CR>", { desc = "󰊢 Blame Line" })

-- Telescope
-- stylua: ignore start
keymap("n", "<leader>gs", function() cmd.Telescope("git_status") end, { desc = " Status" })
keymap("n", "<leader>gl", function() cmd.Telescope("git_commits") end, { desc = " Log" })
keymap("n", "<leader>gL", function() cmd.Telescope("git_bcommits") end, { desc = " Log (Buffer)" })
keymap("n", "<leader>gb", function() cmd.Telescope("git_branches") end, { desc = " Branches" })

-- My utils
keymap("n", "<leader>gc", function() require("funcs.small-git").commit() end, { desc = "󰊢 Commit" })
keymap("n", "<leader>gC", function() require("funcs.small-git").addCommit() end, { desc = "󰊢 Add-Commit" })
keymap("n", "<leader>gg", function() require("funcs.small-git").addCommitPush() end, { desc = "󰊢 Add-Commit-Push" })
keymap("n", "<leader>gm", function() require("funcs.small-git").amendNoEditPushForce() end, { desc = "󰊢 Amend-No-Edit & Force Push" })
keymap("n", "<leader>gM", function() require("funcs.small-git").amendAndPushForce() end, { desc = "󰊢 Amend & Force Push" })
keymap({ "n", "x" }, "<leader>gu", function () require("funcs.small-git").githubUrl() end, { desc = " GitHub Link" })
keymap("n", "<leader>gU", function () require("funcs.small-git").githubUrl("repo") end, { desc = " Goto Repo" })
keymap("n", "<leader>gi", function () require("funcs.small-git").issueSearch("open") end, { desc = " Open Issues" })
keymap("n", "<leader>gI", function () require("funcs.small-git").issueSearch("closed") end, { desc = " Closed Issues" })

-- Diffview
-- Line History of Selection
keymap(
	"x",
	"<leader>gd",
	":DiffviewFileHistory<CR><C-w>w<C-w>|", -- requires `:` for '<'> marks
	{ desc = "󰊢 Line History (Diffview)" }
)

-- Pickaxe Current file for a file
keymap("n", "<leader>gd", function()
	vim.ui.input({ prompt = "󰢷 Git Pickaxe (empty = full history)" }, function(pickaxe)
		if not pickaxe then return end

		local query = pickaxe ~= "" and (" -G'%s'"):format(pickaxe) or ""
		cmd("DiffviewFileHistory %" .. query)
		cmd.wincmd("w") -- go directly to file window
		cmd.wincmd("|") -- maximize it
		if pickaxe ~= "" then
			fn.execute("/" .. pickaxe, "silent!") -- directly search for the term
			vim.defer_fn(function() cmd("silent! normal! n") end, 200) -- goto first item
		end
	end)
end, { desc = "󰊢 Pickaxe File History" })

--------------------------------------------------------------------------------
-- OPTION TOGGLING

-- stylua: ignore
keymap("n", "<leader>or", "<cmd>set relativenumber!<CR>", { desc = " Relative Line Numbers" })
keymap("n", "<leader>on", "<cmd>set number!<CR>", { desc = " Line Numbers" })
keymap("n", "<leader>os", "<cmd>set spell!<CR>", { desc = "󰓆 spellcheck" })
keymap("n", "<leader>ol", "<cmd>LspRestart<CR>", { desc = "󰒕 LspRestart" })

keymap("n", "<leader>od", function() -- codespell-ignore
	if vim.diagnostic.is_disabled(0) then
		vim.diagnostic.enable(0)
	else
		vim.diagnostic.disable(0)
	end
end, { desc = " Diagnostics" })

keymap("n", "<leader>ow", function()
	local wrapOn = vim.opt_local.wrap:get()
	if wrapOn then
		vim.opt_local.wrap = false
		vim.opt_local.colorcolumn = vim.opt.colorcolumn:get()
		pcall(vim.keymap.del, "n", "A", { buffer = true })
		pcall(vim.keymap.del, "n", "I", { buffer = true })
	else
		vim.opt_local.wrap = true
		vim.opt_local.colorcolumn = ""
		keymap("n", "A", "g$a", { buffer = true })
		keymap("n", "I", "g^i", { buffer = true })
	end
end, { desc = "󰖶 Wrap" })

-- FIX scrolloff
keymap("n", "<leader>of", function() vim.opt.scrolloff = 13 end, { desc = "󰘖 Fix Scrolloff" })

-- make <C-a>/<C-x> work on letters. Useful for macros
keymap("n", "<leader>oa", function()
	local nrformats = vim.opt.nrformats
	local hasAlpha = vim.tbl_contains(nrformats:get(), "alpha")
	if hasAlpha then
		nrformats:remove { "alpha" }
		u.notify("Option", "󰀫 alpha disabled")
	else
		nrformats:append("alpha")
		u.notify("Option", "󰀫 alpha enabled")
	end
end, { desc = "󰀫 Toggle nrformats alpha" })

--------------------------------------------------------------------------------
