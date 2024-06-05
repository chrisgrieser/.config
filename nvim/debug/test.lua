-- vim.ui.input({
-- 	prompt = "Hello World",
-- 	footer = "foobar",
-- }, function(text) vim.notify(text or "") end)

vim.ui.select({ "one", "two" }, {
	prompt = "Hello World",
	footer = "foobar",
	kind = "codeaction",
}, function(selection)
	if not selection then return end
	vim.notify(selection)
end)
