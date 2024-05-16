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

---dedent lines, mostly for python REPL
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
					-- trailing ; makes console.log invalid
					if ft == "javascript" or ft == "typescript" then
						lastLine = vim.trim(lastLine):gsub(";$", "")
					end

					local printCmd = printer:match("^%w+")
					if not (vim.startswith(lastLine, printCmd)) then
						lastLine = printer:format(lastLine)
					end
					table.insert(inputLines, lastLine)
				end

				local lines = table.concat(inputLines, "\n")
				local shellCmd = repl .. ' "' .. lines:gsub('"', '\\"') .. '"'
				local evaluatedOut = vim.fn.system(shellCmd):gsub("\n$", "")
				u.notify("Eval", evaluatedOut)
				return originalLines -- do not modify original lines
			end

			-- DOCS https://github.com/echasnovski/mini.operators/blob/main/doc/mini-operators.txt#L214
			local conf = { evaluate = { func = evalFunc } }
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
	local parentDir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
	local MiniOperators = require("mini.operators")

	if parentDir:find("hammerspoon") then
		local lines = table.concat(content.lines, "\n"):gsub('"', '\\"')
		-- stylua: ignore
		local hsApplescript = ('tell application "Hammerspoon" to execute lua code "hs.alert(hs.inspect(%s))"'):format(lines)
		vim.system { "osascript", "-e", hsApplescript }
	else
		local output = MiniOperators.default_evaluate_func(content)
		u.notify("Eval", table.concat(output, "\n"))
	end

	return input_lines
end

--------------------------------------------------------------------------------
-- filetype-specific multiply-transformations

---@param ft string
---@param line string
---@return string
local function lineTransform(ft, line)
	if ft == "css" then
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
	elseif ft == "javascript" or ft == "typescript" then
		if line:find("^%s*if.+{$") then line = line:gsub("^(%s*)if", "%1} else if") end
	elseif ft == "lua" then
		if line:find("^%s*if.+then%s*$") then line = line:gsub("^(%s*)if", "%1elseif") end
	elseif ft == "sh" then
		if line:find("^%s*if.+then$") then line = line:gsub("^(%s*)if", "%1elif") end
	elseif ft == "python" then
		if line:find("^%s*if.+:$") then line = line:gsub("^(%s*)if", "%1elif") end
	end

	return line
end

-- ensures the cursor stays in the same column after duplication
-- HACK needs to work with `defer_fn`, since the transformer function is
-- called only before the multiplication operation
local function moveCursorToValue(content)
	local rowBefore = vim.api.nvim_win_get_cursor(0)[1]

	vim.defer_fn(function()
		local rowAfter = vim.api.nvim_win_get_cursor(0)[1]
		local line = vim.api.nvim_get_current_line()
		local _, valuePos = line:find("[:=] ? %S") -- find value
		local _, _, fieldPos = line:find("@.-()%w+$") -- luadoc or jsdoc
		local gotoPos = fieldPos or valuePos
		if rowBefore ~= rowAfter and gotoPos then
			vim.api.nvim_win_set_cursor(0, { rowAfter, gotoPos - 1 })
		end
	end, 1)
	return content.lines
end

local function filetypeSpecificMultiply()
	autocmd("FileType", {
		pattern = { "css", "javascript", "typescript", "lua", "sh", "python" },
		callback = function(ctx)
			local ft = ctx.match

			vim.b["minioperators_config"] = {
				multiply = {
					func = function(content)
						moveCursorToValue(content)
						content.lines[1] = lineTransform(ft, content.lines[1])
						return content.lines
					end,
				},
			}
		end,
	})
end

--------------------------------------------------------------------------------

return {
	"echasnovski/mini.operators",
	keys = {
		{ "s", desc = "󰅪 Substitute Operator" }, -- in visual mode, `s` surrounds
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
		replace = { prefix = "", reindent_linewise = false }, -- substitute
		multiply = { prefix = "w", func = moveCursorToValue }, -- duplicate
		exchange = { prefix = "sx", reindent_linewise = false },
		sort = { prefix = "sy" },
		evaluate = { prefix = "#", func = luaEval },
	},
	init = function()
		-- in `init`, so autocmds are set up before the plugin is loaded
		filetypeSpecificMultiply()
		filetypeSpecificEval()
	end,
	config = function(_, opts)
		require("mini.operators").setup(opts)

		-- Do not set `substitute` mapping for visual mode, since we use `s` for
		-- `surround` there, and `p` effectively already substitutes
		require("mini.operators").make_mappings(
			"replace",
			{ textobject = "s", line = "ss", selection = "" }
		)
	end,
}
