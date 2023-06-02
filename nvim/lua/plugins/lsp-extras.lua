local u = require("config.utils")

local function glanceConfig()
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
				["<D-s>"] = actions.quickfix, -- consistent with the respective keymap for telescope
				["<S-CR>"] = actions.enter_win("preview"),
				["j"] = actions.next_location, -- `.next` goes to next item, `.next_location` skips groups
				["k"] = actions.previous_location,
			},
			preview = {
				["<S-CR>"] = actions.enter_win("list"),
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
					vim.notify("No " .. method .. "found")
				elseif #results == 1 then
					jump(results[1])
				else
					open(results)
				end
			end,
		},
	}
end

--------------------------------------------------------------------------------

return {
	{ -- lsp definitions and references count in the status line
		"chrisgrieser/nvim-dr-lsp",
		dev = true,
		lazy = true, -- loaded by lualine
	},
	{ -- breadcrumbs for winbar
		"SmiteshP/nvim-navic",
		event = "LspAttach", -- loading on `require` ignores the config, so loading on LspAttach
		init = function() vim.g.navic_silence = true end, -- suppress notifications on errors
		opts = {
			lsp = { auto_attach = true },
			icons = { Object = "󰆧 " },
			separator = "  ",
			depth_limit = 8,
			depth_limit_indicator = "…",
		},
	},
	{ -- better virtualtext diagnostics
		"https://git.sr.ht/~whynothugo/lsp_lines.nvim",
		config = true,
		lazy = true, -- loaded by keymap
		-- disabled at start
		init = function() vim.diagnostic.config { virtual_lines = false } end,
	},
	{ -- better references/definitions
		"dnlhc/glance.nvim",
		cmd = "Glance",
		config = glanceConfig,
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
	{ -- better LSP variable-rename
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
