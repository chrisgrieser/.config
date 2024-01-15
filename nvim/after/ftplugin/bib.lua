-- Vim filetype plugin file
-- Language: BibTeX (ft=bib)
-- Author: Chris Grieser <grieser.chris@gmail.com>
-- Latest Revision: 2024-01-15

if vim.b.did_ftplugin == 1 then
	return
end
vim.b.did_ftplugin = 1 ---@diagnostic disable-line: inject-field
vim.b.undo_ftplugin = "setlocal comments< commentstring< formatoptions<" ---@diagnostic disable-line: inject-field

vim.bo.commentstring = "% %s"
vim.bo.comments = ":%"
vim.opt_local.formatoptions:append { r = true, o = true }
