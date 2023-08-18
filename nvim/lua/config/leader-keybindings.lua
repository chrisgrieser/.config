local autocmd = vim.api.nvim_create_autocmd
local bo = vim.bo
local cmd = vim.cmd
local fn = vim.fn
local keymap = vim.keymap.set
local u = require("config.utils")

--------------------------------------------------------------------------------
-- META

keymap("n", "<D-;>", function()
	local pathOfThisFile = debug.getinfo(1).source:sub(2)
	vim.cmd.edit(pathOfThisFile)
end, { desc = "⌨️ Edit leader-keybindings.lua" })

--------------------------------------------------------------------------------

-- Highlights
keymap("n", "<leader>pg", function() cmd.Telescope("highlights") end, { desc = " Highlight Groups" })

-- [P]lugins
keymap("n", "<leader>pp", require("lazy").sync, { desc = " Lazy Update/Sync" })
keymap("n", "<leader>ph", require("lazy").home, { desc = " Lazy Overview" })
keymap("n", "<leader>pi", require("lazy").install, { desc = " Lazy Install" })

keymap("n", "<leader>pm", cmd.Mason, { desc = " Mason Overview" })
-- stylua: ignore
keymap("n", "<leader>pt", cmd.TSUpdate, { desc = " Treesitter Update" })

-- Theme Picker
-- stylua: ignore
keymap("n", "<leader>pc", function() cmd.Telescope("colorscheme") end, { desc = "  Change Colorschemes" })

--------------------------------------------------------------------------------

-- copy [l]ast ex[c]ommand
keymap("n", "<leader>lc", function()
	local lastCommand = fn.getreg(":"):gsub("^I ", "")
	if #lastCommand == 0 then
		vim.notify("No last command available", u.warn)
		return
	end
	fn.setreg("+", lastCommand)
	vim.notify("COPIED\n" .. lastCommand)
end, { desc = "󰘳 Copy last command" })

-- [l]ast command [a]gain
-- as opposed to `@:`, this works across sessions
keymap("n", "<leader>la", ":<Up><CR>", { desc = "󰘳 Run last command again", silent = true })

-- search command history
-- stylua: ignore
keymap("n", "<leader>lh", function() cmd.Telescope("command_history") end, { desc = "󰘳  Command History" })

-- show current filetype & buftype
keymap("n", "<leader>lf", function()
	local out = "filetype" .. bo.filetype
	if bo.buftype ~= "" then out = out .. "\nbuftype: " .. bo.buftype end
	vim.notify(out, u.trace)
end, { desc = "󰽘 Inspect FileType & BufType" })

--------------------------------------------------------------------------------
-- REFACTORING

