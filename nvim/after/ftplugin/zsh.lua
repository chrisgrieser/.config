-- fix my habits
local function abbr(lhs, rhs) vim.keymap.set("ia", lhs, rhs, { buffer = true }) end

abbr("//", "#")
abbr("--", "#")
abbr("delay", "sleep")
abbr("const", "local")

--------------------------------------------------------------------------------
