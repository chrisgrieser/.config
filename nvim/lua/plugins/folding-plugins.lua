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
		event = "BufReadPost", -- later will not save folds
		opts = true,
	},
	{
		"jghauser/fold-cycle.nvim",
		keys = {
			{ "^", function() require("fold-cycle").close() end, desc = " Cycle-Close Folds" },
		},
	},
	{
		"kevinhwang91/nvim-ufo",
		dependencies = "kevinhwang91/promise-async",
		event = "BufReadPost", -- needed for folds to load properly
		keys = {
			{
				"zr",
				function() require("ufo").openFoldsExceptKinds { "comment" } end,
				desc = " 󱃄 Open All Folds except comments",
			},
			{ "zm", function() require("ufo").closeAllFolds() end, desc = " 󱃄 Close All Folds" },
			{
				"z1",
				function() require("ufo").closeFoldsWith(1) end,
				desc = " 󱃄 Close L1 Folds",
			},
			{
				"z2",
				function() require("ufo").closeFoldsWith(2) end,
				desc = " 󱃄 Close L2 Folds",
			},
			{
				"z3",
				function() require("ufo").closeFoldsWith(3) end,
				desc = " 󱃄 Close L3 Folds",
			},
			{
				"z4",
				function() require("ufo").closeFoldsWith(4) end,
				desc = " 󱃄 Close L4 Folds",
			},
		},
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
				-- INFO some filetypes only allow indent, some only LSP, some only
				-- treesitter. However, ufo only accepts two kinds as priority,
				-- therefore making this function necessary :/
				local lspWithOutFolding = { "markdown", "sh", "css", "html", "python" }
				if vim.tbl_contains(lspWithOutFolding, ft) then return { "treesitter", "indent" } end
				return { "lsp", "indent" }
			end,
			-- open opening the buffer, close these fold kinds
			-- use `:UfoInspect` to get available fold kinds from the LSP
			close_fold_kinds = { "imports" },
			open_fold_hl_timeout = 800,
			fold_virt_text_handler = foldTextFormatter,
		},
	},
}
