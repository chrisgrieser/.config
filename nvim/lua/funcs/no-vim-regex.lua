local M = {}
--------------------------------------------------------------------------------

-- TODO preview https://neovim.io/doc/user/map.html#%3Acommand-preview

---main function running the substitution
---@param opts table
local function substitute(opts)
	local input = vim.split(opts.args, "/", { trimempty = true, plain = true })
	local toSearch = input[1]
	local toReplace = input[2]
	local bufferLines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

	local newBufferLines = {}
	for _, line in pairs(bufferLines) do
		local newLine = line:gsub(toSearch, toReplace)
		table.insert(newBufferLines, newLine)	
	end	
	vim.api.nvim_buf_set_lines(0, 0, -1, true, newBufferLines)
end

function M.setup() vim.api.nvim_create_user_command("S", substitute, { nargs = 1 }) end

return M
