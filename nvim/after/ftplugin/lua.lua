require("config.utils")
--------------------------------------------------------------------------------

-- lua regex opener
keymap("n", "g/", function()
	normal('"zya"vi"') -- yank and keep selection for quick replacement when done
	local pattern = fn.getreg("z"):match('"(.*)"')
	local url = "https://gitspartv.github.io/lua-patterns/?pattern=" .. pattern
	fn.system("open '" .. url .. "'") -- opening method on macOS
end, { desc = "Open next lua pattern in regex viewer", buffer = true })


keymap("n", "go", function()
	local isGitRepo = os.execute("test -e $(git rev-parse --show-toplevel)/.git") == 0 -- using test -e instead of -f to check for repo and submodule
	local cwd = expand("%:p:h")
	local scope = "find_files"
	if cwd:find("/nvim/") and not (cwd:find("/my%-plugins/")) then
		scope = "find_files cwd=" .. fn.stdpath("config")
	elseif cwd:find("/hammerspoon/") then
		scope = "find_files cwd=" .. vim.env.DOTFILE_FOLDER .. "/hammerspoon/"
	elseif isGitRepo and not (cwd:find(vim.env.DOTFILE_FOLDER)) then
		scope = "git_files"
	end
	cmd("Telescope " .. scope)
end, { buffer = true, desc = " Smart in repo/folder"  })
