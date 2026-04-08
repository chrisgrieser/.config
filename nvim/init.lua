vim.g.localRepos = vim.env.HOME .. "/Developer"
vim.g.notesDir = vim.env.HOME .. "/Notes"
vim.g.iCloudSync = vim.env.HOME .. "/Library/Mobile Documents/com~apple~CloudDocs/Tech/nvim-data"
vim.g.serverAddress = "/tmp/nvim_server.pipe"

--------------------------------------------------------------------------------
require("config.utils") -- first to load globals

local sRequire = require("config.utils").safeRequire

sRequire("config.restart-and-reopen")
sRequire("config.options") -- before plugins, so they are available for them
sRequire("config.neovide-gui-settings") -- correct gui settings during plugin installation

sRequire("config.nvim-pack")
-- sRequire("personal-plugins.messages-to-notify") -- after plugins, since needing notification plugin
sRequire("personal-plugins.ui2")
sRequire("config.colorscheme") -- after plugins, since needing colorscheme plugin

sRequire("config.autocmds")
sRequire("config.keybindings")

sRequire("personal-plugins.git-conflict")
sRequire("config.spellfixes")
