require("config/utils")
--------------------------------------------------------------------------------

-- make `gf` work for init.lua
bo.path = ".,./lua,,"

-- regex opener
keymap("n", "gR", function()
	normal('"zya"vi"') -- yank and keep selection for quick replacement when done
	local pattern = fn.getreg("z"):match('"(.*)"')
	local url = "https://gitspartv.github.io/lua-patterns/?pattern=" .. pattern
	os.execute("open '" .. url .. "'") -- opening method on macOS
end, { desc = "Open next lua pattern in lua pattern viewer" })
