-- DOCS https://github.com/MeanderingProgrammer/render-markdown.nvim#setup
--------------------------------------------------------------------------------

local wikilinkHlgroup = "Label"

--------------------------------------------------------------------------------

return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = "echasnovski/mini.icons",

	ft = "markdown",
	init = function()
		-- also set wikilinks in conceal is disabled (like on the cursorline)
		-- (semantic highlighting by `marksman` lsp)
		vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
			desc = "User: Highlights for wikilinks",
			callback = function()
				vim.api.nvim_set_hl(0, "@lsp.type.class.markdown", { link = wikilinkHlgroup })
			end,
		})
	end,
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
		quote = {
			repeat_linebreak = true, -- full border on soft-wrap
		},
		html = {
			comment = { text = "󰆈" }, -- PENDING https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/574
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
			wiki = {
				-- highlight wikilinks when conceal is active
				-- (or: markdown_inline query: `((shortcut_link) @wikilink (#set! priority 130))`)
				icon = "󰴚 ",
				highlight = wikilinkHlgroup,
				scope_highlight = wikilinkHlgroup,
			},
			custom = {
				-- internal links
				file = { pattern = "%.md$", priority = 100, highlight = wikilinkHlgroup, icon = "󰴚 " },

				-- for links that do not match a pattern below
				web = { icon = " " },

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
