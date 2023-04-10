require("config.utils")

-- typescript uses same config as javascript ftplugin
local javascriptConfig = fn.stdpath("config") .. "/after/ftplugin/javascript.lua"
cmd.source(javascriptConfig)

--------------------------------------------------------------------------------

-- setup quickfix list for npm, see also: https://vonheikemen.github.io/devlog/tools/vim-and-the-quickfix-list/
bo.makeprg = "npm run build"
bo.errorformat = " > %f:%l:%c: %trror: %m" .. ",%-G%.%#" -- = ignore remaining lines

-- Build
-- requires makeprg defined above
keymap("n", "<leader>r", function()
	cmd.update()
	cmd.redir("@z")
	cmd([[silent make]]) -- silent, to not show up message (redirection still works)
	local output = fn.getreg("z"):gsub(".-\r", "") -- remove first line
	local logLevel = output:find("error") and logError or logTrance
	vim.notify(output, logLevel)
	cmd.redir("END")
end, { buffer = true, desc = " npm run build" })
