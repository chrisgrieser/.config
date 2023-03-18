require("config.utils")
--------------------------------------------------------------------------------

-- typescript uses same config as javascript ftplugin
local javascriptConfig = Fn.stdpath("config") .. "/after/ftplugin/javascript.lua"
Cmd.source(javascriptConfig)

-- setup quickfix list for npm, see also: https://vonheikemen.github.io/devlog/tools/vim-and-the-quickfix-list/
bo.makeprg = "npm run build"
bo.errorformat = " > %f:%l:%c: %trror: %m" .. ",%-G%.%#" -- = ignore remaining lines

-- Build
-- requires makeprg defined above
Keymap("n", "<leader>r", function()
	Cmd.update()
	Cmd.redir("@z")
	Cmd([[silent make]]) -- silent, to not show up message (redirection still works)
	local output = Fn.getreg("z"):gsub(".-\r", "") -- remove first line
	local logLevel = output:find("error") and LogError or LogTrace
	vim.notify(output, logLevel)
	Cmd.redir("END")
end, { buffer = true, desc = " npm run build" })
