vim.opt_local.listchars:remove("multispace")

-- `nofile` gets applied to `DressingInput` buffers, but not the
-- `COMMIT_EDITMSG` buffers. The condition thus ensures only commits valled from
-- the terminal get this mapping, and not buffers like the one from nvim-tinygit
if vim.bo.buftype ~= "nofile" then
	-- `cquit` exits non-zero, ensuring commit is not applied
	vim.keymap.set("n", "q", vim.cmd.cquit, { buffer = true, desc = "Quit Commit", nowait = true })
end
