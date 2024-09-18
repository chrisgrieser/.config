-- ABBREVIATIONS
local abbr = require("config.utils").bufAbbrev
abbr("//", "#")
abbr("--", "#")
abbr("delay", "sleep")
abbr("const", "local")

--------------------------------------------------------------------------------
-- KEYMAPS
local keymap = require("config.utils").bufKeymap

keymap("n", "<D-s>", function()
	vim.cmd([[% s_/Users/\w\+/_$HOME/_e]]) -- replace `/Users/…` with `$HOME/`
	vim.lsp.buf.format()
end, { desc = " Format" })
