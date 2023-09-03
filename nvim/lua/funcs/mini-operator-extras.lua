---@diagnostic disable: inject-field
-- used solely for mini.operators
local M = {}
local autocmd = vim.api.nvim_create_autocmd
--------------------------------------------------------------------------------

-- INFO some repl-cmds automatically print the last line, so they do not
-- require a printer command
local evalCmds = {
	sh = { repl = "zsh -c" },
	python = { repl = "python3 -c", printer = "print(%s)" },
	applescript = { repl = "osascript -l AppleScript -e" },
	javascript = { repl = "osascript -l JavaScript -e" }, -- Apple's JXA
	typescript = { repl = "node -e", printer = "console.log(%s)" },
}

local function dedent()
	
end

-- run as `init` for mini.operators
function M.filetypeSpecificEval()
	autocmd("FileType", {
		pattern = vim.tbl_keys(evalCmds),
		callback = function(ctx)
			local ft = ctx.match
			local repl = evalCmds[ft].repl
			local printer = evalCmds[ft].printer

			local evalFunc = function(content)
				local inputLines = vim.deepcopy(content.lines)

				if printer then
					local lastLine = table.remove(content.lines)
					local printCmd = printer:match("^%w+")
					if not (vim.startswith(lastLine, printCmd)) then lastLine = printer:format(lastLine) end
					table.insert(content.lines, lastLine)
				end

				-- fix python not being able to read unindented lines
				if ft == "python" then 
					content.lines = vim.tbl_map(function (line)
						local unindentedLines = line:gsub("^%s*", "")
						return unindentedLines
					end, content.lines)
				end

				local lines = table.concat(content.lines, "\n")

				local shellCmd = repl .. " '" .. lines:gsub("'", "\\'") .. "'"
				local evaluatedOut = vim.fn.system(shellCmd):gsub("\n$", "")
				vim.notify(evaluatedOut)
				return inputLines -- do not modify original lines
			end

			-- DOCS https://github.com/echasnovski/mini.operators/blob/main/doc/mini-operators.txt#L214
			local conf = { evaluate = { func = evalFunc } }
			vim.b.minioperators_config = vim.b.minioperators_config
					and vim.tbl_deep_extend("force", conf, vim.b.minioperators_config)
				or conf
		end,
	})
end

--------------------------------------------------------------------------------
-- https://github.com/echasnovski/mini.nvim/issues/439#issuecomment-1683665986

-- 1. output lines as notification instead of back into the buffer
-- 2. if in hammerspoon repo, evaluate hammerspoon-lua instead
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
-- filetype-specific multiply-transformations

local multiplyFuncs = {}

---@param lines string[]
---@return string[]
function multiplyFuncs.css(lines)
	if #lines ~= 1 then return lines end
	local line = lines[1]

	if line:find("top:") then
		line = line:gsub("top:", "bottom:")
	elseif line:find("bottom:") then
		line = line:gsub("bottom:", "top:")
	end
	if line:find("right:") then
		line = line:gsub("right:", "left:")
	elseif line:find("left:") then
		line = line:gsub("left:", "right:")
	end
	if line:find("dark:") then
		line = line:gsub("dark:", "light:")
	elseif line:find("light:") then
		line = line:gsub("light:", "dark:")
	end
	-- %s condition to avoid matching line-height, border-width, etc
	if line:find("%sheight:") then
		line = line:gsub("height:", "width:")
	elseif line:find("%swidth:") then
		line = line:gsub("width:", "height:")
	end
	if line:find("margin:") then
		line = line:gsub("margin:", "padding:")
	elseif line:find("padding:") then
		line = line:gsub("padding:", "margin:")
	end

	return { line }
end

---@param lines string[]
---@return string[]
function multiplyFuncs.lua(lines)
	if #lines ~= 1 then return lines end
	local line = lines[1]

	if line:find("^%s*if.+then%s*$") then line = line:gsub("^(%s*)if", "%1elseif") end

	return { line }
end

---@param lines string[]
---@return string[]
function multiplyFuncs.sh(lines)
	if #lines ~= 1 then return lines end
	local line = lines[1]

	if line:find("^%s*if.+then$") then line = line:gsub("^(%s*)if", "%1elif") end

	return { line }
end

---@param lines string[]
---@return string[]
function multiplyFuncs.javascript(lines)
	if #lines ~= 1 then return lines end
	local line = lines[1]

	if line:find("^%s*if.+{$") then line = line:gsub("^(%s*)if", "%1} else if") end

	return { line }
end

---@param lines string[]
---@return string[]
function multiplyFuncs.python(lines)
	if #lines ~= 1 then return lines end
	local line = lines[1]

	if line:find("^%s*if.+:$") then line = line:gsub("^(%s*)if", "%1elif") end

	return { line }
end

---@param lines string[]
---@return string[]
function multiplyFuncs.typescript(lines) return multiplyFuncs.javascript(lines) end

function M.filetypeSpecificMultiply()
	autocmd("FileType", {
		pattern = vim.tbl_keys(multiplyFuncs),
		callback = function(ctx)
			local ft = ctx.match

			local conf = {
				multiply = {
					func = function(content) return multiplyFuncs[ft](content.lines) end,
				},
			}
			vim.b.minioperators_config = vim.b.minioperators_config
					and vim.tbl_deep_extend("force", conf, vim.b.minioperators_config)
				or conf
		end,
	})
end

--------------------------------------------------------------------------------
return M
