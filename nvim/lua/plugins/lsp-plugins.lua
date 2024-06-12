local u = require("config.utils")
--------------------------------------------------------------------------------

return {
	{ -- nvim lua typings
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
			},
		},
	},
	-- `vim.uv` typings (not as dependency, since they never need to be loaded)
	{ "Bilal2453/luvit-meta", lazy = true },
	-----------------------------------------------------------------------------
	{ -- breadcrumbs for tabline
		"SmiteshP/nvim-navic",
		event = "LspAttach",
		opts = {
			lazy_update_context = false,
			lsp = {
				auto_attach = true,
				preference = { "basedpyright", "tsserver", "marksman", "cssls" },
			},
			icons = { Object = "󰠲 " },
			separator = " ",
			depth_limit = 7,
			highlight = true,
			depth_limit_indicator = "…",
			format_text = function(text) return text:gsub("\t", "") end, -- FIX tabs in breadcrumbs
		},
		init = function()
			-- FIX background color for `opts.highlight = true`
			-- PENDING https://github.com/SmiteshP/nvim-navic/issues/146
			-- stylua: ignore
			local navicHls = { "IconsFile", "IconsModule", "IconsNamespace", "IconsPackage", "IconsClass", "IconsMethod", "IconsProperty", "IconsField", "IconsConstructor", "IconsEnum", "IconsInterface", "IconsFunction", "IconsVariable", "IconsConstant", "IconsString", "IconsNumber", "IconsBoolean", "IconsArray", "IconsObject", "IconsKey", "IconsNull", "IconsEnumMember", "IconsStruct", "IconsEvent", "IconsOperator", "IconsTypeParameter", "Text" }
			local function fixBackground()
				local lualineHl = vim.api.nvim_get_hl(0, { name = "lualine_b_normal" })
				local bg = ("#%06x"):format(lualineHl.bg)
				for _, hlName in ipairs(navicHls) do
					hlName = "Navic" .. hlName
					local hlToFollow = hlName
					local hl
					repeat -- follow linked highlights
						hl = vim.api.nvim_get_hl(0, { name = hlToFollow })
						hlToFollow = hl.link
					until not hl.link
					vim.api.nvim_set_hl(0, hlName, { fg = hl.fg, bg = bg })
				end
				vim.api.nvim_set_hl(0, "NavicSeparator", { link = "lualine_b_normal" })
			end
			vim.api.nvim_create_autocmd("ColorScheme", {
				callback = function() vim.defer_fn(fixBackground, 1) end,
			})
		end,
		config = function(_, opts)
			vim.g.navic_silence = false
			require("nvim-navic").setup(opts)

			u.addToLuaLine("tabline", "lualine_b", { "navic", padding = { left = 1, right = 0 } })
			-- FIX use this dummy component to remove blank space https://github.com/SmiteshP/nvim-navic/issues/115
			u.addToLuaLine("tabline", "lualine_b", {
				function() return " " end,
				cond = function() return #(require("nvim-navic").get_data() or {}) > 0 end,
				padding = 0,
			})
		end,
		keys = {
			{ -- copy breadcrumbs
				"<D-b>",
				function()
					local rawdata = require("nvim-navic").get_data()
					if not rawdata then return end
					local breadcrumbs = ""
					for _, v in pairs(rawdata) do
						breadcrumbs = breadcrumbs .. v.name .. "."
					end
					breadcrumbs = breadcrumbs:sub(1, -2):gsub(".%[", "[")
					u.copyAndNotify(breadcrumbs)
				end,
				desc = "󰒕 Copy Breadcrumbs",
			},
			{ -- go up to parent
				"gk",
				function()
					local symbolPath = require("nvim-navic").get_data()
					if not symbolPath then return end
					local parent = symbolPath[#symbolPath - 1]
					if not parent then return end
					local pos = parent.scope.start
					vim.api.nvim_win_set_cursor(0, { pos.line, pos.character })
				end,
				desc = "󰒕 Go up to parent",
			},
		},
	},
	{ -- signature hints
		"ray-x/lsp_signature.nvim",
		event = "BufReadPre",
		keys = {
			{
				"<D-g>",
				function() require("lsp_signature").toggle_float_win() end,
				mode = { "n", "v", "i" },
				desc = "󰏪 LSP signature",
			},
		},
		opts = {
			hint_prefix = "󰏪 ",
			hint_scheme = "@variable.parameter", -- highlight group
			floating_window = false,
			always_trigger = true,
			handler_opts = { border = vim.g.borderStyle },
			auto_close_after = 3000,
		},
	},
	{ -- display inlay hints from at EoL, not in the text
		"lvimuser/lsp-inlayhints.nvim",
		keys = {
			{
				"<leader>oh",
				function() require("lsp-inlayhints").toggle() end,
				desc = "󰒕 Inlay Hints",
			},
		},
		opts = {
			inlay_hints = {
				labels_separator = "",
				parameter_hints = {
					prefix = " 󰏪 ",
					remove_colon_start = true,
					remove_colon_end = true,
				},
				type_hints = {
					prefix = " 󰜁 ",
					remove_colon_start = true,
					remove_colon_end = true,
				},
			},
		},
		init = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					if not (args.data and args.data.client_id) then return end
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if not client then return end
					require("lsp-inlayhints").on_attach(client, args.buf)
				end,
			})
		end,
	},
	{ -- CodeLens, but also for languages not supporting it
		"Wansmer/symbol-usage.nvim",
		event = "LspAttach",
		opts = {
			request_pending_text = false, -- remove "loading…"
			references = { enabled = true, include_declaration = false },
			definition = { enabled = false },
			implementation = { enabled = false },
			vt_position = "signcolumn", -- not eol, to not conflict with inlay hints
			hl = { link = "Comment" },
			disable = { lsp = { "cssls" } },
			text_format = function(symbol)
				if not symbol.references then return "" end
				if symbol.references == 0 or (symbol.references < 2 and vim.bo.filetype == "css") then
					return
				end
				if symbol.references > 100 then return "++" end

				local refs = tostring(symbol.references)
				local altDigits = "󰬺󰬻󰬼󰬽󰬾󰬿󰭀󰭁󰭂" -- there is no numeric `0` nerdfont icon, so using dot
				for i = 1, #altDigits do
					refs = refs:gsub(tostring(i), altDigits:sub(i, i))
				end
				return refs
			end,
			-- available kinds: https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#symbolKind
			kinds = {
				vim.lsp.protocol.SymbolKind.Module,
				vim.lsp.protocol.SymbolKind.Package,
				vim.lsp.protocol.SymbolKind.Function,
				vim.lsp.protocol.SymbolKind.Method,
				vim.lsp.protocol.SymbolKind.Class,
				vim.lsp.protocol.SymbolKind.Interface,
				vim.lsp.protocol.SymbolKind.Constructor,
			},
		},
	},
	{ -- lsp definitions & references count in the status line
		"chrisgrieser/nvim-dr-lsp",
		event = "LspAttach",
		config = function()
			u.addToLuaLine("sections", "lualine_c", {
				require("dr-lsp").lspCount,
				fmt = function(str) return str:gsub("R", ""):gsub("D", " 󰄾"):gsub("LSP:", "󰈿") end,
			})
			u.addToLuaLine("sections", "lualine_x", require("dr-lsp").lspProgress)
		end,
	},
	{ -- add ignore-comments & lookup rules
		"chrisgrieser/nvim-rulebook",
		opts = {
			suppressFormatter = {
				-- use `biome` instead of `prettier`
				javascript = { location = "prevLine", ignoreBlock = "// biome-ignore format: expl" },
				typescript = { location = "prevLine", ignoreBlock = "// biome-ignore format: expl" },
				css = { location = "prevLine", ignoreBlock = "/* biome-ignore format: expl */" },
			},
		},
		keys = {
			{
				"<leader>cl",
				function() require("rulebook").lookupRule() end,
				desc = " Lookup Rule",
			},
			{
				"<leader>ci",
				function() require("rulebook").ignoreRule() end,
				desc = "󰅜 Ignore Rule",
			},
			{
				"<leader>cy",
				function() require("rulebook").yankDiagnosticCode() end,
				desc = "󰅍 Yank Diagnostic Code",
			},
			{
				"<leader>cf",
				function() require("rulebook").suppressFormatter() end,
				mode = { "n", "x" },
				desc = "󰉿 Suppress Formatter",
			},
		},
	},
}
