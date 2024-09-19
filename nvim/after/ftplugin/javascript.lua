local u = require("config.utils")
local abbr = require("config.utils").bufAbbrev
--------------------------------------------------------------------------------

vim.bo.commentstring = "// %s" -- add space

--------------------------------------------------------------------------------

-- ABBREVIATIONS

abbr("cosnt", "const")
abbr("local", "const")
abbr("--", "//")
abbr("~=", "!==")
abbr("elseif", "else if")
abbr("()", "() =>") -- quicker arrow function

--------------------------------------------------------------------------------

---open the next regex at https://regex101.com/
u.bufKeymap("n", "g/", function()
	vim.cmd.TSTextobjectSelect("@regex.outer")
	local notFound = vim.fn.mode():find("v")
	if not notFound then
		vim.notify("No regex found", nil, { title = "Regex101" })
		return
	end
	vim.cmd.normal { '"zy', bang = true }

	local regex, flags = vim.fn.getreg("z"):match("/(.*)/(%l*)")
	local data = {
		regex = regex,
		flags = flags,
		substitution = vim.api.nvim_get_current_line():match('%.replace ?%(/.*/.*, ?"(.-)"'),
		delimiter = "/",
		flavor = "javascript",
		testString = "",
	}

	vim.cmd.TSTextobjectSelect("@regex.inner") -- reselect for easier pasting
	require("rip-substitute.open-at-regex101").open(data)
end, { desc = " Open in regex101" })
