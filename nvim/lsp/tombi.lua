-- DEBUGGING for https://github.com/tombi-toml/tombi/issues/772#issuecomment-3154428810

---@type vim.lsp.Config
local c = {
	cmd_env = { NO_COLOR = 1 },
	cmd = { "tombi", "lsp", "-v" },
}

return c
