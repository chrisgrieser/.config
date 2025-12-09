-- DOCS https://github.com/stevearc/aerial.nvim#options
--------------------------------------------------------------------------------

local getBreadcrumbs = function()
	local symbols = vim.iter(require("aerial").get_location())
		:map(function(loc) return loc.name end)
		:join(".")
		:gsub("%.(%d+)", "[%1]") -- enclose array elements with []
	if vim.bo.ft == "json" or vim.bo.ft == "yaml" then symbols = "." .. symbols end -- for yq/jq
	return symbols
end

--------------------------------------------------------------------------------

return {
	"stevearc/aerial.nvim",
	cmd = "AerialToggle",
	event = "VeryLazy",
	keys = {
		{
			"<D-0>",
			function()
				vim.b.aerialWasManuallyClosed = require("aerial").is_open()
				require("aerial").toggle { focus = false }
			end,
			desc = "󰙅 Aerial Toggle",
		},
		{
			"<leader>ia",
			function()
				local symbols = require("aerial").get_location()
				local text = vim.iter(symbols):map(function(loc) return loc.kind end):join(", ")
				vim.notify(text, nil, { title = "Aerial symbols", icon = "󰙅" })
			end,
			desc = "󰙅 Aerial symbols",
		},
		{
			"<leader>yb",
			function()
				local crumbs = getBreadcrumbs()
				vim.fn.setreg("+", crumbs)
				vim.notify(crumbs, nil, { title = "Copied", icon = "󰙅", ft = "text" })
			end,
			desc = "󰙅 Breadcrumbs",
		},
	},
	config = function(_, opts)
		vim.g.lualineAdd("tabline", "lualine_b", { getBreadcrumbs, icon = "󰙅" })
		require("aerial").setup(opts)
	end,
	opts = {
		---FILETYPE-SPECIFIC------------------------------------------------------
		backends = {
			yaml = { "lsp", "treesitter" },
			json = { "lsp", "treesitter" },
		},
		filter_kind = {
			-- _ = { "Array", "Boolean", "Class", "Constant", "Constructor", "Enum", "EnumMember", "Event", "Field", "File", "Function", "Interface", "Key", "Method", "Module", "Namespace", "Null", "Number", "Object", "Operator", "Package", "Property", "String", "Struct", "TypeParameter", "Variable" },
			yaml = { "Array", "Module", "String" },
			json = { "Array", "Module", "String" },
		},
		post_parse_symbol = function(_bufnr, item, _ctx)
			return item.name ~= "callback" and item.name ~= "value"
		end,

		---VISUALS----------------------------------------------------------------
		layout = {
			min_width = vim.o.columns - vim.o.textwidth - 4,
			win_opts = { winhighlight = "Normal:ColorColumn" },
		},
		icons = { Collapsed = "▶" }, -- fix indent

		---OPEN/CLOSE-------------------------------------------------------------
		open_automatic = function(bufnr)
			local narrowWin = vim.api.nvim_win_get_width(0) < vim.o.textwidth
			if narrowWin then return false end
			if vim.bo[bufnr].ft == "yaml" then return false end
			if vim.bo[bufnr].ft == "markdown" then return true end -- always open in markdown

			local symbols = require("aerial").num_symbols(bufnr)
			local smallFile = vim.api.nvim_buf_line_count(bufnr) < 120
			local manySymbols = symbols >= 10
			if symbols == 0 then manySymbols = true end -- FIX closing aerial resulting in 0 for buffer

			return (not smallFile) and manySymbols and not vim.b[bufnr].aerialWasManuallyClosed
		end,
		close_automatic_events = { "switch_buffer", "unfocus", "unsupported" },

		on_attach = function(bufnr)
			vim.api.nvim_create_autocmd("WinClosed", {
				desc = "User: Close aerial when win is closed",
				buffer = bufnr,
				once = true,
				callback = function()
					vim.b[bufnr].aerialWasManuallyClosed = false
					require("aerial").close()
				end,
			})
			-----------------------------------------------------------------------
			vim.keymap.set("n", "<C-j>", vim.cmd.AerialNext, { buffer = bufnr })
			vim.keymap.set("n", "<C-k>", vim.cmd.AerialPrev, { buffer = bufnr })
		end,
	},
}
