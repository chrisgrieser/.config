local autocmd = vim.api.nvim_create_autocmd
local bo = vim.bo
local cmd = vim.cmd
local fn = vim.fn
local keymap = vim.keymap.set
local u = require("config.utils")

--------------------------------------------------------------------------------
-- META

keymap("n", "<D-;>", function()
	local thisFilePath = debug.getinfo(1).source:sub(2)
	vim.cmd.edit(thisFilePath)
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
keymap("n", "<leader>pt", cmd.TSUpdate, { desc = " Treesitter Parser Update" })

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
	local icon = require("nvim-web-devicons").get_icon(fn.bufname(), bo.filetype)
	icon = not icon and "" or icon .. " "
	local out = ("filetype: %s%s"):format(icon, bo.filetype)
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
keymap("x", "<leader>fs",	": s///g<Left><Left><Left>", { desc = "󱗘 :s (in selection)" })

keymap("n", "<leader>fd", ":g//d<Left><Left>", { desc = "󱗘 :delete matching lines" })
keymap("n", "<leader>fy", ":g//y<Left><Left>", { desc = "󱗘 :yank matching lines" })

keymap("n", "<leader>f<Tab>", function()
	bo.expandtab = false
	cmd.retab { bang = true }
	bo.tabstop = vim.opt_global.tabstop:get()
	vim.notify("Now using tabs ↹ ")
end, { desc = "↹ Use Tabs" })

keymap("n", "<leader>f<Space>", function()
	bo.expandtab = true
	cmd.retab { bang = true }
	vim.notify("Now using spaces 󱁐")
end, { desc = "󱁐 Use Spaces" })

--------------------------------------------------------------------------------

-- Undo
keymap(
	"n",
	"<leader>ur",
	function() cmd("silent later " .. tostring(vim.opt.undolevels:get())) end,
	{ desc = "󰛒 Redo All", silent = true }
)
keymap("n", "<leader>uh", "<cmd>Gitsigns reset_hunk<CR>", { desc = "󰕌 󰊢 Undo (Reset) Hunk" })
keymap("n", "<leader>ub", "<cmd>Gitsigns reset_buffer<CR>", { desc = "󰕌 󰊢 Undo (Reset) Buffer" })
keymap("n", "<leader>ut", function() cmd.Telescope("undo") end, { desc = "󰕌  Undo Telescope" })

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

--------------------------------------------------------------------------------

-- LOGGING & DEBUGGING
-- stylua: ignore start
keymap({ "n", "x" }, "<leader>ll", function() require("funcs.quick-log").log() end, { desc = " log variable" })
keymap({ "n", "x" }, "<leader>lo", function() require("funcs.quick-log").objectlog() end, { desc = " object log variable" })
keymap("n", "<leader>lb", function() require("funcs.quick-log").beeplog() end, { desc = " beep log" })
keymap("n", "<leader>l1", function() require("funcs.quick-log").timelog() end, { desc = " time log" })
keymap("n", "<leader>lr", function() require("funcs.quick-log").removelogs() end, { desc = "  remove log" })
keymap("n", "<leader>ld", function() require("funcs.quick-log").debuglog() end, { desc = " debugger" })
keymap("n", "<leader>lt", cmd.Inspect, { desc = " Treesitter Inspect" })
-- stylua: ignore end

--------------------------------------------------------------------------------
-- Splitting lines

keymap("x", "<leader>s", [[<Esc>`>a<CR><Esc>`<i<CR><Esc>]], { desc = "󰗈 split around selection" })
keymap("n", "<leader>S", "gww", { desc = "󰗈 Reflow Line (gww)" })

--------------------------------------------------------------------------------
-- GIT

-- Neogit
keymap("n", "<leader>gn", cmd.Neogit, { desc = "󰊢 Neogit Menu" })
keymap("n", "<leader>gc", "<cmd>Neogit commit<CR>", { desc = "󰊢 Commit (Neogit)" })

-- Gitsigns
keymap("n", "<leader>ga", "<cmd>Gitsigns stage_hunk<CR>", { desc = "󰊢 Add Hunk" })
keymap("n", "<leader>gA", "<cmd>Gitsigns stage_buffer<CR>", { desc = "󰊢 Add Buffer" })
keymap("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<CR>", { desc = "󰊢 Preview Hunk Diff" })
keymap("n", "<leader>gr", "<cmd>Gitsigns reset_hunk<CR>", { desc = "󰊢 Reset Hunk" })
keymap("n", "<leader>gR", "<cmd>Gitsigns reset_buffer<CR>", { desc = "󰊢 Reset Buffer" })
keymap("n", "<leader>g?", "<cmd>Gitsigns blame_line<CR>", { desc = "󰊢 Blame Line" })

-- Telescope
-- stylua: ignore start
keymap("n", "<leader>gs", function() cmd.Telescope("git_status") end, { desc = "󰊢  Status" })
keymap("n", "<leader>gl", function() cmd.Telescope("git_commits") end, { desc = "󰊢  Log / Commits" })
keymap("n", "<leader>gL", function() cmd.Telescope("git_bcommits") end, { desc = "󰊢  Buffer Commits" })
keymap("n", "<leader>gb", function() cmd.Telescope("git_branches") end, { desc = "󰊢  Branches Commits" })

-- My utils
keymap({ "n", "x" }, "<leader>gu", function () require("funcs.git-utils").githubUrl() end, { desc = "󰊢 GitHub Link" })
keymap("n", "<leader>gg", function() require("funcs.git-utils").addCommitPush() end, { desc = "󰊢 Add-Commit-Push" })
keymap("n", "<leader>gi", function() require("funcs.git-utils").issueSearch("open") end, { desc = "󰊢 Open Issues" })
keymap("n", "<leader>gI", function() require("funcs.git-utils").issueSearch("closed") end, { desc = "󰊢 Closed Issues" })
keymap("n", "<leader>gm", function() require("funcs.git-utils").amendNoEditPushForce() end, { desc = "󰊢 Amend-No-Edit & Force Push" })
keymap("n", "<leader>gM", function() require("funcs.git-utils").amendAndPushForce() end, { desc = "󰊢 Amend & Force Push" })
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

		-- directly search for the term
		if pickaxe ~= "" then fn.execute("/" .. pickaxe, "silent!") end
	end)
