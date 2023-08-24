local keymap = vim.keymap.set
local fn = vim.fn
local expand = vim.fn.expand
local u = require("config.utils")
local abbr = vim.cmd.inoreabbrev
--------------------------------------------------------------------------------

-- TODO: explainshell Docker Image
-- https://github.com/bash-lsp/bash-language-server/tree/main/vscode-client#configuration
-- https://github.com/bash-lsp/bash-language-server/issues/180

--------------------------------------------------------------------------------

-- bash-lsp has no symbol support, so using treesitter instead
keymap(
	"n",
	"gs",
	function() vim.cmd.Telescope("treesitter") end,
	{ desc = " Document Symbols", buffer = true }
)

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

	local text
	if fn.mode() == "n" then
		text = vim.api.nvim_get_current_line() .. "\n"
	elseif fn.mode():find("[Vv]") then
		u.normal('"zy')
		text = fn.getreg("z"):gsub("\n$", "")
	end
	fn.system { "wezterm", "send-text", "--no-paste", text }
end

keymap({ "n", "x" }, "<localleader>t", sendToWezTerm, { desc = " Send to WezTerm", buffer = true })

-- extra trailing chars
keymap("n", "<leader>|", "mzA |<Esc>`z", { desc = " | to EoL", buffer = true })
keymap("n", "<leader>\\", "mzA \\<Esc>`z", { desc = " \\ to EoL", buffer = true })

-- habit from writing too much js or lua
abbr("<buffer> // #")
abbr("<buffer> -- #")

u.applyTemplateIfEmptyFile("zsh")

-- pipe textobj
--stylua: ignore
keymap({ "o", "x" }, "i|", "<cmd>lua require('various-textobjs').shellPipe(true)<CR>", { desc = "󱡔 inner shellPipe textobj", buffer = true })
--stylua: ignore
keymap({ "o", "x" }, "a|", "<cmd>lua require('various-textobjs').shellPipe(false)<CR>", { desc = "󱡔 outer shellPipe textobj", buffer = true })

--------------------------------------------------------------------------------

-- Reload Sketchybar
keymap("n", "<localleader><localleader>", function()
	vim.cmd("silent update")
	if expand("%:p:h"):find("sketchybar") then
		fn.system([[brew services restart sketchybar]])
	else
		vim.notify("Not in a sketchybar directory.", u.warn)
	end
end, { buffer = true, desc = "  Reload sketchybar" })
