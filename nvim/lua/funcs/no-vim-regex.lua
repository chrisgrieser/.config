local M = {}
--------------------------------------------------------------------------------

-- TODO ranges
-- TODO flags


--------------------------------------------------------------------------------


-- iterate lines and replace
local function substitute(lines, toSearch, toReplace)
	local newBufferLines = {}
	for _, line in pairs(lines) do
		local newLine = line:gsub(toSearch, toReplace)
		table.insert(newBufferLines, newLine)
	end
	return newBufferLines
end

---main function running the substitution
---@param opts table
local function executeSubstitution(opts)
	local input = vim.split(opts.args, "/", { trimempty = true, plain = true })
	local toSearch = input[1]
	local toReplace = input[2]
	local bufferLines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local newBufferLines = substitute(bufferLines, toSearch, toReplace)
	vim.api.nvim_buf_set_lines(0, 0, -1, false, newBufferLines)
end


-- https://neovim.io/doc/user/map.html#%3Acommand-preview
local function previewFunc(opts, ns, preview_buf)
	if preview_buf then
		vim.notify("vim.opt.inccommand = 'split' has not been implemented yet", vim.log.levels.WARN)
		return
	end
	local input = vim.split(opts.args, "/", { trimempty = true, plain = true })
	local toSearch = input[1]
	local toReplace = input[2]

	local line1 = opts.line1
	local line2 = opts.line2
	local bufferLines = vim.api.nvim_buf_get_lines(0, line1 - 1, line2, false)

	substitute(bufferLines, opts)

	for i, line in ipairs(bufferLines) do
		local start_idx, end_idx = string.find(line, toSearch)
		if start_idx then
			vim.api.nvim_buf_add_highlight(0, ns, "Substitute", line1 + i - 2, start_idx - 1, end_idx)
		end
	end
	return 2 -- Return the value of the preview type
end

function M.setup()
	vim.api.nvim_create_user_command("S", executeSubstitution, {
		nargs = "?",
		range = "%",
		addr = "lines",
		preview = previewFunc,
	})
end

return M
