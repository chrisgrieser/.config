local M = {}
--------------------------------------------------------------------------------

-- TODO preview https://neovim.io/doc/user/map.html#%3Acommand-preview

function M.substitute() end

function M.setup()
	vim.api.nvim_create_user_command( "S", { nargs = 1, addr = "lines" })
end

--------------------------------------------------------------------------------
return M
