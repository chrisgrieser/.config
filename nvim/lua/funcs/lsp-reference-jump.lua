local M = {}

---@alias Position { character: integer, line: integer }
--------------------------------------------------------------------------------

---@param refs Position[]
---@param dir? "next"|"prev" default: "next"
---@return Position
local function findNextRef(refs, dir)
	local curLine, curCol = unpack(vim.api.nvim_win_get_cursor(0))
	curLine = curLine - 1 -- vim is 1-indexed

	table.sort(refs, function(a, b) return a.line < b.line end)
	local iter = dir == "prev" and vim.iter(refs):rev() or vim.iter(refs)

	local nextRef = iter
		:filter(function(ref)
			if dir == "prev" then
				return ref.line < curLine or (ref.line == curLine and ref.character < curCol)
			else
				return ref.line > curLine or (ref.line == curLine and ref.character > curCol)
			end
		end)
		:nth(1)

	-- if no reference found, loop around
	if not nextRef then nextRef = dir == "prev" and refs[#refs] or refs[1] end
	return nextRef
end

---@param dir? "next"|"prev" default: "next"
function M.jump(dir)
	local params = vim.lsp.util.make_position_params()

	-- PERF `textDocument/documentHighlight` only searches the current buffer, as
	-- opposed to `textDocument/references` which searches the entire workspace.
	-- Since we jump only in the current file, the former is enough.
	vim.lsp.buf_request(0, "textDocument/documentHighlight", params, function(err, refs, _, _)
		if err then
			vim.notify("LSP Error: " .. err.message, vim.log.levels.ERROR, { title = "LSP Jump" })
			return
		end
		if not refs or vim.tbl_isempty(refs) then return end

		-- we only need the start position
		refs = vim.tbl_map(function(ref) return ref.range.start end, refs) ---@cast refs Position[]

		local nextRef = findNextRef(refs, dir)
		vim.api.nvim_win_set_cursor(0, { nextRef.line + 1, nextRef.character })
		vim.cmd.normal { "zv", bang = true } -- open folds if inside a fold
	end)
end

--------------------------------------------------------------------------------
return M
