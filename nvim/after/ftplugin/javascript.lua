local abbr = require("config.utils").bufAbbrev
local bkeymap = require("config.utils").bufKeymap
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

bkeymap({ "n", "x" }, "<D-s>", function()
	vim.lsp.buf.format()
	-- FIX manually close folds PENDING https://github.com/biomejs/biome/issues/4393
	vim.defer_fn(function() require("ufo").openFoldsExceptKinds { "comment", "imports" } end, 500)
end, { desc = "󰒕 LSP Format & close some folds" })

bkeymap("n", "<leader>ft", function()
	vim.lsp.buf.code_action {
		filter = function(a) return a.title == "Convert to template string" end,
		apply = true,
	}
end, { desc = "󰛦 Convert to Template String" })

---open the next regex at https://regex101.com/
bkeymap("n", "g/", function()
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
