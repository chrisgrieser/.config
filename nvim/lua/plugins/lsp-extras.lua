local u = require("config.utils")
--------------------------------------------------------------------------------

return {
	{ -- breadcrumbs for winbar
		"SmiteshP/nvim-navic",
		event = "LspAttach", -- loading on `require` ignores the config, so loading on LspAttach
		init = function() vim.g.navic_silence = true end, -- suppress notifications on errors
		opts = {
			lsp = { auto_attach = true },
			icons = { Object = "󰆧 " },
			separator = "  ",
			depth_limit = 7,
			depth_limit_indicator = "…",
		},
	},
	{ -- better goto-symbol
		"SmiteshP/nvim-navbuddy",
		event = "LspAttach",
		dependencies = { "SmiteshP/nvim-navic", "MunifTanjim/nui.nvim" },
		opts = {
			window = {
				border = u.borderStyle,
				size = { height = "50%", width = "85%" },
				scrolloff = nil,
				sections = {
					left = { size = "30%" },
					mid = { size = "40%" },
					right = { preview = "never" }, -- leaf|always|never
				},
			},
			lsp = { auto_attach = true },
		},
	},
	{ -- better virtualtext diagnostics
		"https://git.sr.ht/~whynothugo/lsp_lines.nvim",
		config = true,
		lazy = true, -- loaded by keymaps
		-- off at start
		init = function() vim.diagnostic.config { virtual_lines = false } end,
	},
	{ -- better references/definitions
		"dnlhc/glance.nvim",
		cmd = "Glance",
		opts = {
			height = 23,
			border = {
				enable = true,
				top_char = u.borderHorizontal,
				bottom_char = u.borderHorizontal,
			},
			preview_win_opts = { number = false },
			list = {
				width = 0.4,
				position = "left",
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
						vim.notify("No " .. method .. "found")
					elseif #results == 1 then
						jump(results[1])
					else
						open(results)
					end
				end,
			},
		},
	},
	{ -- signature hints
		"ray-x/lsp_signature.nvim",
		event = "LspAttach", -- loading on `require` ignores the config, so loading on LspAttach
		opts = {
			floating_window = false,
			hint_prefix = "󰘎 ",
			hint_scheme = "NonText", -- highlight group
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
	{ -- better LSP rename
		"smjonas/inc-rename.nvim",
		event = "CmdlineEnter", -- loading with `cmd =` does not work with incremental preview
		opts = {
			-- if more than one file is changed, save all buffers
			post_hook = function(results)
				local filesChanged = #vim.tbl_keys(results.changes)
				if filesChanged > 1 then vim.cmd.wall() end
			end,
		},
	},
}
