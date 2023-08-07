local keymap = vim.keymap.set
local expand = vim.fn.expand
local u = require("config.utils")
--------------------------------------------------------------------------------

-- TODO: explainshell Docker Image
-- https://github.com/bash-lsp/bash-language-server/tree/main/vscode-client#configuration
-- https://github.com/bash-lsp/bash-language-server/issues/180

--------------------------------------------------------------------------------

-- send to WEZTERM
keymap("n", "<leader>t", function ()
	vim.fn.system("wezterm cli send-text" .. expand("%:p:h"))
end, { desc = " Send to WeZterm", buffer = true})

--------------------------------------------------------------------------------

-- habit from writing too much js or lua
vim.cmd.inoreabbrev("<buffer> // #")
vim.cmd.inoreabbrev("<buffer> -- #")

u.applyTemplateIfEmptyFile("zsh")

-- pipe textobj
--stylua: ignore
keymap({ "o", "x" }, "i|", "<cmd>lua require('various-textobjs').shellPipe(true)<CR>", { desc = "󱡔 inner shellPipe textobj", buffer = true })
--stylua: ignore
keymap({ "o", "x" }, "a|", "<cmd>lua require('various-textobjs').shellPipe(false)<CR>", { desc = "󱡔 outer shellPipe textobj", buffer = true })

--------------------------------------------------------------------------------

-- Reload Sketchybar
keymap("n", "<leader>r", function()
	vim.cmd("silent update")
	if expand("%:p:h"):find("sketchybar") then
		vim.fn.system([[brew services restart sketchybar]])
	else
		vim.notify("Not in a sketchybar directory.", u.warn)
	end
end, { buffer = true, desc = "  Reload sketchybar" })
