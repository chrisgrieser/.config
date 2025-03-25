return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
	ft = "markdown",
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
		win_options = {
			-- makes toggling this plugin also toggle conceallevel
			conceallevel = { default = 0, rendered = 2 },
		},
	},
}
