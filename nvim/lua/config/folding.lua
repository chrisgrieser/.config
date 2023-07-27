local cmd = vim.cmd
local fn = vim.fn
local keymap = vim.keymap.set
local u = require("config.utils")
local bo = vim.bo

--------------------------------------------------------------------------------

-- REMEMBER FOLDS (AND CURSOR LOCATION)
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
		function() require("ufo").closeFoldsWith(lvl) end,
		{ desc = desc }
	)
end

--------------------------------------------------------------------------------
-- MESO-LEVEL FOLD COMMANDS
-- affect multiple folds, but not all

-- Cycle Folds (f1 = ^ Karabiner Remap)
keymap({ "c", "i" }, "<f1>", "^", { desc = "HACK for karabiner rebinding" })
keymap("n", "<f1>", function() require("fold-cycle").close() end, { desc = "󰘖 Cycle Fold" })
