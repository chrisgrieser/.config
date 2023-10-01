local u = require("config.utils")
--------------------------------------------------------------------------------

return {
	{ -- better references/definitions
		"dnlhc/glance.nvim",
		keys = {
			{ "gd", "<cmd>Glance definitions<CR>", desc = "󰒕 Definitions" },
			{ "gf", "<cmd>Glance references<CR>", desc = "󰒕 References" },
		},
		config = function()
			local actions = require("glance").actions
			require("glance").setup {
				height = 25,
				list = { width = 0.35, position = "left" },
				border = {
					enable = true,
					top_char = u.borderHorizontal,
					bottom_char = u.borderHorizontal,
				},
				preview_win_opts = { number = false, wrap = false },
				folds = { folded = false },
				mappings = {
					list = {
						["<C-CR>"] = actions.enter_win("preview"),
						["j"] = actions.next_location, -- `.next` goes to next item, `.next_location` skips groups
						["k"] = actions.previous_location,

						-- consistent with the respective keymap for telescope
						["<D-s>"] = function()
							actions.quickfix() -- leaves quickfix window open, so it's necessary to close it
							vim.cmd.cclose() -- cclose = quickfix-close
						end,
					},
					preview = {
						["<C-CR>"] = actions.enter_win("list"),
					},
				},
				hooks = {
					-- jump directly if there is only one references
					-- filter out current line, if references
					before_open = function(results, open, jump, method)
						if method == "references" then
							local filtered = {}
							local curLn = vim.fn.line(".")
							local curUri = vim.uri_from_bufnr(0)
							for _, result in pairs(results) do
								local targetLine = result.range.start.line + 1 -- LSP counts off-by-one
								local targetUri = result.uri or result.targetUri
								local isCurrentLine = targetLine == curLn and (targetUri == curUri)
								if not isCurrentLine then table.insert(filtered, result) end
							end
							results = filtered
						end

						if #results == 0 then
							vim.notify("No " .. method .. " found")
						elseif #results == 1 then
							jump(results[1])
						else
							open(results)
						end
					end,
				},
			}
		end,
	},
	{ -- virtual text showing usage count of functions
		"Wansmer/symbol-usage.nvim",
		event = "BufReadPre", -- TODO need run before LspAttach if you use nvim 0.9. On 0.10 use 'LspAttach'
		opts = {
			hl = { link = "NonText" },
			vt_position = "end_of_line",
			references = { enabled = true, include_declaration = false },
			definition = { enabled = false },
			implementation = { enabled = false },
			-- see `lsp.SymbolKind`
			kinds = { vim.lsp.protocol.SymbolKind.Function, vim.lsp.protocol.SymbolKind.Method },
			text_format = function(symbol) return " 󰈿 " .. symbol.references end,
		},
	},
	{ -- lsp definitions & references count in the status line
		"chrisgrieser/nvim-dr-lsp",
		event = "LspAttach",
		config = function()
			u.addToLuaLine("sections", "lualine_x", require("dr-lsp").lspProgress)
			u.addToLuaLine("sections", "lualine_c", {
				require("dr-lsp").lspCount,
				-- needs the highlight value, since setting the hlgroup directly
				-- results in bg color being inherited from main editor
				color = function() return { fg = u.getHighlightValue("Comment", "fg") } end,
				fmt = function(str) return str:gsub("R", ""):gsub("D", " 󰄾"):gsub("LSP:", "󰈿") end,
			})
		end,
	},
	{ -- breadcrumbs for winbar
		"SmiteshP/nvim-navic",
		event = "LspAttach", -- loading on `require` ignores the config, so loading on LspAttach
		keys = {
			{
				"<D-b>",
				function()
					local rawdata = require("nvim-navic").get_data()
					if not rawdata then
						u.notify("Navic", "No breadcrumbs available.")
						return
					end
					local breadcrumbs = ""
					for _, v in pairs(rawdata) do
						breadcrumbs = breadcrumbs .. v.name .. "."
					end
					breadcrumbs = breadcrumbs:sub(1, -2)
					vim.fn.setreg("+", breadcrumbs)
					u.notify("Copied", breadcrumbs)
				end,
				desc = "󰒕 Copy Breadcrumbs",
			},
		},
		opts = {
			lsp = {
				auto_attach = true,
				preference = { "pyright", "tsserver" },
			},
			icons = { Object = "󰆧 " },
			separator = "  ",
			depth_limit = 7,
			depth_limit_indicator = "…",
		},
	},
	{ -- signature hints
		"ray-x/lsp_signature.nvim",
		event = "BufReadPre", -- TODO need run before LspAttach if you use nvim 0.9. On 0.10 use 'LspAttach'
		opts = {
			floating_window = false,
			always_trigger = true,
			hint_prefix = "󰘎 ",
			hint_scheme = "DiagnosticHint", -- = highlight group
			hint_inline = function() return false end, -- TODO change with 0.10
		},
	},
	{ -- better LSP variable-rename
		"smjonas/inc-rename.nvim",
		event = "CmdlineEnter", -- loading with `cmd = "IncRename` does not work with incremental preview
		opts = {
			post_hook = function(results)
				if not results.changes then return end

				-- if more than one file is changed, save all buffers
				local filesChanged = #vim.tbl_keys(results.changes)
				if filesChanged > 1 then vim.cmd("silent wall") end

				-- FIX making the cmdline-history not navigable
				-- PENDING: https://github.com/smjonas/inc-rename.nvim/issues/40
				vim.fn.histdel("cmd", "^IncRename ")
			end,
		},
	},
}
