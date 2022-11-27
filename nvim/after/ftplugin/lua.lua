require("utils")
--------------------------------------------------------------------------------

-- add EmmyLua annotations when in hammerspoon directory
if vim.fn.expand("%:p"):find("hammerspoon") then
	vim.lsp.buf.add_workspace_folder(os.getenv("HOME") .. "/.hammerspoon/Spoons/EmmyLua.spoon/annotations")
-- add nvim-config folder when in nvim directory
elseif fn.expand("%:p"):find("nvim") then
	vim.lsp.buf.add_workspace_folder(vim.fn.stdpath("config"))
end
