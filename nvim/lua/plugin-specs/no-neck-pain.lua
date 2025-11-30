return {
	"shortcuts/no-neck-pain.nvim",
	ft = "markdown",
	cmd = "NoNeckPain",
	keys = {
		{ "<leader>or", vim.cmd.NoNeckPain, desc = " Readable length" },
	},
	init = function()
		vim.api.nvim_create_autocmd({ "BufEnter" }, {
			callback = function(ctx)
				vim.schedule(function()
					if vim.b.noneckpain_justran then return end
					if vim.bo[ctx.buf].buftype ~= "" then return end
					local isMarkdown = vim.bo[ctx.buf].filetype == "markdown"
					local enabled = _G.NoNeckPain and _G.NoNeckPain.state and _G.NoNeckPain.state.enabled ---@diagnostic disable-line: undefined-field
					Chainsaw(enabled) -- 🪚
					if (isMarkdown and not enabled) or (isMarkdown and enabled) then
						vim.cmd("NoNeckPain")
						vim.defer_fn(function () vim.b.noneckpain_justran = false end, 1000)
					end
				end)
			end,
		})
	end,
	opts = {
		width = "textwidth",
		autocmds = {
			skipEnteringNoNeckPainBuffer = false,
			disableOnLastBuffer = true,
		},
		colors = {
			blend = -0.3,
		},
	},
}
