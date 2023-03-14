
local generalWords = {
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

-- INFO `false` indicates that the second element is not exchanged backwards
local filetypeSpecificWords = {
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
	-- filetypes to link to another filetype
	typescript = "javascript",
	bash = "sh",
	zsh = "sh",
}

--------------------------------------------------------------------------------

local M = {}

---switches words under the cursor to their opposite, e.g. `true` to `false`
function M.switch()

	local ft = vim.bo.filetype
	local wordsToUse

	-- filetype inherits word by other filetype
	if (filetypeSpecificWords[ft]) == "string" then ft = tostring(filetypeSpecificWords[ft]) end

	if filetypeSpecificWords[ft] then
		wordsToUse = vim.tbl_extend("force", generalWords, filetypeSpecificWords[ft])
	else
		wordsToUse = generalWords
	end

	-- remove keywords for <cword>
	local iskeywBefore = vim.opt.iskeyword:get()
	vim.opt.iskeyword:remove { "_", "-", "." }
	local cword = vim.fn.expand("<cword>")

	local newWord = nil
	for _, pair in pairs(wordsToUse) do
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
		vim.cmd.normal { 'viw"zP', bang = true }
	else
		vim.notify("Word under cursor cannot be switched.", vim.log.levels.WARN)
	end

	vim.opt.iskeyword = iskeywBefore
end

--------------------------------------------------------------------------------
return M
