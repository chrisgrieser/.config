return {
	"folke/snacks.nvim",

	keys = {
		{
			":",
			function()
				vim.ui.input({
					prompt = "Cmdline",
					win = {
						ft = "vim",
						bo = { ft = "pseudo-cmdline" },
					},
				}, function(expr)
					if not expr then return end
					local output = vim.trim(vim.fn.execute(expr))
					if output == "" then return end
					vim.notify(output, vim.log.levels.DEBUG, { title = ":" .. expr, icon = "" })
				end)
			end,
			desc = "󰘳 Cmdline with vim motions",
		},
		{
			"<leader>ee",
			function()
				vim.ui.input({
					prompt = "󰢱 Eval",
					win = { ft = "lua" }, --> this part is snacks-specific
				}, function(expr)
					if not expr then return end
					local result = vim.inspect(vim.fn.luaeval(expr))
					local opts = { title = "Eval", icon = "󰢱", ft = "lua" }
					vim.notify(result, vim.log.levels.DEBUG, opts)
				end)
			end,
			desc = "󰢱 Eval lua expr",
		},
	},

	opts = {
		input = {
			icon = "",
			win = {
				relative = "editor",
				backdrop = 60,
				border = vim.o.winborder --[[@as "rounded"|"single"|"double"|"solid"]],
				title_pos = "left",
				width = 50,
				row = math.ceil(vim.o.lines / 2) - 3,
			},
		},
	},
}
