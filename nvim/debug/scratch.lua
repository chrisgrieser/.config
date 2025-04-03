vim.ui.select({"a", "b"}, {
	prompt = "prompt_text",
}, function (selection)
	if not selection then return end
	
end)
