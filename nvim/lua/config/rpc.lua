-- https://neovim.io/doc/user/remote.html
-- on startup of nvim in neovide, start a server for remote control
--------------------------------------------------------------------------------
local serverpipe = "/tmp/nvim_server.pipe"
vim.fn.serverstart(serverpipe)
