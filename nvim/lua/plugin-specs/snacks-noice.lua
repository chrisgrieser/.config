return {
	"folke/snacks.nvim",
	init = function()
		vim.ui_attach(
			vim.api.nvim_create_namespace("ui"),
			{ ext_messages = true },
			function(event, ...) ---@diagnostic disable-line: redundant-parameter
				if not vim.startswith(event, "msg_") then return end
				local args = { ... }
				vim.notify(vim.inspect(args)) -- 🪚
				vim.notify(event)
			end
		)
	end,
	keys = {
		{
			-- PROS: vim motions, highlighting, history via `<Up>`, results as via `vim.notify`
			-- CONS: no completions, no incremental previews
			":",
			function()
				vim.ui.input({
					prompt = "Cmdline",
					win = { ft = "vim" }, --> this part is snacks-specific
				}, function(expr)
					if not expr then return end
					local output = vim.trim(vim.fn.execute(expr))
					if output == "" then return end
					vim.notify(output, vim.log.levels.DEBUG, { title = ":" .. expr, icon = "" })
				end)
			end,
			desc = "󰘳 Better cmdline",
		},
	},
}
