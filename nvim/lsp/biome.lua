-- PENDING https://github.com/neovim/nvim-lspconfig/pull/3962
--------------------------------------------------------------------------------

return {
	cmd = function(dispatchers, config)
	  local cmd = 'biome'
	  local local_cmd = config and config.root_dir and config.root_dir .. '/node_modules/.bin/biome'
	  if local_cmd and vim.fn.executable(local_cmd) == 1 then
	    cmd = local_cmd
	  end
	  return vim.lsp.rpc.start({ cmd, 'lsp-proxy' }, dispatchers)
	end,
}
