return {
	{ 
		"jghauser/fold-cycle.nvim",
		opts = true,
		init = function()
			-- stylua: ignore
			vim.keymap.set("n", "<", function() require("fold-cycle").close() end, { nowait = true, desc = " Cycle-Close Fold" })
		end,
	},
	{ 
		"anuvyklack/pretty-fold.nvim",
		event = "VeryLazy",
		opts = {
			process_comment_signs = false,
			fill_char = " ",
		},
	},
	{ 
		"kevinhwang91/nvim-ufo",
		enabled = false,
		dependencies = "kevinhwang91/promise-async",
		event = "BufReadPost",
		init = function()
			-- stylua: ignore start
			vim.keymap.set("n", "zR", function() require("ufo").openAllFolds() end, { desc = "  Open all folds" })
			vim.keymap.set("n", "zM", function() require("ufo").closeAllFolds() end, { desc = "  Close all folds" })

			vim.opt.foldlevel = 99
			vim.opt.foldlevelstart = 99
			-- stylua: ignore end
		end,
		opts = {
			-- Use lsp, and indent as fallback
			provider_selector = function() return { "lsp", "indent" } end,
			open_fold_hl_timeout = 500,
			fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
				-- https://github.com/kevinhwang91/nvim-ufo#minimal-configuration
				local foldIcon = ""
				local newVirtText = {}
				local suffix = " " .. foldIcon .. "  " .. tostring(endLnum - lnum)
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
		},
	},
}
