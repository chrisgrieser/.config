
local M = {}
local inlayHintNs = vim.api.nvim_create_namespace("lspEndhints")
--------------------------------------------------------------------------------

---@param userConfig? LspEndhints.config
function M.setup(userConfig)
	require("lsp-endhints.config").setup(userConfig)
	require("lsp-endhints.override-handler")(inlayHintNs)
<<<<<<< HEAD

	local config = require("eol-lsp-hints.config").config
	if config.autoEnableHints then autoEnableHints() end
||||||| parent of c36ed92 (refactor: auto-enable as separate module)

	local config = require("lsp-endhints.config").config
	if config.autoEnableHints then autoEnableHints() end
=======
	require("lsp-endhints.auto-enable")(inlayHintNs)
>>>>>>> c36ed92 (refactor: auto-enable as separate module)
end

--------------------------------------------------------------------------------
return M
