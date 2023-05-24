--------------------------------------------------------------------------------
-- WARN do not save this file, or codespell will fix all misspellings 🙈
--------------------------------------------------------------------------------
-- INFO if abbreviations are not working, probably something has been mapped to 
-- in insert `<Space>`
-----------------------------------------------------------------------------------

local spellfixes = {
	teh = "the",
	keybaord = "keyboard",
	sicne = "since",
	nto = "not",
	shwo = "show",
	retrun = "return",
	onyl = "only",
	esle = "else",
	treu = "true",
	ture = "true",
	fo = "of",
	dwon = "down",
	ntoe = "note",
}

for wrong, correct in pairs(spellfixes) do
	vim.cmd.inoreabbrev(wrong .. " "  .. correct)
end
