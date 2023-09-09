local autocmd = vim.api.nvim_create_autocmd
local u = require("config.utils")
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

---@param lines string[]
---@return string[] dedentedLines
local function dedent(lines)
	local indentAmounts = vim.tbl_map(function(line) return #(line:match("^%s*")) end, lines)
	local smallestIndent = math.min(unpack(indentAmounts))
	local dedentedLines = vim.tbl_map(function(line) return line:sub(smallestIndent + 1) end, lines)
	return dedentedLines
end

-- run as `init` for mini.operators
local function filetypeSpecificEval()
	autocmd("FileType", {
		pattern = vim.tbl_keys(evalCmds),
		callback = function(ctx)
			local ft = ctx.match
			local repl = evalCmds[ft].repl
			local printer = evalCmds[ft].printer

			local evalFunc = function(content)
				local originalLines = vim.deepcopy(content.lines)
				local inputLines = vim.deepcopy(content.lines)
				if ft == "python" then inputLines = dedent(inputLines) end

				if printer then
					local lastLine = table.remove(inputLines)
					local printCmd = printer:match("^%w+")
					if not (vim.startswith(lastLine, printCmd)) then lastLine = printer:format(lastLine) end
					table.insert(inputLines, lastLine)
				end

				local lines = table.concat(inputLines, "\n")
				local shellCmd = repl .. " '" .. lines:gsub("'", "\\'") .. "'"
				local evaluatedOut = vim.fn.system(shellCmd):gsub("\n$", "")
				u.notify("Eval", evaluatedOut)
				return originalLines -- do not modify original lines
			end

			-- DOCS https://github.com/echasnovski/mini.operators/blob/main/doc/mini-operators.txt#L214
			local conf = { evaluate = { func = evalFunc } }
			---@diagnostic disable-next-line: inject-field
			vim.b.minioperators_config = vim.b.minioperators_config
					and vim.tbl_deep_extend("force", conf, vim.b.minioperators_config)
				or conf
		end,
	})
end

-- 1. output lines as notification instead of back into the buffer
-- 2. if in hammerspoon repo, evaluate hammerspoon-lua instead
---@param content object
---@return string[] lines
local function luaEval(content)
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
		u.notify("Eval", table.concat(output, "\n"))
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

local function filetypeSpecificMultiply()
	autocmd("FileType", {
		pattern = vim.tbl_keys(multiplyFuncs),
		callback = function(ctx)
			local ft = ctx.match

			local conf = {
				multiply = {
					func = function(content) return multiplyFuncs[ft](content.lines) end,
				},
			}
			---@diagnostic disable-next-line: inject-field
			vim.b.minioperators_config = vim.b.minioperators_config
					and vim.tbl_deep_extend("force", conf, vim.b.minioperators_config)
				or conf
		end,
	})
end

--------------------------------------------------------------------------------
return {
	{
		"echasnovski/mini.operators",
		keys = {
			{ "s", mode = { "n", "x" }, desc = "󰅪 Substitute Operator" },
			{ "w", mode = { "n", "x" }, desc = "󰅪 Multiply Operator" },
			{ "#", mode = { "n", "x" }, desc = "󰅪 Evaluate Operator" },
			{ "sy", mode = { "n", "x" }, desc = "󰅪 Sort Operator" },
			{ "sx", mode = { "n", "x" }, desc = "󰅪 Exchange Operator" },
			{ "S", "s$", desc = "󰅪 Substitute to EoL", remap = true },
			{ "W", "w$", desc = "󰅪 Multiply to EoL", remap = true },
			{ "'", "#$", desc = "󰅪 Evaluate to EoL", remap = true },
			{ "sX", "sx$", desc = "󰅪 Exchange to EoL", remap = true },
			{ "sY", "sy$", desc = "󰅪 Sort to EoL", remap = true },
		},
		opts = {
			replace = { prefix = "s", reindent_linewise = true },
			multiply = { prefix = "w" },
			exchange = { prefix = "sx", reindent_linewise = true },
			sort = { prefix = "sy" },
			evaluate = { prefix = "#", func = luaEval },
		},
		init = function()
			filetypeSpecificMultiply()
			filetypeSpecificEval()
		end,
	},
}
