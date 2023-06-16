local cmd = vim.cmd
local fn = vim.fn
local keymap = vim.keymap.set
local u = require("config.utils")

--------------------------------------------------------------------------------
-- PAUSE FOLDS WHEN SEARCHING

vim.opt.foldopen:remove { "search" } -- no auto-open when searching

keymap("n", "-", "zn/", { desc = "/ & Pause Folds" })

-- while searching: pause folds
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
-- MESO FOLD COMMANDS
-- (cycles multiple folds, but not all)

-- Cycle Folds (f1 = ^ Karabiner Remap)
keymap({ "c", "i" }, "<f1>", "^", { desc = "HACK for karabiner rebinding" })
keymap("n", "<f1>", function() require("fold-cycle").close() end, { desc = "󰘖 Cycle Fold" })

--------------------------------------------------------------------------------
-- MICRO FOLD COMMANDS

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

-- h closes (similar to how l opens due to opt.foldopen="hor")
-- works well with vim's startofline option
---@diagnostic disable: param-type-mismatch
keymap("n", "h", function()
	-- `virtcol` accounts for tab indentation
	local onIndentOrFirstNonBlank = fn.virtcol(".") <= fn.indent(".") + 1
	local shouldCloseFold = vim.tbl_contains(vim.opt_local.foldopen:get(), "hor")

	if onIndentOrFirstNonBlank and shouldCloseFold then
		local wasFolded = pcall(u.normal, "zc")
		-- fallback: the line didn't have a closable fold, then use h to go into
		-- into the indentation
		if not wasFolded then u.normal("h") end
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
end, { desc = "l / open fold" })
---@diagnostic enable: param-type-mismatch
