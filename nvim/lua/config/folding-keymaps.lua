-- set foldlevel
for _, lvl in pairs { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 } do
	-- stylua: ignore
	Keymap("n", "z" .. tostring(lvl), function () vim.opt_local.foldlevel = lvl end, { desc = "󰘖 Set Fold Level" })
end

-- f1 = ^ (Karabiner Remap)
Keymap("i", "<f1>", "^", { desc = "HACK for karabiner rebinding" })
Keymap("n", "<f1>", function() require("fold-cycle").close() end, { desc = "󰘖 Cycle Fold" })

-- toggle all toplevel folds
Keymap("n", "zz", function()
	Cmd("%foldclose") -- close toplevel folds
	Cmd("silent! normal! zo") -- open fold cursor is standing on
end, { desc = "󰘖 Close toplevel folds" })

-- goto next/prev closed fold
Keymap("n", "gz", function()
	local lnum = Fn.line(".")
	local lastLine = Fn.line("$")
	local endOfFold = Fn.foldclosedend(lnum)
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

Keymap("n", "gZ", function()
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
Keymap(
	"n",
	"zp",
	function() require("ufo").peekFoldedLinesUnderCursor(false, true) end,
	{ desc = "󰘖 󰈈 Preview Fold" }
)

-- make n preview fold (since opt.foldopen does not include search)
Keymap("n", "n", function()
	Normal("n")
	require("ufo").peekFoldedLinesUnderCursor(false, true)
end, { desc = "n + preview fold" })

-- h closes (similar to how l opens due to opt.foldopen="hor")
Keymap("n", "h", function()
	local shouldOpenFold = vim.tbl_contains(vim.opt_local.foldopen:get(), "hor")
	local firstColumn = vim.fn.col(".") == 1
	local notOnFold = vim.fn.foldclosed(".") == -1 ---@diagnostic disable-line: param-type-mismatch
	if firstColumn and shouldOpenFold and notOnFold then
		pcall(Normal, "zc")
	else
		Normal("h")
	end
end, { desc = "h (+ close fold at BoL)" })

Keymap("n", "l", function()
	local shouldOpenFold = vim.tbl_contains(vim.opt_local.foldopen:get(), "hor")
	local isOnFold = vim.fn.foldclosed(".") > -1 ---@diagnostic disable-line: param-type-mismatch
	if shouldOpenFold and isOnFold then
		local hasOpendFold = pcall(Normal, "zo")
		if hasOpendFold then Normal("mf") end -- remember last opened fold in f mark
	else
		Normal("l")
	end
end, { desc = "l (or open fold)" })

Keymap("n", "zu", "mz`fza`z", { desc = "󰘖 Undo Last Fold Toggle" })
