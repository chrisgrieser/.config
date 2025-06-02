-- HACK For plugins using backdrop-like effects, there is some winblend bug,
-- which causes the underlines to be displayed in ugly red. We fix this by
-- temporarily disabling the underline effects set.
local function toggleUnderlines()
	local change = vim.bo.buftype == "" and "underline" or "none"

	---INFO not using `api.nvim_set_hl` yet as it overwrites a group instead of updating it
	vim.cmd.highlight("@markup.link.url gui=" .. change)
	vim.cmd.highlight("@markup.link.url.markdown_inline gui=" .. change)
	vim.cmd.highlight("@string.special.url.comment gui=" .. change)
	vim.cmd.highlight("@string.special.url.html gui=" .. change)
	vim.cmd.highlight("Underlined gui=" .. change)

	vim.api.nvim_set_hl(0, "LspReferenceWrite", { underdashed = vim.bo.buftype == "" })
	vim.api.nvim_set_hl(0, "LspReferenceRead", { underdotted = vim.bo.buftype == "" })
end

vim.api.nvim_create_autocmd({ "WinEnter", "FileType" }, {
	desc = "User: FIX underlines for backdrop",
	callback = function(ctx)
		-- Dressing/snacks need to be detected separately, as they use `noautocmd`
		local ft = ctx.match
		if ctx.event == "WinEnter" or ft == "snacks_input" then vim.defer_fn(toggleUnderlines, 1) end
	end,
})
