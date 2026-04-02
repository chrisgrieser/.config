local config = {
	lightColor = "dawnfox",
	darkColor = "tokyonight",
}
--------------------------------------------------------------------------------

---@param toMode? "dark"|"light"
function vim.g.setColorscheme(toMode)
	if not toMode then toMode = vim.o.background end
	vim.o.background = toMode -- FIX background being stuck on some themes
	local scheme = toMode == "dark" and config.darkColor or config.lightColor
	pcall(vim.cmd.colorscheme, scheme)
end

vim.schedule(vim.g.setColorscheme) -- set initial colorscheme on startup

-- allow toggling colorscheme externally via
-- `nvim --server '/tmp/nvim_server.pipe' --remote-send '<cmd>lua vim.g.setColorscheme("dark")<CR>'`
-- (needed since since `OptionSet` buggy with some colorschemes, see 
-- https://github.com/neovide/neovide/issues/3443)
if vim.g.neovide then
	vim.g.neovide_theme = "auto" -- automatically set `background`
	pcall(os.remove, "/tmp/nvim_server.pipe") -- since after a crash, the server is still there
	vim.fn.serverstart("/tmp/nvim_server.pipe")
end
