local keymap = vim.keymap.set
local u = require("config.utils")

--------------------------------------------------------------------------------

-- fix my habits
u.ftAbbr("//", "#")
u.ftAbbr("--", "#")

u.applyTemplateIfEmptyFile("zsh")
