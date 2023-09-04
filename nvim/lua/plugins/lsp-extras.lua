local u = require("config.utils")
--------------------------------------------------------------------------------

return {
	{ -- lightbulb for available lsp actions
		"kosayoda/nvim-lightbulb",
		event = "LspAttach",
		opts = {
			autocmd = { enabled = true, updatetime = -1 }, -- -1 = updatetime set by myself
			sign = { enabled = false },
			status_text = { enabled = true, text = " " },
			action_kinds = { "refactor" },
			ignore = {
				clients = {
					"lua_ls", -- spams parameter refactoring
					"marksman", -- spams ToC update everywhere
					"ruff_lsp", -- spams fixAll everywhere
				},
			},
		},
	},
	{ -- lsp definitions & references count in the status line
		"chrisgrieser/nvim-dr-lsp",
		event = "LspAttach",
		dev = true,
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
		init = function()
			vim.keymap.set("n", "^", function()
				if not require("nvim-navic").is_available() then
					u.notify("", "Navic is not available.")
					return
				end
				local symbolPath = require("nvim-navic").get_data()
				if #symbolPath == 0 then return end
				local parent = #symbolPath > 1 and symbolPath[#symbolPath - 1] or symbolPath[1]
				local parentPos = parent.scope.start
				vim.api.nvim_win_set_cursor(0, { parentPos.line, parentPos.character })
			end, { desc = "󰒕 Go Up to Parent" })

			-- copy breadcrumbs
			vim.keymap.set("n", "<D-b>", function()
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
			end, { desc = "󰒕 Copy Breadcrumbs" })
		end,
		opts = {
			lsp = {
				auto_attach = true,
				preference = { "pyright" },
			},
			icons = { Object = "󰆧 " },
			separator = "  ",
			depth_limit = 7,
			depth_limit_indicator = "…",
		},
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
	{ -- better LSP variable-rename
		"smjonas/inc-rename.nvim",
		event = "CmdlineEnter", -- loading with `cmd = "IncRename` does not work with incremental preview
		opts = {
			post_hook = function(results)
				if not results.changes then return end

				-- if more than one file is changed, save all buffers
				local filesChang = #vim.tbl_keys(results.changes)
				if filesChang > 1 then vim.cmd.wall() end

				-- FIX making the cmdline-history not navigable, pending: https://github.com/smjonas/inc-rename.nvim/issues/40
				vim.fn.histdel("cmd", "^IncRename ")
			end,
		},
	},
}
