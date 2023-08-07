local keymap = vim.keymap.set
local fn = vim.fn
local expand = vim.fn.expand
local u = require("config.utils")
--------------------------------------------------------------------------------

-- TODO: explainshell Docker Image
-- https://github.com/bash-lsp/bash-language-server/tree/main/vscode-client#configuration
-- https://github.com/bash-lsp/bash-language-server/issues/180

--------------------------------------------------------------------------------

-- https://wezfurlong.org/wezterm/cli/cli/send-text
local function sendToWezTerm()
	fn.system([[
		open -a 'WezTerm' 
		i=0
		while ! pgrep -xq wezterm-gui; do 
			sleep 0.1
			i=$((i+1))
			test $i -gt 30 && return
		done
		sleep 0.2
	]])
	local command

	if fn.mode() == "n" then
		local text = vim.api.nvim_get_current_line()
		command = ("wezterm cli send-text --no-paste '%s\n'"):format(text)
	elseif fn.mode() == "x" then
		u.normal('"zy')
		local selectedText = fn.getreg("z"):gsub("\n$", "")
		command = ("wezterm cli send-text '%s'"):format(selectedText)
	end

	fn.system(command)
end

keymap("n", "<leader>t", sendToWezTerm, { desc = " Send line to WezTerm", buffer = true })
keymap("x", "<leader>t", sendToWezTerm, { desc = " Send selection to WezTerm", buffer = true })

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
		fn.system([[brew services restart sketchybar]])
	else
		vim.notify("Not in a sketchybar directory.", u.warn)
	end
end, { buffer = true, desc = "  Reload sketchybar" })
