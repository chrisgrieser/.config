require("config.utils")
--------------------------------------------------------------------------------

-- lua regex opener
keymap("n", "g/", function()
	normal('"zya"vi"') -- yank and keep selection for quick replacement when done
	local pattern = fn.getreg("z"):match('"(.-)"')
	local url = "https://gitspartv.github.io/lua-patterns/?pattern=" .. pattern
	fn.system("open '" .. url .. "'") -- opening method on macOS
end, { desc = "Open next lua pattern in regex viewer", buffer = true })

-- Build
keymap("n", "<leader>r", function()
	cmd.update()
	local parentFolder = expand("%:p:h")
	if parentFolder:find("nvim") then
		cmd.source()
		vim.notify(expand("%:r") .. " re-sourced.")
	elseif parentFolder:find("hammerspoon") then
		os.execute([[open -g "hammerspoon://hs-reload"]])
	end
end, {buffer = true, desc = " Reload"})
