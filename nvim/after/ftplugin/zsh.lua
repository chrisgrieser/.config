-- ABBREVIATIONS
local abbr = require("config.utils").bufAbbrev
abbr("//", "#")
abbr("--", "#")
abbr("delay", "sleep")
abbr("const", "local")

--------------------------------------------------------------------------------
local keymap = require("config.utils").bufKeymap
keymap("n", "<D-s>", vim.lsp.buf.format, { desc = " Format" })