keymap(
	"n",
	"<leader>ff",
	":% s/<C-r><C-w>//g<Left><Left><Left>",
	{ desc = "󱗘 :s (word under cursor)" }
)
keymap("x", "<leader>ff", [["zy:% s/<C-r>z//g<Left><Left>]], { desc = "󱗘 :s (selected text)" })
keymap("x", "<leader>fs", ": s///g<Left><Left><Left>", { desc = "󱗘 :s (in selection)" })

keymap("n", "<leader>fd", ":g//d<Left><Left>", { desc = "󱗘 :delete matching lines" })
keymap("n", "<leader>fy", ":g//y<Left><Left>", { desc = "󱗘 :yank matching lines" })

keymap("n", "<leader>f<Tab>", function()
	bo.expandtab = false
	bo.tabstop = 3
	cmd.retab { bang = true }
	vim.notify("Now using 󰌒 (width 3)")
end, { desc = "󰌒 Use Tabs" })

keymap("n", "<leader>f<Space>", function()
	bo.tabstop = 2
	bo.expandtab = true
	cmd.retab { bang = true }
	vim.notify("Now using 󱁐 (2)")
end, { desc = "󱁐 Use Spaces" })

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
	{ desc = "󰽙 undo closing buffer" }
)
keymap("n", "<leader>uh", "<cmd>Gitsigns reset_hunk<CR>", { desc = "󰕌 󰊢 Undo (Reset) Hunk" })
keymap("n", "<leader>ub", "<cmd>Gitsigns reset_buffer<CR>", { desc = "󰕌 󰊢 Undo (Reset) Buffer" })
keymap(
	"n",
	"<leader>ut",
	function() cmd.Telescope("undo") end,
	{ desc = "󰕌  Undo Telescope", silent = true }
)

-- save open time for each buffer
autocmd("BufReadPost", {
	callback = function() vim.b.timeOpened = os.time() end,
})

keymap("n", "<leader>uo", function()
	local now = os.time() -- saved in epoch secs
	local secsPassed = now - vim.b.timeOpened
	cmd.earlier(tostring(secsPassed) .. "s")
end, { desc = "󰜊 Undo since last open", silent = true })

--------------------------------------------------------------------------------
-- LSP
keymap("n", "<leader>h", vim.lsp.buf.hover, { desc = "󰒕 Hover" })
keymap({ "n", "x" }, "<leader>c", vim.lsp.buf.code_action, { desc = "󰒕 Code Action" })

--------------------------------------------------------------------------------

-- LOGGING
-- stylua: ignore start
keymap({ "n", "x" }, "<leader>ll", function() require("funcs.lumberjack").messageLog() end, { desc = "󰣈 message log" })
keymap({ "n", "x" }, "<leader>ll", function() require("funcs.lumberjack").variableLog() end, { desc = "󰣈 variable log" })
keymap({ "n", "x" }, "<leader>lo", function() require("funcs.lumberjack").objectLog() end, { desc = "󰣈 object log" })
keymap("n", "<leader>lb", function() require("funcs.lumberjack").beepLog() end, { desc = "󰣈 beep log" })
keymap("n", "<leader>l1", function() require("funcs.lumberjack").timeLog() end, { desc = "󰣈 time log" })
keymap("n", "<leader>lr", function() require("funcs.lumberjack").removeLogs() end, { desc = "󰣈  remove log" })
keymap("n", "<leader>ld", function() require("funcs.lumberjack").debugLog() end, { desc = "󰣈 debugger log" })
keymap("n", "<leader>lt", cmd.Inspect, { desc = " Treesitter Inspect" })
-- stylua: ignore end

--------------------------------------------------------------------------------

-- Merging & Splitting Lines
keymap({ "n", "x" }, "<leader>m", "ddpkJ", { desc = "󰗈 Merge line down" })
keymap("x", "<leader>s", [[<Esc>`>a<CR><Esc>`<i<CR><Esc>]], { desc = "󰗈 split around selection" })

-- Append to / delete from EoL
keymap("n", "<leader>,", "mzA,<Esc>`z", { desc = " , to EoL" })
keymap("n", '<leader>"', 'mzA"<Esc>`z', { desc = ' " to EoL' })
keymap("n", "<leader>)", "mzA)<Esc>`z", { desc = " ) to EoL" })

--------------------------------------------------------------------------------
-- GIT

-- Gitsigns
keymap("n", "<leader>ga", "<cmd>Gitsigns stage_hunk<CR>", { desc = "󰊢 Add Hunk" })
keymap("n", "<leader>gv", "<cmd>Gitsigns preview_hunk<CR>", { desc = "󰊢 Preview Hunk Diff" })
keymap("n", "<leader>gr", "<cmd>Gitsigns reset_hunk<CR>", { desc = "󰊢 Reset Hunk" })
keymap("n", "<leader>g?", "<cmd>Gitsigns blame_line<CR>", { desc = "󰊢 Blame Line" })

-- Telescope
-- stylua: ignore start
keymap("n", "<leader>gs", function() cmd.Telescope("git_status") end, { desc = " Status" })
keymap("n", "<leader>gl", function() cmd.Telescope("git_commits") end, { desc = " Log" })
keymap("n", "<leader>gL", function() cmd.Telescope("git_bcommits") end, { desc = " Log (Buffer)" })
keymap("n", "<leader>gb", function() cmd.Telescope("git_branches") end, { desc = " Branches" })

-- My utils
keymap("n", "<leader>gc", function() require("funcs.git-utils").commit() end, { desc = "󰊢 Commit" })
keymap("n", "<leader>gg", function() require("funcs.git-utils").addCommitPush() end, { desc = "󰊢 Add-Commit-Push" })
keymap("n", "<leader>gm", function() require("funcs.git-utils").amendNoEditPushForce() end, { desc = "󰊢 Amend-No-Edit & Force Push" })
keymap("n", "<leader>gM", function() require("funcs.git-utils").amendAndPushForce() end, { desc = "󰊢 Amend & Force Push" })
keymap({ "n", "x" }, "<leader>gu", function () require("funcs.git-utils").githubUrl() end, { desc = " GitHub Link" })

-- Octo
keymap("n", "<leader>gi", function() cmd.Octo({"issue", "list"}) end, { desc = " Open Issues" })
keymap("n", "<leader>gI", function() cmd.Octo({"issue", "list", "states=CLOSED"}) end, { desc = " Closed Issues" })
keymap("n", "<leader>gp", function() cmd.Octo({"pr", "list"}) end, { desc = " Open PRs" })
-- stylua: ignore end

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
			cmd("silent! normal! n") -- search for first item
		end
	end)
end, { desc = "󰊢 Pickaxe File History" })

--------------------------------------------------------------------------------
-- OPTION TOGGLING

-- stylua: ignore
keymap("n", "<leader>or", "<cmd>set relativenumber!<CR>", { desc = "  Relative Line Numbers" })
keymap("n", "<leader>on", "<cmd>set number!<CR>", { desc = "  Line Numbers" })

keymap("n", "<leader>ol", "<cmd>LspRestart<CR>", { desc = " 󰒕 LspRestart" })

keymap("n", "<leader>od", function()
	if vim.diagnostic.is_disabled(0) then
		vim.diagnostic.enable(0)
	else
		vim.diagnostic.disable(0)
	end
end, { desc = "  Diagnostics" })

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
end, { desc = " 󰖶 Wrap" })

-- FIX scrolloff and folding sometimes broken
keymap("n", "<leader>of", function()
	vim.opt.scrolloff = 13
	vim.opt_local.foldlevel = 99
end, { desc = " 󰘖 Fix Folding/Scrolloff" })

-- make <C-a>/<C-x> work on letters. Useful for macros
keymap("n", "<leader>oa", function()
	local nrformats = vim.opt.nrformats
	local hasAlpha = vim.tbl_contains(nrformats:get(), "alpha")
	if hasAlpha then
		nrformats:remove { "alpha" }
		vim.notify(" 󰀫 alpha disabled")
	else
		nrformats:append("alpha")
		vim.notify(" 󰀫 alpha enabled")
	end
end, { desc = " 󰀫 Toggle nrformats alpha" })

--------------------------------------------------------------------------------
