-- INFO `false` as third list items indicates that the second element is *not* 
-- exchanged with the first
local generalWords = {
	-- on/off
	{ "on", "off" },
	{ "yes", "no" },
	{ "y", "n" },
	{ "disable", "enable" },
	{ "disabled", "enabled" },
	{ "1", "0" },
	{ "true", "false" },

	-- opposites
	{ "show", "hide" },
	{ "min", "max" },
	{ "minimum", "maximum" },
	{ "increase", "decrease" },
	{ "increased", "decreased" },
	{ "always", "never" },
	{ "next", "previous" },
	{ "inner", "outer" },
	{ "before", "after" },
	{ "low", "high" },
	{ "dark", "light" },
	{ "first", "last" },
	{ "up", "down" },
	{ "right", "left" },
	{ "black", "white" },
	{ "red", "blue" },

	-- commonly switched between
	{ "variable", "constant" },
	{ "read", "write" },
	{ "warn", "error" },
	{ "and", "or" },

	-- comparisons
	{ "<", ">" },
	{ "<=", ">=" },
	{ "!=", "==" },

	-- units
	{ "years", "months", false },
	{ "months", "weeks", false },
	{ "weeks", "days", false },
	{ "days", "hours", false },
	{ "hours", "minutes", false },
	{ "minutes", "seconds", false },
	{ "mins", "secs" },
}

local filetypeSpecificWords = {
	css = {
		{ "padding", "margin" },
		{ "top", "bottom" },
		{ "relative", "absolute" },
		{ "width", "height" },
		-- most common css terms already included in general words
	},
	lua = {
		{ "==", "~=" },
		{ "nil", "{}" },
		{ "if", "elseif", false },
		{ "not", "", false },
		{ "elseif", "else", false },
		{ "else", "if", false },
		{ "function", "local function", false },
		{ "pairs", "ipairs" },
		{ "find", "match" },
		{ "Notify", "print", false }, -- hammerspoon specific
	},
	python = {
		{ "True", "False" },
	},
	javascript = {
		{ "null", "undefined", false },
		{ "if", "} else if", false },
		{ "else", "else if", false },
		{ "var", "const", false }, -- don't switch back to var!
		{ "const", "let" },
		{ "map", "forEach" },
		{ "replace", "replaceAll" },
		{ "===", "!==" },
		{ "&&", "||" },
		{ "return", "break" },
		{ "default", "case" }, -- switch-case statements
	},
	sh = {
		{ "lt", "gt" },
		{ "eq", "nq" },
		{ "&&", "||" },
		{ "if", "elif", false },
		{ "elif", "else", false },
		{ "else", "if", false },
		{ "echo", "print" },
		{ "exit", "return" },
	},

	-- filetypes to link to another filetype
	typescript = "javascript",
	bash = "sh",
	zsh = "sh",
	fish = "sh",
}

--------------------------------------------------------------------------------

local M = {}

---switches words under the cursor to their opposite, e.g. `true` to `false`
function M.switch()
	local ft = vim.bo.filetype
	local wordsToUse = {}

	if filetypeSpecificWords[ft] then
		-- filetype inherits words by other filetype
		if filetypeSpecificWords[ft] == "string" then ft = tostring(filetypeSpecificWords[ft]) end

		---@diagnostic disable-next-line: param-type-mismatch --- type match ensured above
		for _, v in pairs(filetypeSpecificWords[ft]) do
			table.insert(wordsToUse, v)
		end
	end

	-- INFO general words added *after* the filetype-specific words, so that the latter get priority
	for _, v in pairs(generalWords) do 
		table.insert(wordsToUse, v)
	end

	-- remove word-delimiters for <cword>
	local iskeywBefore = vim.opt.iskeyword:get()
	vim.opt.iskeyword:remove { "_", "-", "." }

	local cword = vim.fn.expand("<cword>")
	local cBigword = vim.fn.expand("<cWORD>")

	local alphaNumericUnderCursor = cBigword:find("[%a%d]")
	local word = alphaNumericUnderCursor and cword or cBigword

	local newWord = nil
	for _, pair in pairs(wordsToUse) do
		if word == pair[1] then
			newWord = pair[2]
			break
		elseif word == pair[2] and pair[3] ~= false then
			newWord = pair[1]
			break
		end
	end

	local switchWordFound = newWord ~= nil
	if switchWordFound then
		vim.fn.setreg("z", newWord)
		vim.cmd.normal { 'viw"zP', bang = true }
	else
		-- fallback to `~`
		vim.cmd.normal { "~", bang = true }
	end

	vim.opt.iskeyword = iskeywBefore
end

--------------------------------------------------------------------------------
return M
