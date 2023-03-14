local M = {}

---runs :normal natively with bang
local function normal(cmdStr) vim.cmd.normal { cmdStr, bang = true } end

--------------------------------------------------------------------------------

local words = {
	{ "true", "false" },
	{ "warn", "error" },
	{ "on", "off" },
	{ "yes", "no" },
	{ "disable", "enable" },
	{ "disabled", "enabled" },
	{ "show", "hide" },
	{ "right", "left" },
	{ "red", "blue" },
	{ "top", "bottom" },
	{ "min", "max" },
	{ "always", "never" },
	{ "width", "height" },
	{ "relative", "absolute" },
	{ "low", "high" },
	{ "dark", "light" },
	{ "before", "after" },
	{ "and", "or" },
	{ "next", "previous" },
	{ "read", "write" },
	{ "inner", "outer" },
}

local ftWords = {
	lua = {
		{ "if", "elseif", false },
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
		{ "if", "} else if", false },
		{ "else", "else if", false },
		{ "var", "const", false },
		{ "const", "let" },
		{ "replace", "replaceAll" },
	},
	sh = {
		{ "if", "elif", false },
		{ "elif", "else", false },
		{ "else", "if", false },
		{ "echo", "print" },
		{ "exit", "return" },
	},
}

--------------------------------------------------------------------------------

---switches words under the cursor from `true` to `false` and similar cases
function M.switch()
	local iskeywBefore = vim.opt.iskeyword:get()
	vim.opt.iskeyword:remove { "_", "-", "." }

	local ft = vim.bo.filetype
	local wordsToUse = words
	if ftWords[ft] then
		for _, item in pairs(ftWords) do
			table.insert(words, item)
		end
	end

	local cword = vim.fn.expand("<cword>")
	local newWord = nil
	for _, pair in pairs(words) do
		if cword == pair[1] then
			newWord = pair[2]
			break
		elseif cword == pair[2] and pair[3] ~= false then
			newWord = pair[1]
			break
		end
	end

	if newWord then
		vim.fn.setreg("z", newWord)
		normal([[viw"zP]])
	else
		vim.notify("Word under cursor cannot be switched.", vim.log.levels.WARN)
	end

	vim.opt.iskeyword = iskeywBefore
end

--------------------------------------------------------------------------------
return M
