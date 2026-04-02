-- config used for the `pass` cli
--------------------------------------------------------------------------------

vim.keymap.set("n", "<CR>", "ZZ", { desc = "Save and exit" })
vim.keymap.set("n", "q", vim.cmd.cquit, { desc = "Abort" }) -- quit with error = aborting

vim.keymap.set("n", "L", "$")
vim.keymap.set("n", "H", "0^")

vim.keymap.set("n", "ss", "VP", { desc = "Substitute line" })
vim.keymap.set("n", "S", "v$hP", { desc = "Substitute to EoL" })

vim.keymap.set("n", "<Space>", "ciw")
vim.keymap.set("n", "<S-Space>", "daw")

--------------------------------------------------------------------------------

vim.opt.clipboard = "unnamedplus"
vim.opt.fillchars:append { eob = " " } -- no `~` at end of buffer
vim.opt.wrap = false
vim.opt.signcolumn = "yes:1"

---SYNC TERMINAL BACKGROUND-----------------------------------------------------
-- https://github.com/neovim/neovim/issues/16572#issuecomment-1954420136
-- https://www.reddit.com/r/neovim/comments/1ehidxy/you_can_remove_padding_around_neovim_instance/
local termBgModified = false
vim.api.nvim_create_autocmd({ "UIEnter", "ColorScheme" }, {
	desc = "User: Enable terminal background sync",
	callback = function()
		local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
		if normal.bg then
			io.write(string.format("\027]11;#%06x\027\\", normal.bg))
			termBgModified = true
		end
	end,
})

vim.api.nvim_create_autocmd("UILeave", {
	desc = "User: Disable terminal background sync",
	callback = function()
		if termBgModified then io.write("\027]111\027\\") end
	end,
})
