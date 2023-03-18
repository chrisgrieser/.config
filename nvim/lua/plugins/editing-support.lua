return {
	{ -- e, w, b move based on CamelCase
		"bkad/CamelCaseMotion",
		event = "BufReadPost",
	},
	{ -- highlights for ftFT
		"unblevable/quick-scope",
		keys = { "f", "F", "t", "T" },
		init = function() vim.g.qs_highlight_on_keys = { "f", "F", "t", "T" } end,
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
	{ -- autopair brackets, quotes, and markup
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/nvim-cmp",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			local npairs = require("nvim-autopairs")
			npairs.setup { check_ts = true } -- use treesitter

			local rule = require("nvim-autopairs.rule")
			local isNodeType = require("nvim-autopairs.ts-conds").is_ts_node
			npairs.add_rules {
				rule("<", ">", "lua"):with_pair(isNodeType("string")), -- useful for keymaps
				rule('\\"', '\\"', "json"):with_pair(), -- escaped double quotes 
				rule("*", "*", "markdown"):with_pair(), -- italics
				rule("__", "__", "markdown"):with_pair(), -- bold

				-- before: (|)			after: ( | )
				rule(" ", " "):with_pair(function(opts)
					local pair = opts.line:sub(opts.col - 1, opts.col)
					return vim.tbl_contains({ "()", "[]", "{}" }, pair)
				end),
				-- before: () =>|		after: () => { | }
				rule("%(.*%)%s*%=>$", " {  }", { "typescript", "javascript" })
					:use_regex(true)
					:set_end_pair_length(2),
			}

			-- add brackets to cmp completions, e.g. "function" -> "function()"
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},
	{ -- autopair, but for keywords
		"RRethy/nvim-treesitter-endwise",
		event = "BufEnter",
		dependencies = "nvim-treesitter/nvim-treesitter",
	},
	{ -- swapping of sibling nodes (works with more nodes than Iswap, but has no hint mode)
		"Wansmer/sibling-swap.nvim",
		lazy = true, -- required in keymaps
		dependencies = "nvim-treesitter/nvim-treesitter",
		config = function()
			require("sibling-swap").setup {
				use_default_keymaps = false,
				allowed_separators = {
					"..", -- added for lua string concatenation
					"*", -- added multiplication
					["-"] = false, -- since subtraction is not communicative
					["|"] = false, -- since chaotic with pipes in shell
				},
			}
		end,
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
	{ -- Better Folding
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
				open_fold_hl_timeout = 500,
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
		end,
	},
}
