local words = {}
local dictPath = vim.g.linterConfigs .. "/spellfile-vim-ltex.ad" 
for word in io.lines(dictPath) do
	table.insert(words, word)
end
print(vim.inspect(words))
