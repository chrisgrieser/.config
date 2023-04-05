local M = {}
--------------------------------------------------------------------------------

-- TODO preview https://neovim.io/doc/user/map.html#%3Acommand-preview
-- TODO ranges

---main function running the substitution
---@param opts table
local function substitute(opts)
	local input = vim.split(opts.args, "/", { trimempty = true, plain = true })
	local toSearch = input[1]
	local toReplace = input[2]
	local flags = input[3] -- TODO implement flags
	if flags == nil then flags = {} end
	local bufferLines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

	-- iterate lines and replace
	local newBufferLines = {}
	for _, line in pairs(bufferLines) do
		local newLine = line:gsub(toSearch, toReplace)
		table.insert(newBufferLines, newLine)
	end

	vim.api.nvim_buf_set_lines(0, 0, -1, false, newBufferLines)
end

local function previewFunc(opts, preview_ns, preview_buf)
	if preview_buf
	local line1 = opts.line1
	local line2 = opts.line2
	local lines = vim.api.nvim_buf_get_lines(0, line1 - 1, line2, false)
	for i, line in ipairs(lines) do
		local start_idx, end_idx = string.find(line, "%s+$")
		if start_idx then
			-- Highlight the match
			vim.api.nvim_buf_add_highlight(
				0,
				preview_ns,
				"Substitute",
				line1 + i - 2,
				start_idx - 1,
				end_idx
			)
		end
	end
	-- Return the value of the preview type
	return 2
end

function M.setup()
	vim.api.nvim_create_user_command("S", substitute, {
		nargs = 1,
		range = "%",
		addr = "lines",
		preview = previewFunc,
	})
end

return M
