---@module "lazy.types"
---@type LazyPluginSpec
return {
	"davidosomething/format-ts-errors.nvim",
	opts = {
		add_markdown = true,
		start_indent_level = 0,
	},
	config = function (_, opts)
		require("format-ts-errors").setup(opts)

		vim.lsp.config("ts_ls", {
			handlers = {
				["textDocument/publishDiagnostics"] = function() 
					:map(function(diag)
					local formatter = require("format-ts-errors")[diag.code]
					if formatter then diag.message = formatter(diag.message) end
					return diag
				end)
				end,
			}
		})
	end
}
