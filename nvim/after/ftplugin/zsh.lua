-- use bash parser for zsh files
vim.treesitter.language.register("bash", "zsh")

--------------------------------------------------------------------------

-- ABBREVIATIONS
local abbr = require("config.utils").bufAbbrev
abbr("//", "#")
abbr("delay", "sleep")
abbr("const", "local")

--------------------------------------------------------------------------------
-- KEYMAPS
local bkeymap = require("config.utils").bufKeymap

bkeymap("n", "<D-s>", function()
	vim.cmd([[% substitute_/Users/\w\+/_$HOME/_e]]) -- replace `/Users/…` with `$HOME/`
	vim.lsp.buf.format()
end, { desc = " Format" })
