require("config.utils")
--------------------------------------------------------------------------------

-- lua regex opener
keymap("n", "g/", function()
	normal('"zya"vi"') -- yank and keep selection for quick replacement when done
	local pattern = fn.getreg("z"):match('"(.*)"')
	local url = "https://gitspartv.github.io/lua-patterns/?pattern=" .. pattern
	fn.system("open '" .. url .. "'") -- opening method on macOS
end, { desc = "Open next lua pattern in regex viewer", buffer = true })

-- if in neovim config, find files in neovim config only
keymap("n", "go", function()
	local isNvimConfig = expand("%:p"):find(fn.stdpath("config"))
	local isCustomPlugin = expand("%:p"):find("my%-plugins")
	if isNvimConfig and not isCustomPlugin then
		telescope.find_files {
			cwd = fn.stdpath("config"),
			prompt_title = "nvim config",
			prompt_prefix = "漣 ",
		}
	else
		telescope.find_files()
	end
end, { desc = "Telescope: Files in neovim config", buffer = true })
