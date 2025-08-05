-- FIX https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/488#issuecomment-3154937211
vim.api.nvim_create_autocmd("User", {
	pattern = "LazyLoad",
	group = vim.api.nvim_create_augroup("render-markdown", { clear = true }),
	callback = function(ctx)
		if ctx.data ~= "render-markdown" then return end
		vim.treesitter.stop()
		pcall(vim.treesitter.start)
		return true -- delete this autocmd
	end,
})

--------------------------------------------------------------------------------

return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = "echasnovski/mini.icons",

	ft = { "markdown", "codecompanion" },
	keys = {
		{
			"<leader>oc",
			function() require("render-markdown").toggle() end,
			ft = "markdown",
			desc = " Markdown render",
		},
	},
	---@module "render-markdown"
	---@type render.md.UserConfig
	opts = {
		sign = { enabled = false },
		latex = { enabled = false },
		file_types = { "markdown", "codecompanion" },
		render_modes = { "n", "c", "i", "v", "V" },
		html = {
			comment = { text = "󰆈" },
		},
		heading = {
			position = "inline", -- remove indentation of headings
			icons = { "󰲠 ", "󰲢 ", "󰲤 ", "󰲦 ", "󰲨 ", "󰲪 " },
		},
		bullet = {
			icons = { "▪️", "▫️", "•", "◦" },
			ordered_icons = "", -- empty string = disable
		},
		code = {
			border = "thick",
			position = "left",
		},
		link = {
			custom = {
				myWebsite = { pattern = "https://chris%-grieser.de", icon = " " },
				proseSh = { pattern = "prose%.sh", icon = " " },
				mastodon = { pattern = "%.social/@", icon = " " },
				linkedin = { pattern = "linkedin%.com", icon = "󰌻 " },
				researchgate = { pattern = "researchgate%.net", icon = "󰙨 " },
			},
		},
		-- makes toggling this plugin also toggle conceallevel
		win_options = {
			conceallevel = { default = 0, rendered = 2 },
		},
		-- LSP hovers: hide code block lines, and hide markup even in cursorline
		overrides = {
			buftype = {
				nofile = {
					code = { border = "hide", style = "normal" },
					win_options = {
						concealcursor = { default = vim.o.concealcursor, rendered = "nvic" },
					},
				},
			},
		},
	},
}
