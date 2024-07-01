local M = {}
local inlayHintNs = vim.api.nvim_create_namespace("lspEndhints")
--------------------------------------------------------------------------------

---@param userConfig? LspEndhints.config
function M.setup(userConfig)
	require("lsp-endhints.config").setup(userConfig)
	require("lsp-endhints.override-handler")(inlayHintNs)

	local config = require("eol-lsp-hints.config").config
	if config.autoEnableHints then autoEnableHints() end
end

--------------------------------------------------------------------------------
return M
