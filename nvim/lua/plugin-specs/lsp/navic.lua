---@module "lazy.types"
---@type LazyPluginSpec
return {
	"SmiteshP/nvim-navic",
	event = "LspAttach",
	opts = {
		lazy_update_context = false,
		lsp = {
			auto_attach = true,
			preference = { "tombi" },
		},
		icons = { Object = " " },
		separator = " ",
		depth_limit = 9,
		depth_limit_indicator = "…",
	},
	config = function(_, opts)
		require("nvim-navic").setup(opts)
		vim.g.lualineAdd("tabline", "lualine_b", { "navic" })
	end,
	keys = {
		{ -- copy breadcrumbs
			"<leader>yb",
			function()
				local rawdata = require("nvim-navic").get_data()
				if not rawdata then return end
				local breadcrumbs = ""
				for _, v in pairs(rawdata) do
					breadcrumbs = breadcrumbs .. v.name .. "."
				end
				breadcrumbs = breadcrumbs:sub(1, -2):gsub(".%[", "[")
				vim.fn.setreg("+", breadcrumbs)
				vim.notify(breadcrumbs, nil, { title = "Copied", ft = "text" })
			end,
			desc = "󰳯 Breadcrumbs",
		},
		{ -- go up to parent
			"gk",
			function()
				local symbolPath = require("nvim-navic").get_data()
				if not symbolPath then return end
				local parent = symbolPath[#symbolPath - 1]
				if not parent then return end
				local pos = parent.scope.start
				vim.api.nvim_win_set_cursor(0, { pos.line, pos.character })
			end,
			desc = "󰒕 Go up to parent",
		},
	},
}
