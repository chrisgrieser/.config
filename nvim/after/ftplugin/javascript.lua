local abbr = require("config.utils").bufAbbrev
local bkeymap = require("config.utils").bufKeymap
--------------------------------------------------------------------------------

vim.bo.commentstring = "// %s" -- add space

--------------------------------------------------------------------------------

-- ABBREVIATIONS
abbr("cosnt", "const")
abbr("local", "const")
abbr("elseif", "else if")
abbr("--", "//")
abbr("~=", "!==")
abbr("()", "() =>")

--------------------------------------------------------------------------------

-- pretty ts error
bkeymap(
	"n",
	"<leader>D",
	function() require("personal-plugins.pretty-ts-error").prettyTsError() end,
	{ desc = " Pretty ts_ls diagnostic" }
)

-- open the next regex at https://regex101.com/
bkeymap("n", "g/", function()
	-- GUARD
	local ok, tsSelect = pcall(require, "nvim-treesitter-textobjects.select")
	if not (ok and tsSelect) then
		vim.notify("`nvim-treesitter-textobjects` not installed.", vim.log.levels.WARN)
		return
	end
	tsSelect.select_textobject("@regex.outer", "textobjects")
	local notFound = vim.fn.mode():find("v") -- if a textobj is found, switches to visual mode
	if not notFound then
		vim.notify("No regex found", nil, { title = "Regex101" })
		return
	end

	-- get regex via temp register `z`
	vim.cmd.normal { '"zy', bang = true }
	local regex, flags = vim.fn.getreg("z"):match("/(.*)/(%l*)")
	local line = vim.api.nvim_get_current_line()
	local substitution = line:match("%.replace ?%(/.*/.*, ?'(.-)'")
		or line:match('%.replace ?%(/.*/.*, ?"(.-)"')

	local data = {
		regex = regex,
		flags = flags,
		substitution = substitution,
		delimiter = "/",
		flavor = "javascript",
		testString = "",
	}

	tsSelect.select_textobject("@regex.inner", "textobjects") -- reselect for easier pasting
	require("rip-substitute.open-at-regex101").open(data)
end, { desc = " Open in regex101" })

--------------------------------------------------------------------------------

