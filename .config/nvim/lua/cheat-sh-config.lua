g.CheatSheetSilent = 0
g.CheatSheetDoNotMap = 1
g.CheatDoNotReplaceKeywordPrg = 1
g.CheatSheetReaderCmd = 'vsplit'
g.CheatSheetStayInOrigBuf = 0

keymap("n", "<leader>k",
	[[:call cheat#cheat("", getcurpos()[1], getcurpos()[1], 0, 0, '!')<CR>]],
	{script = true, silent = true}
)
keymap("v", "<leader>k",
	[[:call cheat#cheat("", -1, -1, 2, 0, '!')<CR>]],
	{script = true, silent = true}
)

-- autocmd("BufWinEnter", {
-- 	pattern = g.CheatSheetBufferName,
-- 	callback = function ()
-- 		bo.syntax="ON" -- needed cause treesitter turns syntax off
-- 		keymap({"n", "v"}, "q", ":quit<CR>", {silent = true, buffer = true}) -- since it's effectively a read only mode
-- 		keymap({"n", "v"}, "<leader>k", ":call cheat#navigate(1,'Q')<CR>", {silent = true, buffer = true, script = true})
-- 	end
-- })

