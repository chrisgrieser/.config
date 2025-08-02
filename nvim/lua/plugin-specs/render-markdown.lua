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
		file_types = { "markdown", "codecompanion" },
		render_modes = { "n", "c", "i", "v", "V" },
		sign = {
			enabled = false,
		},
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
		overrides = {
			buftype = {
				-- LSP hovers: hide code block lines, and hide markup even in cursorline
				nofile = {
					code = {
						border = "hide",
						style = "normal",
					},
					win_options = {
						concealcursor = {
							default = vim.o.concealcursor,
							rendered = "nvic",
						},
					},
				},
			},
		},
	},
}
