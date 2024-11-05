local M = {}

---@alias LspPosition { character: integer, line: integer }
---@alias LspReferenceRange { start: LspPosition, end: LspPosition }
---@alias RefjumpReference { range: LspReferenceRange, uri: string }

---@param ref_pos LspPosition
---@param current_line integer
---@param current_col integer
---@return boolean
local function reference_is_after_current_position(ref_pos, current_line, current_col)
	return ref_pos.line > current_line
		or (ref_pos.line == current_line and ref_pos.character > current_col)
end

---@param ref_pos LspPosition
---@param current_line integer
---@param current_col integer
---@return boolean
local function reference_is_before_current_position(ref_pos, current_line, current_col)
	return ref_pos.line < current_line
		or (ref_pos.line == current_line and ref_pos.character < current_col)
end

---Find n:th next reference in `references` from `current_position` where n is
---`count`. Search forward if `forward` is `true`, otherwise search backwards.
---@param references RefjumpReference[]
---@param forward boolean
---@param count integer
---@param current_position integer[]
---@return RefjumpReference
local function find_next_reference(references, forward, count, current_position)
	local current_line = current_position[1] - 1
	local current_col = current_position[2]

	local iter = forward and vim.iter(references) or vim.iter(references):rev()

	return iter
		:filter(function(ref)
			local ref_pos = ref.range.start
			if forward then
				return reference_is_after_current_position(ref_pos, current_line, current_col)
			else
				return reference_is_before_current_position(ref_pos, current_line, current_col)
			end
		end)
		:nth(count)
end

---@param next_reference RefjumpReference
local function jump_to(next_reference)
	local bufnr = vim.api.nvim_get_current_buf()
	local next_location = { uri = vim.uri_from_bufnr(bufnr), range = next_reference.range }

	vim.lsp.util.jump_to_location(next_location, "utf-16")
	vim.cmd("normal! zv") -- Open folds if the reference is inside a fold
end

---@param next_reference RefjumpReference
---@param forward boolean
---@param references RefjumpReference[]
local function jump_to_next_reference(next_reference, forward, references)
	-- If no reference is found, loop around
	if not next_reference then
		next_reference = forward and references[1] or references[#references]
	end

	if next_reference then
		jump_to(next_reference)
	else
		vim.notify("Could not find the next reference", vim.log.levels.WARN, { title = "LSP Jump" })
	end
end

---@param opts { forward: boolean }
function M.reference_jump_from(opts)
	local curPos = vim.api.nvim_win_get_cursor(0)
	opts = opts or { forward = true }

	local params = vim.lsp.util.make_position_params()

	-- We call `textDocument/documentHighlight` here instead of
	-- `textDocument/references` for performance reasons. The latter searches the
	-- entire workspace, but `textDocument/documentHighlight` only searches the
	-- current buffer, which is what we want.
	vim.lsp.buf_request(0, "textDocument/documentHighlight", params, function(err, refs, _, _)
		if err then
			vim.notify("LSP Error: " .. err.message, vim.log.levels.ERROR, { title = "LSP Jump" })
			return
		end
		if not refs or vim.tbl_isempty(refs) then return end

		table.sort(refs, function(a, b) return a.range.start.line < b.range.start.line end)

		local next_reference = find_next_reference(refs, opts.forward, 1, curPos)
		jump_to_next_reference(next_reference, opts.forward, refs)
	end)
end

return M
