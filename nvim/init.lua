vim.g.localRepos = vim.env.HOME .. "/Developer"
vim.g.notesDir = vim.env.HOME .. "/Notes"
vim.g.iCloudSync = vim.env.HOME .. "/Library/Mobile Documents/com~apple~CloudDocs/Tech/nvim-data"

--------------------------------------------------------------------------------

local sRequire = require("config.utils").safeRequire

sRequire("config.restart-and-reopen")
sRequire("config.options") -- before plugins, so they are available for them
sRequire("config.neovide-gui-settings")

sRequire("config.nvim-pack")
sRequire("config.colorscheme")

sRequire("config.autocmds")
sRequire("config.keybindings")

sRequire("personal-plugins.git-conflict")
sRequire("config.spellfixes")
sRequire("personal-plugins.messages-to-notify")
