require("config.utils")
--------------------------------------------------------------------------------

local function leaveVisualMode()
	-- https://github.com/neovim/neovim/issues/17735#issuecomment-1068525617
	local escKey = vim.api.nvim_replace_termcodes("<Esc>", false, true, true)
	vim.api.nvim_feedkeys(escKey, "nx", false)
end

-- use 2 spaces instead of tabs
bo.shiftwidth = 2
bo.tabstop = 2
bo.softtabstop = 2
bo.expandtab = true
wo.listchars = "tab: >"

-- does not work perfectly yet though
keymap("x", "<D-m>", function ()
	leaveVisualMode()
	cmd [['<,'> !yq -P -o=json -I=0]]
	cmd[[.s/\d\@<!"\d\@!//ge]] -- remove quotes that do not surround a number https://vim.fandom.com/wiki/Regex_lookahead_and_lookbehind
	cmd[[.s/:/: /ge]]
	cmd[[.s/,/, /ge]]
	normal("kJ")
end, {desc = "minify YAML", buffer = true})
