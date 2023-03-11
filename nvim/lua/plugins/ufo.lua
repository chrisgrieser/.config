
local foldIcon = "  "

return {
	"kevinhwang91/nvim-ufo",
	dependencies = "kevinhwang91/promise-async",
	lazy = false, -- can't lazy load, or folds from previous sessions are not opened
	config = function()
		local ufo = require("ufo")
		ufo.setup {
			provider_selector = function(bufnr, filetype, buftype) ---@diagnostic disable-line: unused-local
				return { "lsp", "treesitter" } -- Use lsp and treesitter as fallback
			end,
			-- open_fold_hl_timeout = 0,
			fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
				-- https://github.com/kevinhwang91/nvim-ufo#minimal-configuration
				local newVirtText = {}
				local suffix = foldIcon .. " " .. tostring(endLnum - lnum)
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
			end,
		}

		-- Using ufo provider need remap `zR` and `zM`
		vim.keymap.set("n", "zR", ufo.openAllFolds, {desc = " Open all folds"}) 
		vim.keymap.set("n", "zM", ufo.closeAllFolds, {desc = " Close all folds"})

		-- fold settings required for UFO
		vim.opt.foldenable = true
		vim.opt.foldlevel = 99
		vim.opt.foldlevelstart = 99
	end,
}
