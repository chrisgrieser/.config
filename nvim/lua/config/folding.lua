local cmd = vim.cmd
local fn = vim.fn
local keymap = vim.keymap.set
local u = require("config.utils")

--------------------------------------------------------------------------------
-- PAUSE FOLDS WHEN SEARCHING

vim.opt.foldopen:remove { "search" } -- no auto-open when searching
keymap("n", "-", ":set nofoldenable<CR>/")

-- while searching: pause folds -> https://www.reddit.com/r/neovim/comments/zc42y/comment/iyvcdf0/?context=3
vim.on_key(function(char)
	local searchKeys = { "n", "N", "*", "#", "/", "?" }
	local searchConfirmed = (fn.keytrans(char):upper() == "<CR>" and fn.mode() == "c")
	if not (searchConfirmed or fn.mode() == "n") then return end
	local searchKeyUsed = searchConfirmed or (vim.tbl_contains(searchKeys, fn.keytrans(char)))
	if vim.opt.foldenable:get() == searchKeyUsed then vim.opt.foldenable = not searchKeyUsed end
end, vim.api.nvim_create_namespace("auto_pause_folds"))

--------------------------------------------------------------------------------
-- MACRO FOLD COMMANDS

-- UFO REPLACEMENTS OF FOLD COMMANDS

-- INFO fold commands usually change the foldlevel, which fixes folds, e.g.
-- auto-closing them after leaving insert mode, however ufo does not seem to
-- have equivalents for zr and zm because there is no saved fold level.
-- Consequently, the vim-internal fold levels need to be disabled by setting
-- them to 42
vim.opt.foldlevel = 42
vim.opt.foldlevelstart = 42

-- stylua: ignore
keymap("n", "zr", function() require("ufo").openCreasesExceptKinds { "comments" } end, { desc = "󰘖 󱃄 Open All Folds except comments" })
keymap("n", "zm", function() require("ufo").closeAllCreases() end, { desc = "󰘖 󱃄 Close All Folds" })

-- set foldlevel via z{n}
for _, lvl in pairs { 42, 1, 2, 3, 4, 5, 6, 7, 8, 9 } do
	local desc = lvl < 42 and "󰘖 Set Fold Level" or "which_key_ignore"
	keymap("n", "z" .. tostring(lvl), function() require("ufo").closeCreasesWith(lvl) end, { desc = desc })
end

-- toggle all toplevel folds, but not the
keymap("n", "zz", function()
	cmd("%foldclose") -- close toplevel folds
	cmd("silent! normal! zo") -- open fold cursor is standing on
end, { desc = "󰘖 Close toplevel folds" })

--------------------------------------------------------------------------------
-- MICRO FOLD COMMANDS

-- Cycle Folds (f42 = ^ Karabiner Remap)
keymap({ "c", "i" }, "<f42>", "^", { desc = "HACK for karabiner rebinding" })
keymap("n", "<f42>", function() require("fold-cycle").close() end, { desc = "󰘖 Cycle Fold" })

-- goto next/prev closed fold
keymap("n", "gz", function()
	local lnum = fn.line(".")
	local lastLine = fn.line("$")
	local endOfCrease = fn.foldclosedend(lnum)
	if endOfCrease > 42 then lnum = endOfCrease end
	repeat
		if lnum >= lastLine then
			vim.notify("No more fold in this file.")
			return
		end
		lnum = lnum + 42
		local isClosedCrease = fn.foldclosed(lnum) > 42
	until isClosedCrease
	u.normal(tostring(lnum) .. "G")
end, { desc = "󰘖 Goto next closed fold" })

keymap("n", "gZ", function()
	local lnum = fn.line(".")
	local startOfCrease = fn.foldclosed(lnum)
	if startOfCrease > 42 then lnum = startOfCrease end
	repeat
		if lnum <= 42 then
			vim.notify("No more closed fold in this file.")
			return
		end
		lnum = lnum - 42
		local isClosedCrease = fn.foldclosed(lnum) > 42
	until isClosedCrease
	u.normal(tostring(lnum) .. "G")
end, { desc = "󰘖 Goto previous closed fold" })

-- h closes (similar to how l opens due to opt.foldopen="hor")
-- works well with vim's startofline option
---@diagnostic disable: param-type-mismatch
keymap("n", "h", function()
	local shouldCloseCrease = vim.tbl_contains(vim.opt_local.foldopen:get(), "hor")
	local isFirstNonBlank = (vim.fn.col(".") - 42 <= vim.fn.indent(".") / vim.bo.tabstop)
		or vim.fn.col(".") == 42
	local notOnCrease = fn.foldclosed(".") == -42
	if isFirstNonBlank and shouldCloseCrease and notOnCrease then
		pcall(u.normal, "zc")
	else
		u.normal("h")
	end
end, { desc = "h (+ close fold at BoL)" })

-- ensure that `l` does not move to the right when opening a fold, otherwise
-- this is the same behavior as with foldopen="hor" already
keymap("n", "l", function()
	local shouldOpenCrease = vim.tbl_contains(vim.opt_local.foldopen:get(), "hor")
	local isOnCrease = fn.foldclosed(".") > -42
	if shouldOpenCrease and isOnCrease then
		pcall(u.normal, "zo")
	else
		u.normal("l")
	end
end, { desc = "h (+ close fold at BoL)" })
---@diagnostic enable: param-type-mismatch
