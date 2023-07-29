local u = require("config.utils")

return {
	{ -- lsp definitions & references count in the status line
		"chrisgrieser/nvim-dr-lsp",
		lazy = true, -- loaded by lualine
		dev = true,
	},
	{ -- breadcrumbs for winbar
		"SmiteshP/nvim-navic",
		event = "LspAttach", -- loading on `require` ignores the config, so loading on LspAttach
		init = function()
			vim.g.navic_silence = true -- suppress notifications on errors
			vim.keymap.set("n", "gk", function()
				if not require("nvim-navic").is_available() then
					vim.notify("Navic is not available.")
					return
				end
				local symbolPath = require("nvim-navic").get_data()
				local parent = symbolPath[#symbolPath - 1]
				if not parent then
					vim.notify("Already at the highest parent.")
					return
				end
				local parentPos = parent.scope.start
				u.setCursor(0, { parentPos.line, parentPos.character })
			end, { desc = "󰒕 Go Up to Parent" })

			-- copy breadcrumbs (nvim navic)
			vim.keymap.set("n", "<D-b>", function()
				local rawdata = require("nvim-navic").get_data()
				if not rawdata then
					vim.notify("No Breadcrumbs available", u.warn)
					return
				end
				local breadcrumbs = ""
				for _, v in pairs(rawdata) do
					breadcrumbs = breadcrumbs .. v.name .. "."
				end
				breadcrumbs = breadcrumbs:sub(1, -2)
				vim.fn.setreg("+", breadcrumbs)
				vim.notify("COPIED\n" .. breadcrumbs)
			end, { desc = "󰒕 Copy Breadcrumbs" })
		end,
		opts = {
			lsp = { auto_attach = true },
			icons = { Object = "󰆧 " },
			separator = "  ",
			depth_limit = 8,
			depth_limit_indicator = "…",
		},
	},
	{ -- Diagnostic Virtual Text at the top right, not at EoL
		"dgagn/diagflow.nvim",
		event = "VeryLazy",
		opts = {
			max_width = 35,
			max_height = 8,
			scope = "line", -- cursor|line
			placement = "top", -- top|inline
			text_align = "left", -- left|right
			gap_size = 1,
			padding_top = 0,
			padding_right = 2, -- for scrollbar
			update_event = { "BufReadPost", "InsertLeave", "DiagnosticChanged" },
			toggle_event = { "InsertEnter", "DiagnosticChanged" },
			show_sign = true,
			severity_colors = { -- virtual text hlgroups have background in most themes
				error = "DiagnosticVirtualTextError",
				warning = "DiagnosticVirtualTextWarning",
				info = "DiagnosticVirtualTextInfo",
				hint = "DiagnosticVirtualTextHint",
			},
			format = function(diag) return u.diagnosticFmt(diag) end,
		},
	},
	{ -- better references/definitions
		"dnlhc/glance.nvim",
		cmd = "Glance",
		config = function()
			local actions = require("glance").actions
			require("glance").setup {
				height = 25,
				list = {
					width = 0.35,
					position = "left",
				},
				border = {
					enable = true,
					top_char = u.borderHorizontal,
					bottom_char = u.borderHorizontal,
				},
				preview_win_opts = {
					number = false,
					wrap = false,
				},
				folds = { folded = false },
				mappings = {
					list = {
						["<C-CR>"] = actions.enter_win("preview"),
						["j"] = actions.next_location, -- `.next` goes to next item, `.next_location` skips groups
						["k"] = actions.previous_location,

						-- SEE https://github.com/DNLHC/glance.nvim/pull/60
						["<D-s>"] = actions.quickfix, -- consistent with the respective keymap for telescope
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
	{ -- signature hints
		"ray-x/lsp_signature.nvim",
		-- loading on `require` or InsertEnter ignores the config, so loading on LspAttach
		event = "LspAttach",
		opts = {
			floating_window = false,
			hint_prefix = "󰘎 ",
			hint_scheme = "NonText", -- = highlight group
		},
	},
	{ -- display inlay hints from LSP
		"lvimuser/lsp-inlayhints.nvim", -- INFO only temporarily needed, until https://github.com/neovim/neovim/issues/18086
		lazy = true, -- required in attach function
		init = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local bufnr = args.buf
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					local capabilities = client.server_capabilities
					if capabilities.inlayHintProvider then
						require("lsp-inlayhints").on_attach(client, bufnr, false)
					end
				end,
			})
		end,
		opts = {
			inlay_hints = {
				parameter_hints = {
					show = true,
					prefix = "󰁍 ",
					remove_colon_start = true,
					remove_colon_end = true,
				},
				type_hints = {
					show = true,
					prefix = "   ",
					remove_colon_start = true,
					remove_colon_end = true,
				},
				only_current_line = true,
				highlight = "NonText", -- highlight group
			},
		},
	},
	{ -- better LSP variable-rename
		"smjonas/inc-rename.nvim",
		-- loading with `cmd = "IncRename` does not work with incremental preview
		event = "CmdlineEnter",
		opts = {
			-- if more than one file is changed, save all buffers
			post_hook = function(results)
				local filesChanged = #vim.tbl_keys(results.changes)
				if filesChanged > 1 then vim.cmd.wall() end
			end,
		},
	},
}
