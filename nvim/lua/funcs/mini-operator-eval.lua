-- used solely for mini.operators
local M = {}
--------------------------------------------------------------------------------

-- INFO some repl-cmds automatically print the last line, so they do not
-- require a printer command
local cmds = {
	sh = { repl = "zsh -c" },
	python = { repl = "python3 -c", printer = "print(%s)" },
	applescript = { repl = "osascript -l AppleScript -e" },
	javascript = { repl = "osascript -l JavaScript -e" }, -- Apple's JXA
	typescript = { repl = "node -e", printer = "console.log(%s)" },
}

-- run as `init` for mini.operators
function M.filetypeSpecificEval()
	vim.api.nvim_create_autocmd("FileType", {
		pattern = vim.tbl_keys(cmds),
		callback = function(ctx)
			local ft = ctx.match
			local repl = cmds[ft].repl
			local printer = cmds[ft].printer

			local evalFunc = function(content)
				local inputLines = vim.deepcopy(content.lines)

				if printer then
					local lastLine = table.remove(content.lines)
					local printCmd = printer:match("^%w+")
					if not (vim.startswith(lastLine, printCmd)) then lastLine = printer:format(lastLine) end
					table.insert(content.lines, lastLine)
				end
				local lines = table.concat(content.lines, "\n")

				local shellCmd = repl .. " '" .. lines:gsub("'", "\\'") .. "'"
				local evaluatedOut = vim.fn.system(shellCmd):gsub("\n$", "")
				vim.notify(evaluatedOut)
				return inputLines -- do not modify original lines
			end

			-- DOCS https://github.com/echasnovski/mini.operators/blob/main/doc/mini-operators.txt#L214
			vim.b.minioperators_config = { evaluate = { func = evalFunc } }
		end,
	})
end

--------------------------------------------------------------------------------
-- https://github.com/echasnovski/mini.nvim/issues/439#issuecomment-1683665986

---@param content object
---@return string[] lines
function M.luaEval(content)
	local input_lines = vim.deepcopy(content.lines) -- Currently needed as `content` is modified, which it shouldn't
	local parentDir = vim.fn.expand("%:p:h")
	local MiniOperators = require("mini.operators")

	if parentDir:find("hammerspoon") then
		local lines = table.concat(content.lines, "\n"):gsub('"', '\\"')
		-- stylua: ignore
		local hsApplescript = ('tell application "Hammerspoon" to execute lua code "hs.alert(%s)"'):format(lines)
		vim.fn.system { "osascript", "-e", hsApplescript }
	else
		local output = MiniOperators.default_evaluate_func(content)
		vim.notify(table.concat(output, "\n"))
	end

	return input_lines
end
--------------------------------------------------------------------------------
return M
