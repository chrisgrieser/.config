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
				indent_lines = { icon = " " },
				mappings = {
					list = {
						["<C-CR>"] = actions.enter_win("preview"),
						["j"] = actions.next_location, -- `.next` goes to next item, `.next_location` skips groups
						["k"] = actions.previous_location,
						["<PageUp>"] = actions.preview_scroll_win(5),
						["<PageDown>"] = actions.preview_scroll_win(-5),

						-- consistent with the respective keymap for telescope
						["<D-s>"] = function()
							actions.quickfix() -- leaves quickfix window open, so it's necessary to close it
							vim.cmd.cclose() -- cclose = quickfix-close
						end,
					},
					preview = {
						["<C-CR>"] = actions.enter_win("list"),
						["Q"] = false,
					},
				},
				hooks = {
					before_open = function(results, open, jump, method)
						-- filter out current line, if references
						if method == "references" then
							local curLn = vim.fn.line(".")
							local curUri = vim.uri_from_bufnr(0)
							results = vim.tbl_filter(function(result)
								local targetLine = result.range.start.line + 1 -- LSP counts off-by-one
								local targetUri = result.uri or result.targetUri
								local notCurrentLine = (targetLine ~= curLn) or (targetUri ~= curUri)
								return notCurrentLine
							end, results)
						end

						-- jump directly if there is only one references
						if #results == 0 then
							vim.notify("No " .. method .. " found.")
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
	{ -- symbols sibebar and search
		"stevearc/aerial.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
		keys = {
			{ "<D-1>", "<cmd>AerialToggle<CR>", desc = "󰒕 Symbols Sidebar" },
			{ "<C-j>", "<cmd>AerialNext<CR>zv", desc = "󰒕 Next Symbol" },
			{ "<C-k>", "<cmd>AerialPrev<CR>zv", desc = "󰒕 Previous Symbol" },
			{
				"gs",
				function() require("telescope").extensions.aerial.aerial() end,
				desc = "󰒕 Symbols Search",
			},
		},
		config = function()
			require("aerial").setup {
				layout = {
					default_direction = "left",
					min_width = 20,
					win_opts = { signcolumn = "yes:1" },
				},
				show_guides = true,
				highlight_on_hover = true,
				close_on_select = true,
				autojump = false, -- BUG https://github.com/stevearc/aerial.nvim/issues/309
				keymaps = {
					["<Esc>"] = "actions.close",

					-- HACK emulate autojump
					["j"] = "actions.down_and_scroll", 
					["k"] = "actions.up_and_scroll",
				},
			}
			require("telescope").load_extension("aerial")
		end,
	},
	{ -- signature hints
		"ray-x/lsp_signature.nvim",
		event = "BufReadPre", -- TODO need run before LspAttach if you use nvim 0.9. On 0.10 use 'LspAttach'
		opts = {
			hint_prefix = "󰏪 ",
			hint_scheme = "@parameter", -- highlight group
			hint_inline = function() return false end, -- TODO change with 0.10
			floating_window = false,
			always_trigger = true,
			noice = true, -- render via noice.nvim
			toggle_key = "<D-g>",
		},
	},
	{ -- better LSP variable-rename
		"smjonas/inc-rename.nvim",
		keys = {
			{ "<leader>v", ":IncRename ", { desc = "󰒕 IncRename" } },
			{ "<leader>V", ":IncRename <C-r><C-w>", { desc = "󰒕 IncRename (cword)" } },
		},
		opts = {
			post_hook = function(results)
				if not results.changes then return end

				-- if more than one file is changed, save all buffers
				local filesChanged = #vim.tbl_keys(results.changes)
				if filesChanged > 1 then vim.cmd("silent wall") end

				-- FIX make the cmdline-history navigable https://github.com/smjonas/inc-rename.nvim/issues/40
				vim.fn.histdel("cmd", "^IncRename ")
			end,
		},
	},
}
