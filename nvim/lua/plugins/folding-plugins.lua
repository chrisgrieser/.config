--------------------------------------------------------------------------------
local foldIcon = ""
--------------------------------------------------------------------------------

-- https://github.com/kevinhwang91/nvim-ufo#minimal-configuration
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
	table.insert(newVirtText, { suffix, "MoreMsg" })
	return newVirtText
end

--------------------------------------------------------------------------------

return {
	{
		"jghauser/fold-cycle.nvim",
		lazy = true, -- loaded by keymap
		opts = true,
	},
	{
		"kevinhwang91/nvim-ufo",
		dependencies = "kevinhwang91/promise-async",
		event = "BufReadPost",
		opts = {
			provider_selector = function() return { "lsp", "indent" } end,
			open_fold_hl_timeout = 500,
			fold_virt_text_handler = foldTextFormatter,
			preview = {
				win_config = {
					border = BorderStyle,
					winblend = 1,
					maxheight = 10,
				},
			},
		},
	},
}
