--------------------------------------------------------------------------------
local foldIcon = ""
local hlgroup = "NonText"
local function foldTextFormatter(virtText, lnum, endLnum, width, truncate)
	local newVirtText = {}
	local suffix = "  " .. foldIcon .. "  " .. tostring(endLnum - lnum)
	local sufWidth = vim.fn.strdisplaywidth(suffix)
	local targetWidth = width - sufWidth
	local curWidth = 0
	for _, chunk in ipairs(virtText) do
		local chunkText = chunk[1]
		local chunkWidth = vim.fn.strdisplaywidth(chunkText)
		if targetWidth > curWidth + chunkWidth then
			table.insert(newVirtText, chunk)
		else
			chunkText = truncate(chunkText, targetWidth - curWidth)
			local hlGroup = chunk[2]
			table.insert(newVirtText, { chunkText, hlGroup })
			chunkWidth = vim.fn.strdisplaywidth(chunkText)
			if curWidth + chunkWidth < targetWidth then
				suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
			end
			break
		end
		curWidth = curWidth + chunkWidth
	end
	table.insert(newVirtText, { suffix, hlgroup })
	return newVirtText
end

--------------------------------------------------------------------------------

return {
	{
		"chrisgrieser/nvim-origami",
		dev = true,
		init = function()
			vim.keymap.set("n", "h", function() require("origiami").h() end, { desc = "Origami h" })
		end,
		opts = true, -- required, if you use the default config
	},
	{
		"jghauser/fold-cycle.nvim",
		lazy = true, -- loaded by keymap
		opts = true,
	},
	{
		"kevinhwang91/nvim-ufo",
		dependencies = "kevinhwang91/promise-async",
		event = "BufReadPost",
		init = function()
			-- INFO fold commands usually change the foldlevel, which fixes folds, e.g.
			-- auto-closing them after leaving insert mode, however ufo does not seem to
			-- have equivalents for zr and zm because there is no saved fold level.
			-- Consequently, the vim-internal fold levels need to be disabled by setting
			-- them to 99
			vim.opt.foldlevel = 99
			vim.opt.foldlevelstart = 99
		end,
		opts = {
			provider_selector = function(_, ft, _)
				local lspWithOutFolding = { "markdown", "bash", "sh", "bash", "zsh", "css" }
				if vim.tbl_contains(lspWithOutFolding, ft) then
					return { "treesitter", "indent" }
				else
					return { "lsp", "indent" }
				end
			end,
			-- open opening the buffer, close these fold kinds
			-- use `:UfoInspect` to get available fold kinds from the LSP
			close_fold_kinds = { "imports" },
			open_fold_hl_timeout = 500,
			fold_virt_text_handler = foldTextFormatter,
		},
	},
}
