local fn = vim.fn
local cmd = vim.cmd
local keymap = vim.keymap.set
--------------------------------------------------------------------------------

-- disable fold when searching
keymap("n", "-", ":set nofoldenable<CR>/")

-- while searching: pause folds -> https://www.reddit.com/r/neovim/comments/zc720y/comment/iyvcdf0/?context=3
vim.on_key(function(char)
	local searchKeys = { "n", "N", "*", "#", "/", "?" }
	local searchConfirmed = (fn.keytrans(char):upper() == "<CR>" and fn.mode() == "c")
	if not (searchConfirmed or fn.mode() == "n") then return end
	local searchKeyUsed = searchConfirmed or (vim.tbl_contains(searchKeys, fn.keytrans(char)))
	if vim.opt.foldenable:get() == searchKeyUsed then vim.opt.foldenable = not searchKeyUsed end
end, vim.api.nvim_create_namespace("auto_pause_folds"))

--------------------------------------------------------------------------------

-- set foldlevel
for _, lvl in pairs { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 } do
	local desc = lvl < 3 and "󰘖 Set Fold Level" or "which_key_ignore"
	keymap("n", "z" .. tostring(lvl), function() vim.opt_local.foldlevel = lvl end, { desc = desc })
end

-- f1 = ^ (Karabiner Remap)
keymap("i", "<f1>", "^", { desc = "HACK for karabiner rebinding" })
keymap("n", "<f1>", function() require("fold-cycle").close() end, { desc = "󰘖 Cycle Fold" })

-- toggle all toplevel folds
keymap("n", "zz", function()
	cmd("%foldclose") -- close toplevel folds
	cmd("silent! normal! zo") -- open fold cursor is standing on
end, { desc = "󰘖 Close toplevel folds" })

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
		local isClosedFold = Fn.foldclosed(lnum) > 0
	until isClosedFold
	Normal(tostring(lnum) .. "G")
end, { desc = "󰘖 Goto next closed fold" })

keymap("n", "gZ", function()
	local lnum = Fn.line(".")
	local startOfFold = Fn.foldclosed(lnum)
	if startOfFold > 0 then lnum = startOfFold end
	repeat
		if lnum <= 1 then
			vim.notify("No more closed fold in this file.")
			return
		end
		lnum = lnum - 1
		local isClosedFold = Fn.foldclosed(lnum) > 0
	until isClosedFold
	Normal(tostring(lnum) .. "G")
end, { desc = "󰘖 Goto previous closed fold" })

-- preview fold
-- stylua: ignore
keymap("n", "zp", function() require("ufo").peekFoldedLinesUnderCursor(false, true) end, { desc = "󰘖 󰈈 Preview Fold" })

-- h closes (similar to how l opens due to opt.foldopen="hor")
keymap("n", "h", function()
	local shouldOpenFold = vim.tbl_contains(vim.opt_local.foldopen:get(), "hor")
	local firstColumn = fn.col(".") == 1
	local notOnFold = fn.foldclosed(".") == -1 ---@diagnostic disable-line: param-type-mismatch
	if firstColumn and shouldOpenFold and notOnFold then
		pcall(Normal, "zc")
	else
		Normal("h")
	end
end, { desc = "h (+ close fold at BoL)" })

keymap("n", "l", function()
	local shouldOpenFold = vim.tbl_contains(vim.opt_local.foldopen:get(), "hor")
	local isOnFold = fn.foldclosed(".") > -1 ---@diagnostic disable-line: param-type-mismatch
	if shouldOpenFold and isOnFold then
		local hasOpendFold = pcall(Normal, "zo")
		if hasOpendFold then Normal("mf") end -- remember last opened fold in f mark
	else
		Normal("l")
	end
end, { desc = "l (or open fold)" })

keymap("n", "zu", "mz`fza`z", { desc = "󰘖 Undo Last Fold Toggle" })
