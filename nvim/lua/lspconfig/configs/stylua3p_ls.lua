-- INFO https://github.com/antonk52/lua-3p-language-servers
-- required location: lua/lspconfig/configs/stylua3p_ls.lua
--------------------------------------------------------------------------------

local util = require("lspconfig.util")

return {
	default_config = {
		cmd = { "stylua-3p-language-server" },
		filetypes = { "lua" },
		root_dir = util.root_pattern(".stylua.toml"),
	},
}
