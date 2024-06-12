vim.bo.commentstring = "// %s" -- add space

--------------------------------------------------------------------------------

-- fix my habits
local function abbr(lhs, rhs) vim.keymap.set("ia", lhs, rhs, { buffer = true }) end

abbr("cosnt", "const")
abbr("local", "const")
abbr("--", "//")
abbr("~=", "!==")
abbr("elseif", "else if")

--------------------------------------------------------------------------------
