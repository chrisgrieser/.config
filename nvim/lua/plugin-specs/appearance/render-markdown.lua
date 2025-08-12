-- DOCS https://github.com/MeanderingProgrammer/render-markdown.nvim#setup
--------------------------------------------------------------------------------

-- FIX https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/488#issuecomment-3154937211
local query = vim.treesitter.query.get('markdown', 'highlights').query
query:disable_pattern(17)
query:disable_pattern(18)

--------------------------------------------------------------------------------

---@module "lazy.types"
---@type LazyPluginSpec
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
		-- LSP hovers: hide code block lines
		overrides = {
			buftype = {
				nofile = {
					code = { border = "hide", style = "normal" },
				},
			},
		},
	},
}
