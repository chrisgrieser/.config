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
			icons = { "▪️", "▫️", "•", "◦" }, -- smaller than default icons
			ordered_icons = "", -- empty string = disable
		},
		code = {
			border = "thick",
			position = "left",
		},
		link = {
			custom = {
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
				openai = { pattern = "openai%.com", icon = " " },
				doi = { pattern = "doi%.org", icon = "󰑴 " },
				mastodon = { pattern = "%.social/@", icon = " " },
				researchgate = { pattern = "researchgate%.net", icon = "󰙨 " },
				my_website = { pattern = "chris%-grieser.de", icon = " " },
			},
		},
		quote = { repeat_linebreak = true }, -- full border on soft-wrap
		win_options = {
			-- makes toggling this plugin also toggle conceallevel
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
