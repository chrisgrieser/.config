-- https://bryankegley.me/posts/nvim-getting-started/
-- https://neovim.io/doc/user/vim_diff.html
--------------------------------------------------------------------------------

-- required for homebrew installs (where the runtimepath is in the homebrew dir)
vim.opt.runtimepath:append(', "~/.config/nvim/lua"') 

require("options")
require("keybindings")
require("plugins")


-------------------------------------------------------------------------------

-- https://www.reddit.com/r/neovim/comments/puuskh/how_to_reload_my_lua_config_while_using_neovim/
function reloadConfig()
	for name,_ in pairs(package.loaded) do
		package.loaded[name] = nil
	end
	dofile(vim.env.MYVIMRC)
end
command('reload', reloadConfig)
keymap("n", "<leader>r", ":reload<CR>")
