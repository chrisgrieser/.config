local bkeymap = require("config.utils").bufKeymap
local abbr = require("config.utils").bufAbbrev
--------------------------------------------------------------------------------

-- habits from writing too much in other languages
abbr("//", "--")
abbr("const", "local")
abbr("fi", "end")
abbr("!=", "~=")
abbr("!==", "~=")
abbr("=~", "~=") -- shell uses `=~`
abbr("===", "==")

--------------------------------------------------------------------------------
-- REQUIRE MODULE FROM CWD

-- lightweight version of telescope-import.nvim import (just for lua)
bkeymap("n", "<leader>ci", function()
	local regex = [[local (\w+) = require\(["'](.*?)["']\)(\.[\w.]*)?]]
	local rgArgs = { "rg", "--no-config", "--only-matching", "--no-filename", regex }
	local rgResult = vim.system(rgArgs):wait()
	assert(rgResult.code == 0, rgResult.stderr)
	local matches = vim.split(rgResult.stdout, "\n", { trimempty = true })
	table.sort(matches)
	local uniqMatches = vim.fn.uniq(matches)
	local isAtBlank = vim.api.nvim_get_current_line():match("^%s*$")

	vim.api.nvim_create_autocmd("FileType", {
		desc = "User (buffer-specific): Set filetype to `lua` for `TelescopeResults`",
		pattern = "TelescopeResults",
		once = true,
		callback = function(ctx)
			vim.api.nvim_set_option_value("filetype", "lua", { buf = ctx.buf })
			-- make discernible as the results are now colored
			local ns = vim.api.nvim_create_namespace("telescope-import")
			vim.api.nvim_win_set_hl_ns(0, ns)
			vim.api.nvim_set_hl(ns, "TelescopeMatching", { reverse = true })
		end,
	})

	vim.ui.select(uniqMatches, { prompt = " require" }, function(selection)
		if not selection then return end
		if isAtBlank then
			vim.api.nvim_set_current_line(selection)
			vim.cmd.normal { "==", bang = true }
		else
			local lnum = vim.api.nvim_win_get_cursor(0)[1]
			vim.api.nvim_buf_set_lines(0, lnum, lnum, false, { selection })
			vim.cmd.normal { "j==", bang = true }
		end
	end)
end, { desc = " Import module" })

--------------------------------------------------------------------------------

bkeymap("n", "<leader>rf", function()
	local node = vim.treesitter.get_node()
	if not node then return end
	local strNode
	if node:type() == "string" then
		strNode = node
	elseif node:type():find("string_content") then
		strNode = node:parent()
	elseif node:type() == "escape_sequence" then
		strNode = node:parent():parent()
	end
	if not strNode then return end

	local nodeText = vim.treesitter.get_node_text(strNode, 0)
	local row, startCol, _, endCol = strNode:range()
	local newText = ("(%s):format()"):format(nodeText)
	vim.api.nvim_buf_set_text(0, row, startCol, row, endCol, { newText })

	vim.api.nvim_win_set_cursor(0, { row + 1, endCol + 10 })
	vim.cmd.startinsert()
end, { desc = " Formatted String" })

--------------------------------------------------------------------------------

-- auto-comma for tables
vim.api.nvim_create_autocmd("TextChangedI", {
	desc = "User (buffer-specific): Set filetype to lua for TelescopeResults",
	buffer = 0,
	group = vim.api.nvim_create_augroup("lua-autocomma", { clear = true }),
	callback = function()
		local node = vim.treesitter.get_node()
		if node and node:type() == "table_constructor" then
			local line = vim.api.nvim_get_current_line()
			if line:find("^%s*[^,%s%-]$") then vim.api.nvim_set_current_line(line .. ",") end
		end
	end,
})
