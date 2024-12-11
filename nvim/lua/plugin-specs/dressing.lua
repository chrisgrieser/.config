return {
	"stevearc/dressing.nvim",
	init = function(spec)
		---@diagnostic disable-next-line: duplicate-set-field -- intentional
		vim.ui.select = function(items, opts, on_choice)
			require("lazy").load { plugins = { spec.name } }
			return vim.ui.select(items, opts, on_choice)
		end


		--------------------------------------------------------------------------

		-- PENDING https://github.com/folke/snacks.nvim/issues/257
		---@diagnostic disable-next-line: duplicate-set-field -- intentional
		vim.ui.input = function(items, opts, on_choice)
			require("lazy").load { plugins = { spec.name } }
			return vim.ui.input(items, opts, on_choice)
		end
	end,
	-- config = function(_, opts)
	-- 	require("dressing").setup(opts)
	-- 	-- use `snacks` for input, but do not disable `dressing`'s `input` since
	-- 	-- it's still needed for genghis
	-- 	vim.ui.input = require("snacks").input
	-- end,

	-----------------------------------------------------------------------------

	keys = {
		{ "<Tab>", "j", ft = "DressingSelect" },
		{ "<S-Tab>", "k", ft = "DressingSelect" },
	},
	opts = {
		input = {
			start_mode = "insert",
			trim_prompt = true,
			border = vim.g.borderStyle,
			relative = "editor",
			prefer_width = 50,
			min_width = { 20, 0.4 },
			max_width = { 80, 0.8 },
			win_options = { statuscolumn = " " }, -- padding fix PENDING https://github.com/stevearc/dressing.nvim/pull/185
			mappings = {
				n = {
					["q"] = "Close",
					["<Up>"] = "HistoryPrev",
					["<Down>"] = "HistoryNext",
					-- prevent accidental closing due <BS> being mapped to :bprev
					["<BS>"] = "<Nop>",
				},
			},
		},
		select = {
			trim_prompt = true,
			builtin = {
				show_numbers = false,
				border = vim.g.borderStyle,
				relative = "editor",
				max_width = 80,
				min_width = 20,
				max_height = 12,
				min_height = 3,
				mappings = { ["q"] = "Close" },
			},
			telescope = {
				layout_config = {
					horizontal = { width = { 0.7, max = 75 }, height = 0.6 },
				},
			},
			get_config = function(opts)
				local useBuiltin = { "plain", "codeaction", "rule_selection" }
				if vim.tbl_contains(useBuiltin, opts.kind) then
					return {
						backend = { "builtin" },
						builtin = { relative = "cursor" },
					}
				end
			end,
			format_item_override = {
				-- display kind and client name next to code action
				codeaction = function(item)
					vim.api.nvim_create_autocmd("FileType", {
						desc = "User: Add highlighting to `DressingSelect` for code actions",
						pattern = "DressingSelect",
						once = true,
						callback = function(ctx)
							vim.treesitter.start(ctx.buf, "markdown")
								-- stylua: ignore
								vim.api.nvim_buf_call(ctx.buf, function() vim.fn.matchadd("Nontext", [[(.*)$]]) end)
						end,
					})
					local client = (vim.lsp.get_client_by_id(item.ctx.client_id) or {}).name
					return ("%s (%s, %s)"):format(item.action.title, item.action.kind, client)
				end,
			},
		},
	},
}
