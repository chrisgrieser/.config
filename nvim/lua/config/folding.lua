local opt = vim.opt
--------------------------------------------------------------------------------

-- toggle current fold
Keymap("i", "<f1>", "^", { desc = "HACK for karabiner rebinding" })
Keymap("n", "<f1>", function() pcall(Normal, "za") end, { desc = "󰘖 Toggle Fold" })
Keymap("n", "1", function() require("fold-cycle").close() end, { desc = "󰘖 Cycle Fold" })
Keymap("n", "!", "zi", { desc = "󰘖 Toggle Fold Globally" })

-- toggle all toplevel folds
Keymap("n", "zz", function()
	Cmd("%foldclose") -- close toplevel folds
	Cmd("silent! normal! zo") -- open fold cursor is standing on
end, { desc = "󰘖 Close toplevel folds" })


--------------------------------------------------------------------------------

-- fold settings 
opt.foldenable = true
opt.foldlevelstart = 7 -- only applies to new buffers

-- Remember folds and cursor
local function remember(mode)
	local ignoredFts = {
		"TelescopePrompt",
		"DressingSelect",
		"DressingInput",
		"toggleterm",
		"gitcommit",
		"replacer",
		"harpoon",
		"help",
		"qf",
	}
	if vim.tbl_contains(ignoredFts, Bo.filetype) or Bo.buftype ~= "" or not Bo.modifiable then return end

	if mode == "save" then
		Cmd.mkview(1)
	else
		pcall(function() Cmd.loadview(1) end) -- pcall, since cannot load view of newly opened files
	end
end
Autocmd("BufWinLeave", {
	pattern = "?*", -- pattern required, otherwise does not trigger
	callback = function() remember("save") end,
})
Autocmd("BufWinEnter", {
	pattern = "?*",
	callback = function() remember("load") end,
})
