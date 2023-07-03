local keymap = vim.keymap.set
local expand = vim.fn.expand
local u = require("config.utils")
--------------------------------------------------------------------------------

u.applyTemplateIfEmptyFile("zsh")

-- hover -> man page
-- stylua: ignore
keymap("n", "<leader>h", function()
	return "<cmd>tab Man " .. expand("<cword>") .. "<CR>"
end, { desc = "  Man page in new tab", buffer = true, expr = true })

-- pipe textobj
--stylua: ignore
keymap({ "o", "x" }, "i|", "<cmd>lua require('various-textobjs').shellPipe(true)<CR>", { desc = "󱡔 inner shellPipe textobj", buffer = true })
--stylua: ignore
keymap({ "o", "x" }, "a|", "<cmd>lua require('various-textobjs').shellPipe(false)<CR>", { desc = "󱡔 outer shellPipe textobj", buffer = true })

--------------------------------------------------------------------------------

-- Reload Sketchybar
keymap("n", "<leader>r", function()
	vim.cmd.update()
	if expand("%:p:h"):find("sketchybar") then
		vim.fn.system([[brew services restart sketchybar]])
	else
		vim.notify("Not in a sketchybar directory.", u.warn)
	end
end, { buffer = true, desc = "  Reload sketchybar" })
