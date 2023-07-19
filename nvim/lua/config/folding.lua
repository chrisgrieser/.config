local cmd = vim.cmd
local fn = vim.fn
local keymap = vim.keymap.set
local u = require("config.utils")
local bo = vim.bo

--------------------------------------------------------------------------------

-- REMEMBER FOLDS AND CURSOR
local function remember(mode)
	-- stylua: ignore
	local ignoredFts = { "TelescopePrompt", "DressingSelect", "DressingInput", "toggleterm", "gitcommit", "replacer", "harpoon", "help", "qf" }
	if vim.tbl_contains(ignoredFts, bo.filetype) or bo.buftype ~= "" or not bo.modifiable then return end

	if mode == "save" then
		cmd.mkview(1)
	else
		pcall(function() cmd.loadview(1) end) -- pcall, since new files have no view yet
	end
end
vim.api.nvim_create_autocmd("BufWinLeave", {
	pattern = "?*", -- pattern required, otherwise does not trigger
	callback = function() remember("save") end,
})
vim.api.nvim_create_autocmd("BufWinEnter", {
	pattern = "?*",
	callback = function() remember("load") end,
})

--------------------------------------------------------------------------------
-- PAUSE FOLDS WHILE SEARCHING
-- Disabling search in foldopen has the disadvantage of making search nearly
-- unusable. Enabling search in foldopen has the disadvantage of constantly
-- opening all your folds as soon as you search. This snippet fixes this by
-- pausing folds while searching, but restoring them when you are done
-- searching.

vim.opt.foldopen:remove { "search" } -- no auto-open when searching, since the following snippet does that better
keymap("n", "-", "zn/", { desc = "Search & Pause Folds" })

vim.on_key(function(char)
	if vim.g.scrollview_refreshing then return end -- FIX: https://github.com/dstein64/nvim-scrollview/issues/88#issuecomment-1570400161
	local key = fn.keytrans(char)
	local searchKeys = { "n", "N", "*", "#", "/", "?" }
	local searchConfirmed = (key == "<CR>" and fn.getcmdtype():find("[/?]") ~= nil)
	if not (searchConfirmed or fn.mode() == "n") then return end
	local searchKeyUsed = searchConfirmed or (vim.tbl_contains(searchKeys, key))

	local pauseFold = vim.opt.foldenable:get() and searchKeyUsed
	local unpauseFold = not (vim.opt.foldenable:get()) and not searchKeyUsed
	if pauseFold then
		vim.opt.foldenable = false
	elseif unpauseFold then
		vim.opt.foldenable = true
		u.normal("zv") -- after closing folds, keep the *current* fold open
	end
end, vim.api.nvim_create_namespace("auto_pause_folds"))

--------------------------------------------------------------------------------
-- MACRO FOLD COMMANDS
-- affect all folds in the buffer

-- toggle all toplevel folds
keymap("n", "zz", function()
	cmd("%foldclose") -- close toplevel folds
	-- pcall(u.normal, "zo") -- open fold under cursor
end, { desc = "󰘖 Close toplevel folds" })

-- UFO REPLACEMENTS OF FOLD COMMANDS
-- INFO fold commands usually change the foldlevel, which fixes folds, e.g.
-- auto-closing them after leaving insert mode, however ufo does not seem to
-- have equivalents for zr and zm because there is no saved fold level.
-- Consequently, the vim-internal fold levels need to be disabled by setting
-- them to 99
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99

-- stylua: ignore
keymap("n", "zr", function() require("ufo").openFoldsExceptKinds { "comments" } end, { desc = "󰘖 󱃄 Open All Folds except comments" })
keymap("n", "zm", function() require("ufo").closeAllFolds() end, { desc = "󰘖 󱃄 Close All Folds" })

-- set foldlevel via z{n}
for _, lvl in pairs { 1, 2, 3, 4, 5, 6, 7, 8, 9 } do
	local desc = lvl < 4 and "󰘖 Set Fold Level" or "which_key_ignore"
	keymap(
		"n",
		"z" .. tostring(lvl),
		function() require("ufo").closeFoldsWith(lvl - 1) end,
		{ desc = desc }
	)
end

--------------------------------------------------------------------------------
-- MESO-LEVEL FOLD COMMANDS
-- affect multiple folds, but not all

-- Cycle Folds (f1 = ^ Karabiner Remap)
keymap({ "c", "i" }, "<f1>", "^", { desc = "HACK for karabiner rebinding" })
keymap("n", "<f1>", function() require("fold-cycle").close() end, { desc = "󰘖 Cycle Fold" })

--------------------------------------------------------------------------------
-- MICRO-LEVEL FOLD COMMANDS
-- affect only a single fold

-- goto next closed fold
keymap("n", "gz", function()
	local lnum = fn.line(".")
	local lastLine = fn.line("$")
	local endOfFold = fn.foldclosedend(lnum)
	if endOfFold > 0 then lnum = endOfFold end
	repeat
		if lnum >= lastLine then
			vim.notify("No more fold in this file.")
			return
		end
		lnum = lnum + 1
		local isClosedFold = fn.foldclosed(lnum) > 0
	until isClosedFold
	u.normal(tostring(lnum) .. "G")
end, { desc = "󰘖 Goto next fold" })

-- `h` closes folds when at the beginning of a line (similar to how `l` opens
-- with `vim.opt.foldopen="hor"`). Works well with `vim.opt.startofline = true`
keymap("n", "h", function()
	-- `virtcol` accounts for tab indentation
	local onIndentOrFirstNonBlank = fn.virtcol(".") <= fn.indent(".") + 1 ---@diagnostic disable-line: param-type-mismatch
	local shouldCloseFold = vim.tbl_contains(vim.opt_local.foldopen:get(), "hor")
	if onIndentOrFirstNonBlank and shouldCloseFold then
		local wasFolded = pcall(u.normal, "zc")
		if wasFolded then return end
	end
	vim.cmd.normal { "h", bang = true }
end, { desc = "h (+ close fold at BoL)" })

-- ensure that `l` does not move to the right when opening a fold, otherwise
-- this is the same behavior as with foldopen="hor" already
keymap("n", "l", function()
	local shouldOpenFold = vim.tbl_contains(vim.opt_local.foldopen:get(), "hor")
	local isOnFold = fn.foldclosed(".") > -1 ---@diagnostic disable-line: param-type-mismatch
	if shouldOpenFold and isOnFold then
		pcall(u.normal, "zo")
	else
		u.normal("l")
	end
end, { desc = "l / open fold" })
