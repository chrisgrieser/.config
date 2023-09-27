local keymap = vim.keymap.set
local u = require("config.utils")

--------------------------------------------------------------------------------

-- extra trailing chars
keymap("n", "<leader>|", "mzA |<Esc>`z", { desc = "which_key_ignore", buffer = true })
keymap("n", "<leader>\\", "mzA \\<Esc>`z", { desc = "which_key_ignore", buffer = true })

-- fix my habits
u.ftAbbr("//", "#")
u.ftAbbr("--", "#")

u.applyTemplateIfEmptyFile("zsh")
