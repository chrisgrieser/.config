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
keymap("n", "R",function ()
	local line = fn.getline(".")
	fn.append(".", line)
	if line:find("top") then line = line:gsub("top", "bottom")
	elseif line:find("bottom") then line = line:gsub("bottom", "top")
	elseif line:find("right") then line = line:gsub("right", "left")
	elseif line:find("left") then line = line:gsub("left", "right")
	elseif line:find("width") then line = line:gsub("width", "height")
	elseif line:find("height") then line = line:gsub("height", "width")
	end
	fn.setline(".", line)
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