end, { desc = "󰊢 Pickaxe File History (Diffview)" })

--------------------------------------------------------------------------------
-- OPTION TOGGLING

-- stylua: ignore
keymap("n", "<leader>or", "<cmd>set relativenumber!<CR>", { desc = "  Toggle Relative Line Numbers" })
keymap("n", "<leader>on", "<cmd>set number!<CR>", { desc = "  Toggle Line Numbers" })

keymap("n", "<leader>od", function()
	if vim.diagnostic.is_disabled(0) then
		vim.diagnostic.enable(0)
	else
		vim.diagnostic.disable(0)
	end
end, { desc = "  Toggle Diagnostics" })

keymap("n", "<leader>ow", function()
	local wrapOn = vim.opt_local.wrap:get()
	if wrapOn then
		vim.opt_local.wrap = false
		vim.opt_local.colorcolumn = vim.opt.colorcolumn:get()
		vim.keymap.del("n", "A", { buffer = true })
		vim.keymap.del("n", "I", { buffer = true })
	else
		vim.opt_local.wrap = true
		vim.opt_local.colorcolumn = ""
		keymap("n", "A", "g$a", { buffer = true })
		keymap("n", "I", "g^i", { buffer = true })
	end
end, { desc = " 󰖶 Toggle Wrap" })

-- FIX scrolloff and folding sometimes broken
keymap("n", "<leader>of", function()
	vim.opt.scrolloff = 13
	vim.opt_local.foldlevel = 99
end, { desc = " 󰘖 Fix Folding/Scrolloff" })

--------------------------------------------------------------------------------
