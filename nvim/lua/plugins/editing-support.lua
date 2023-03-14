return {
	-- NAVIGATION
	{ "bkad/CamelCaseMotion", event = "BufReadPost" },
	{
		"rhysd/clever-f.vim",
		keys = { "f", "F", "t", "T" },
		init = function()
			vim.g.clever_f_mark_direct = 1 -- essentially quickscope
			vim.g.clever_f_chars_match_any_signs = " " -- space matches special chars
		end,
	},
	{ -- display line numbers while going to a line with `:`
		"nacro90/numb.nvim",
		keys = ":",
		config = function() require("numb").setup() end,
	},

	-----------------------------------------------------------------------------

	{ "Darazaki/indent-o-matic" }, -- automatically set right indent for file
	{ "chrisgrieser/nvim-various-textobjs", dev = true, lazy = true },
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		event = "BufEnter",
		dependencies = "nvim-treesitter/nvim-treesitter",
	},
	{
		"nvim-treesitter/nvim-treesitter-refactor",
		event = "BufEnter",
		dependencies = "nvim-treesitter/nvim-treesitter",
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/nvim-cmp",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			local npairs = require("nvim-autopairs")
			local rule = require("nvim-autopairs.rule")
			local isNodeType = require("nvim-autopairs.ts-conds").is_ts_node

			npairs.setup { check_ts = true } -- use treesitter

			npairs.add_rules {
				-- auto-pair <> if inside string (e.g. for keymaps)
				rule("<", ">", "lua"):with_pair(isNodeType { "string", "comment" }),
				-- auto-pair for markdown syntax
				rule("*", "*", "markdown"):with_pair(),
				rule("__", "__", "markdown"):with_pair(),
			}

			-- add brackets to cmp completions, e.g. "function" -> "function()"
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},
	{ -- autopair, but for keywords
		"RRethy/nvim-treesitter-endwise",
		event = "InsertEnter",
		dependencies = "nvim-treesitter/nvim-treesitter",
	},
	{ -- swapping of nodes
		"mizlan/iswap.nvim",
		dependencies = "nvim-treesitter/nvim-treesitter",
		config = function() require("iswap").setup { autoswap = true } end,
		cmd = "ISwapWith",
	},
	{ -- split-join
		"Wansmer/treesj",
		dependencies = "nvim-treesitter/nvim-treesitter",
		cmd = "TSJToggle",
		config = function()
			require("treesj").setup {
				use_default_keymaps = false,
				cursor_behavior = "start", -- start|end|hold
				max_join_length = 180,
			}
		end,
	},
	{ -- auto-bullets for markdown-like filetypes
		"dkarter/bullets.vim",
		ft = { "markdown", "text" },
		init = function() vim.g.bullets_delete_last_bullet_if_empty = 1 end,
	},
	{ -- Folding
		"kevinhwang91/nvim-ufo",
		dependencies = "kevinhwang91/promise-async",
		event = "BufReadPost",
		config = function()
			local foldIcon = ""
			local ufo = require("ufo")
			ufo.setup {
				provider_selector = function(bufnr, filetype, buftype) ---@diagnostic disable-line: unused-local
					return { "lsp", "indent" } -- Use lsp and treesitter as fallback
				end,
				-- open_fold_hl_timeout = 0,
				fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
					-- https://github.com/kevinhwang91/nvim-ufo#minimal-configuration
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
			}

			-- Using ufo provider need remap `zR` and `zM`
			vim.keymap.set("n", "zR", ufo.openAllFolds, { desc = " Open all folds" })
			vim.keymap.set("n", "zM", ufo.closeAllFolds, { desc = " Close all folds" })

			-- fold settings required for UFO
			vim.opt.foldenable = true
			vim.opt.foldlevel = 99
			vim.opt.foldlevelstart = 99
		end,
	},
}
