require("utils")
local opts = {buffer = true, silent = true}
--------------------------------------------------------------------------------

-- comment marks more useful than symbols for theme development
keymap("n", "gs", function() telescope.current_buffer_fuzzy_find {
		default_text = "/* < ",
		prompt_prefix = " ",
		prompt_title = "Navigation Markers",
	}
end, opts)

-- search only for variables
keymap("n", "gS", function() telescope.current_buffer_fuzzy_find {
		default_text = "--",
		prompt_prefix = " ",
		prompt_title = "CSS Variables",
	}
end, opts)

-- INFO: fix syntax highlighting with ':syntax sync fromstart'
-- various other solutions are described here: https://github.com/vim/vim/issues/2790
-- however, using treesitter, this is less of an issue, but treesitter css
-- highlighting isn't good yet, so...
keymap("n", "zz", ":syntax sync fromstart<CR>", {buffer = true})

keymap("n", "cv", "^Ewct;", opts) -- change [v]alue key
keymap("n", "<leader>c", "mzlEF.yEEp`z", opts) -- double [c]lass under cursor
keymap("n", "<leader>C", "lF.d/[.\\s]<CR>:nohl<CR>", opts) -- delete [c]lass under cursor

-- prefix "." and join the last paste. Useful when copypasting from the dev tools
keymap("n", "<leader>.", "mz`[v`]: s/^\\| /./g<CR>:nohl<CR>`zl", opts)

---@diagnostic disable: undefined-field, param-type-mismatch

-- replicate line and switch top/bottom right/left
keymap("n", "R", function()
	local line = fn.getline(".")
	local newLine = line
	if line:find("top") then newLine = line:gsub("top", "bottom")
	elseif line:find("bottom") then newLine = line:gsub("bottom", "top")
	elseif line:find("right") then newLine = line:gsub("right", "left")
	elseif line:find("left") then newLine = line:gsub("left", "right")
	elseif line:find("width") then newLine = line:gsub("width", "height")
	elseif line:find("height") then newLine = line:gsub("height", "width")
	end
	fn.append(".", newLine)

	-- move cursor line down
	local lineNum = api.nvim_win_get_cursor(0)[1]
	local colNum
	local lineHasChanged = newLine == line
	print(line)
	print(newLine)
	if lineHasChanged then
		-- if line was changed, move cursor to value
		local _, valuePos = line:find(": ?")
		colNum = valuePos + 1
	else
		colNum = api.nvim_win_get_cursor(0)[2]
	end
	api.nvim_win_set_cursor(0, {lineNum + 1, colNum})
end, opts)

-- toggle !important
keymap("n", "<leader>i", function()
	local lineContent = fn.getline(".")
	if lineContent:find("!important") then
		lineContent = lineContent:gsub(" !important", "")
	else
		lineContent = lineContent:gsub(";", " !important;")
	end
	fn.setline(".", lineContent)
end, {buffer = true})
---@diagnostic enable: undefined-field, param-type-mismatch
