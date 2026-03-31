vim.pack.add { "https://github.com/MeanderingProgrammer/render-markdown.nvim" }
--------------------------------------------------------------------------------

require("config.utils").pluginKeymaps {

}

--------------------------------------------------------------------------------

require("render-markdown").setup {
quote = {
	repeat_linebreak = true, -- full border on soft-wrap
},
html = {
	comment = {
		text = function(ctx)
			local text = ctx.text:match("^<!%-%-%s*(.-)%s*%-%->$")
			if not text then return "" end
			return "󰆈 " .. text:gsub("\n.*", " ↓↓↓")
		end,
	},
},
pipe_table = {
	border_enabled = true,
	border_virtual = true, -- borders not on empty lines -> preserves blank lines
},
heading = {
	position = "inline", -- = remove indentation of headings
	width = "block", -- = not full width
	min_width = vim.o.textwidth,
	icons = { "󰎤 ", "󰎧 ", "󰎪 ", "󰎭 ", "󰎱 ", "󰎳 " }, -- `numeric_x` glyphs
	-- icons = { "󰲠 ", "󰲢 ", "󰲤 ", "󰲦 ", "󰲨 ", "󰲪 " },
},
dash = {
	width = vim.o.textwidth,
	priority = 10, -- don't cover codelens from `markdown-oxide` for 1st line of frontmatter
},
bullet = {
	icons = { "◇", "▪️", "▫️" }, -- ◆◇•◦▫️▪️
	ordered_icons = "", -- disable overwriting ordered list numbers with 1-2-3
},
checkbox = {
	checked = { icon = "󰄵" },
	unchecked = { icon = "󰄱" },
	custom = {
		todo = { rendered = "󰡖", raw = "[-]", highlight = "RenderMarkdownInfo" },
	},
},
code = {
	position = "left",
	width = "block", -- = not full width
	min_width = 50,
	left_pad = 0, -- better `0` due to uneven padding https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/576#issuecomment-3694595069
	right_pad = 1,
	border = "thin", -- use the `above`/`below` chars as is
	below = "▔", -- ▀▔
	above = "▁", -- ▃▁
	language_border = "▁",
	language_left = "▁▁█",
	language_right = "█",
	highlight_border = "PmenuThumb",
},
link = {
	-- no icon for internal links, since distinguished via color in
	-- `query/markdown_inline/highlights.scm`
	hyperlink = "",
	wiki = { icon = "" },
	email = "󰇮 ",
	footnote = { icon = "  ", superscript = false },

	custom = {
		web = { icon = " " }, -- for links that do not match a pattern below

		-- news sites
		medium = { pattern = "medium%.com", icon = "󰬔 " }, -- letter-glyphs are named `alpha_…`
		verge = { pattern = "theverge%.com", icon = "󰰫 " },
		techcrunch = { pattern = "techcrunch%.com", icon = "󰬛󰬊 " },
		wired = { pattern = "wired%.com", icon = "󰬞 " },
		nytimes = { pattern = "nytimes%.com", icon = "󰬕󰬠 " },
		bloomberg = { pattern = "bloomberg%.com", icon = "󰯯 " },
		guardian = { pattern = "theguardian%.com", icon = "󰯾 " },
		zeit = { pattern = "zeit%.de", icon = "󰬡 " },
		spiegel = { pattern = "spiegel%.de", icon = "󰬚 " },
		tagesschau = { pattern = "tagesschau%.de", icon = "󰰥 " },

		-- misc
		openai = { pattern = "openai%.com", icon = " " },
		doi = { pattern = "doi%.org", icon = "󰑴 " },
		mastodon = { pattern = "%.social/@", icon = " " },
		researchgate = { pattern = "researchgate%.net", icon = "󰙨 " },
		my_website = { pattern = "chris%-grieser.de", icon = " " },
	},
},
--------------------------------------------------------------------------
sign = { enabled = false },
render_modes = { "n", "c", "i", "v", "V" },
win_options = {
	conceallevel = { default = 0 }, -- makes toggling this plugin also toggle conceallevel
	colorcolumn = { default = vim.o.colorcolumn, rendered = "" }, -- disabled on render, since heading width already indicates it
},
overrides = { -- LSP hovers: hide code block lines
	buftype = {
		nofile = {
			code = { border = "hide", style = "normal" },
		},
	},
},
}
