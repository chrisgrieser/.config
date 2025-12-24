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
		completions = { lsp = { enabled = true } },
		sign = { enabled = false },
		quote = {
			repeat_linebreak = true, -- full border on soft-wrap
		},
		html = {
			comment = { text = "󰆈" }, -- PENDING https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/574
		},
		heading = {
			position = "inline", -- = remove indentation of headings
			width = "block",
			min_width = vim.o.textwidth + 1,
			icons = { "󰲠 ", "󰲢 ", "󰲤 ", "󰲦 ", "󰲨 ", "󰲪 " },
		},
		bullet = {
			icons = { "▪️", "▫️", "•", "◦" }, -- smaller than default icons
			ordered_icons = "", -- empty string = disable
		},
		code = {
			border = "thin",
			position = "left",
			width = "block",
			min_width = 55,
			language_border = "▃",
			language_left = "█",
			language_right = "█",
			left_pad = 1,
			right_pad = 1,
			highlight_border = "DiffText",
		},
		link = {
			-- no icon for internal links, since distinguished via color in
			-- `query/markdown_inline/highlights.scm`
			hyperlink = "",
			wiki = { icon = "" },
			custom = {
				web = { icon = " " }, -- for links that do not match a pattern below

				-- news sites
				medium = { pattern = "medium%.com", icon = "󰬔 " }, -- letter-glyphs are named `alpha_…`
				verge = { pattern = "theverge%.com", icon = "󰰫 " },
				techcrunch = { pattern = "techcrunch%.com", icon = "󰰥 " },
				wired = { pattern = "wired%.com", icon = "󰬞 " },
				nytimes = { pattern = "nytimes%.com", icon = "󰎕 " },
				bloomberg = { pattern = "bloomberg%.com", icon = "󰎕 " },
				guardian = { pattern = "theguardian%.com", icon = "󰎕 " },
				zeit = { pattern = "zeit%.de", icon = "󰎕 " },
				spiegel = { pattern = "spiegel%.de", icon = "󰎕 " },
				tagesschau = { pattern = "tagesschau%.de", icon = "󰎕 " },

				-- misc
				openai = { pattern = "openai%.com", icon = " " },
				doi = { pattern = "doi%.org", icon = "󰑴 " },
				mastodon = { pattern = "%.social/@", icon = " " },
				researchgate = { pattern = "researchgate%.net", icon = "󰙨 " },
				my_website = { pattern = "chris%-grieser.de", icon = " " },
			},
		},
		--------------------------------------------------------------------------
		render_modes = { "n", "c", "i", "v", "V" },
		win_options = {
			conceallevel = { default = 0 }, -- makes toggling this plugin also toggle conceallevel
		},
		overrides = { -- LSP hovers: hide code block lines
			buftype = {
				nofile = {
					code = { border = "hide", style = "normal" },
				},
			},
		},
	},
}
