local M = {}
--------------------------------------------------------------------------------

-- REQUIREMENTS
-- * `ts_ls` LSP
-- * nvim 0.10+
-- * (recommended) `biome` or `prettier` for formatted codeblocks
-- * (recommended) `TSInstall markdown markdown_inline` for better highlighting
-- * (recommended) `render-markdown.nvim` or `markview.nvim` for better highlighting

-- USAGE
-- Call `require("pretty-ts-error").select()` while on a line with a typescript
-- diagnostic. If there is more than one typescript diagnostic, select one.
-- (Replace `"pretty-ts-error"` with the location where this file is saved)

--------------------------------------------------------------------------------

---@param diag vim.Diagnostic
local function show(diag)
	-- open LSP float
	local height = math.min(#lines, vim.api.nvim_win_get_config(0).height - 2)
	local title = ("  %s %s "):format(diag.source, diag.code)
	local _bufnr, winid = vim.lsp.util.open_floating_preview(lines, "markdown", {
		close_events = { "CursorMoved", "CursorMovedI", "BufHidden", "LspDetach" },
		wrap = false,

		title = title,
		height = height,
	})
	-- FIX value above being ignored
	vim.api.nvim_win_set_config(winid, { title = title, height = height })
end

--------------------------------------------------------------------------------

function M.select()
	-- get diagnostics
	local row = vim.api.nvim_win_get_cursor(0)[1] - 1
	local diags = vim.diagnostic.get(0, { lnum = row })
	diags = vim.tbl_filter(function(d) return d.source == "typescript" end, diags)

	if #diags == 0 then
		vim.notify("No diagnostic found.", vim.log.levels.WARN, { icon = "", title = "ts_ls" })
		return
	elseif #diags == 1 then
		show(diags[1]) -- auto-select when only one
		return
	end

	vim.ui.select(diags, {
		prompt = " Select diagnostic: ",
		format_item = function(d) return d.message:sub(0, 30) end,
	}, function(selection)
		if selection then show(selection) end
	end)
end

--------------------------------------------------------------------------------
return M
