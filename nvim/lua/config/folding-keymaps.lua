local cmd = vim.cmd
local fn = vim.fn
local keymap = vim.keymap.set
local u = require("config.utils")

--------------------------------------------------------------------------------
-- PAUSE FOLDS WHEN SEARCHING

vim.opt.foldopen:remove { "search" } -- no auto-open when searching
keymap("n", "-", ":set nofoldenable<CR>/")

-- while searching: pause folds -> https://www.reddit.com/r/neovim/comments/zc720y/comment/iyvcdf0/?context=3
vim.on_key(function(char)
	local searchKeys = { "n", "N", "*", "#", "/", "?" }
	local searchConfirmed = (fn.keytrans(char):upper() == "<CR>" and fn.mode() == "c")
	if not (searchConfirmed or fn.mode() == "n") then return end
	local searchKeyUsed = searchConfirmed or (vim.tbl_contains(searchKeys, fn.keytrans(char)))
	---@diagnostic disable-next-line: param-type-mismatch
	if vim.opt.foldenable:get() == searchKeyUsed then vim.opt.foldenable = not searchKeyUsed end
end, vim.api.nvim_create_namespace("auto_pause_folds"))

--------------------------------------------------------------------------------
-- MACRO FOLD COMMANDS

-- UFO REPLACEMENTS OF FOLD COMMANDS

-- INFO fold commands usually change the foldlevel, which fixes folds, e.g.
-- auto-closing them after leaving insert mode, however ufo does not seem to
-- have equivalents for zr and zm because there is no saved fold level.
-- Consequently, the vim-internal fold levels need to be disabled by setting
-- them to 99
vim.opt.foldlevel = 99 
vim.opt.foldlevelstart = 99

keymap("n", "zr", function () require("ufo").openFoldsExceptKinds() end, { desc = "󰘖 󱃄 Open All Folds except kinds" })
keymap("n", "zR", function () require("ufo").openFoldsExceptKinds() end, { desc = "󰘖 󱃄 Open All Folds except kinds" })
keymap("n", "zm", function () require("ufo").closeAllFolds() end, { desc = "󰘖 󱃄 Close All Folds" })
keymap("n", "zM", function () require("ufo").closeAllFolds() end, { desc = "󰘖 󱃄 Close All Folds" })

-- set foldlevel via z{n}
for _, lvl in pairs { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 } do
	local desc = lvl < 3 and "󰘖 Set Fold Level" or "which_key_ignore"
	keymap("n", "z" .. tostring(lvl), function() require("ufo").closeFoldsWith(lvl) end, { desc = desc })
end

-- toggle all toplevel folds, but not the
keymap("n", "zz", function()
	cmd("%foldclose") -- close toplevel folds
	cmd("silent! normal! zo") -- open fold cursor is standing on
end, { desc = "󰘖 Close toplevel folds" })

--------------------------------------------------------------------------------
-- MICRO FOLD COMMANDS

-- Cycle Folds (f1 = ^ Karabiner Remap)
keymap("i", "<f1>", "^", { desc = "HACK for karabiner rebinding" })
keymap("n", "<f1>", function() require("fold-cycle").close() end, { desc = "󰘖 Cycle Fold" })

-- goto next/prev closed fold
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
end, { desc = "󰘖 Goto next closed fold" })

keymap("n", "gZ", function()
	local lnum = fn.line(".")
	local startOfFold = fn.foldclosed(lnum)
	if startOfFold > 0 then lnum = startOfFold end
	repeat
		if lnum <= 1 then
			vim.notify("No more closed fold in this file.")
			return
		end
		lnum = lnum - 1
		local isClosedFold = fn.foldclosed(lnum) > 0
	until isClosedFold
	u.normal(tostring(lnum) .. "G")
end, { desc = "󰘖 Goto previous closed fold" })

-- h closes (similar to how l opens due to opt.foldopen="hor")
-- works well with vim's startofline option
---@diagnostic disable: param-type-mismatch
keymap("n", "h", function()
	local shouldCloseFold = vim.tbl_contains(vim.opt_local.foldopen:get(), "hor")
	local isFirstNonBlank = (vim.fn.col(".") + 1 <= vim.fn.indent(".")) or vim.fn.col(".") == 1
	local notOnFold = fn.foldclosed(".") == -1 
	if isFirstNonBlank and shouldCloseFold and notOnFold then
		pcall(u.normal, "zc")
	else
		u.normal("h")
	end
end, { desc = "h (+ close fold at BoL)" })

-- ensure that `l` does not move to the right when opening a fold, otherwise
-- this is the same behavior as with foldopen="hor" already
keymap("n", "l", function()
	local shouldOpenFold = vim.tbl_contains(vim.opt_local.foldopen:get(), "hor")
	local isOnFold = fn.foldclosed(".") > -1 
	if shouldOpenFold and isOnFold then
		pcall(u.normal, "zo")
	else
		u.normal("l")
	end
end, { desc = "h (+ close fold at BoL)" })
---@diagnostic enable: param-type-mismatch
