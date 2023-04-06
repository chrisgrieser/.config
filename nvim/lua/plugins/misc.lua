return {
	{ -- preview markdown
		"iamcco/markdown-preview.nvim",
		ft = "markdown",
		build = "cd app && npm install",
	},
	{
		"mbbill/undotree",
		cmd = "UndotreeToggle",
		init = function()
			vim.g.undotree_WindowLayout = 3
			vim.g.undotree_DiffpanelHeight = 8
			vim.g.undotree_ShortIndicators = 1
			vim.g.undotree_SplitWidth = 30
			vim.g.undotree_DiffAutoOpen = 0
			vim.g.undotree_SetFocusWhenToggle = 1
			vim.g.undotree_DiffCommand = "delta"
			vim.g.undotree_HelpLine = 1
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "undotree",
				callback = function()
					vim.keymap.set("n", "<D-w>", ":UndotreeToggle<CR>", { buffer = true })
					vim.opt_local.listchars:append("space: ")
				end,
			})
		end,
	},
	{ -- Folding
		"fold-cycle.nvim",
		event = "VeryLazy",
		opts = true,
	},
	{ -- Folding
		"fold-cycle.nvim",
		event = "VeryLazy",
		opts = true,
	},
	{ -- Folding (disabled)
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
