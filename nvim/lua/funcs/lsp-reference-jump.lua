local M = {}

---@alias LspPosition { character: integer, line: integer }
---@alias LspReference { range: { start: LspPosition, end: LspPosition }, uri: string }
--------------------------------------------------------------------------------

---@param refs LspReference[]
---@param backwards boolean|nil
---@return LspReference
local function findNextRef(refs, backwards)
	local curLine, curCol = unpack(vim.api.nvim_win_get_cursor(0))
	curLine = curLine - 1 -- vim is 1-indexed

	table.sort(refs, function(a, b) return a.range.start.line < b.range.start.line end)
	local iter = backwards and vim.iter(refs):rev() or vim.iter(refs)

	local nextRef = iter
		:filter(function(ref)
			local refPos = ref.range.start
			if backwards then
				-- reference is before current position
				return refPos.line < curLine or (refPos.line == curLine and refPos.character < curCol)
			else
				-- reference is after current position
				return refPos.line > curLine or (refPos.line == curLine and refPos.character > curCol)
			end
		end)
		:nth(1)
	return nextRef
end

---@param dir? "next"|"prev"
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

		local nextRef = findNextRef(refs, dir == "prev")

		-- if no reference is found, loop around
		if not nextRef then nextRef = dir == "prev" and refs[#refs] or refs[1] end

		local pos = nextRef.range.start
		vim.api.nvim_win_set_cursor(0, { pos.line + 1, pos.character })
		vim.cmd.normal { "zv", bang = true } -- open folds if inside a fold
	end)
end

--------------------------------------------------------------------------------
return M
