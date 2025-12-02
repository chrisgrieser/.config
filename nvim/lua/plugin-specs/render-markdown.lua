-- DOCS https://github.com/MeanderingProgrammer/render-markdown.nvim#setup
--------------------------------------------------------------------------------

return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = "echasnovski/mini.icons",

	ft = "markdown",
	keys = {
		{
			"<leader>oc",
			function() require("render-markdown").toggle() end,
			ft = "markdown",
			desc = " Markdown render",
		},
	},
	opts = {
		restart_highlighter = true, -- nvim core bug fix https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/488#issuecomment-3154937211

		sign = { enabled = false },
		latex = { enabled = false },
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
			wiki = {
				icon = "󱗖 ",
			},
			custom = {
				-- tech companies
				apple = { pattern = "apple%.com", icon = " " },
				microsoft = { pattern = "microsoft%.com", icon = " " },
				openai = { pattern = "openai%.com", icon = " " },
				ycombinator = { pattern = "ycombinator%.com", icon = " " },
				slack = { pattern = "slack%.com", icon = "󰒱 " },
				-- already included in defaults: discord, github, google, neovim,,
				-- reddit, stackoverflow, wikipedia, youtube

				-- news sites
				medium = { pattern = "medium%.com", icon = "󰬔 " }, -- letter-glyphs named `alpha_x`
				verge = { pattern = "theverge%.com", icon = "󰰫 " },
				techcrunch = { pattern = "techcrunch%.com", icon = "󰰥 " },
				wired = { pattern = "wired%.com", icon = "󰬞 " },
				nytimes = { pattern = "nytimes%.com", icon = "󰎕 " },
				bloomberg = { pattern = "bloomberg%.com", icon = "󰎕 " },
				guardian = { pattern = "theguardian%.com", icon = "󰎕 " },
				zeit = { pattern = "zeit%.de", icon = "󰎕 " },
				spiegel = { pattern = "spiegel%.de", icon = "󰎕 " },

				-- misc
				myWebsite = { pattern = "chris%-grieser.de", icon = " " },
				mastodon = { pattern = "%.social/@", icon = " " },
				linkedin = { pattern = "linkedin%.com", icon = "󰌻 " },
				researchgate = { pattern = "researchgate%.net", icon = "󰙨 " },
				doi = { pattern = "doi%.org", icon = "󰑴 " },
			},
		},
		-- makes toggling this plugin also toggle conceallevel
		win_options = {
			conceallevel = { default = 0, rendered = 2 },
		},
		-- LSP hovers: hide code block lines (CAVEAT: also affects code-companion chat)
		overrides = {
			buftype = {
				nofile = {
					code = { border = "hide", style = "normal" },
				},
			},
		},
	},
}
