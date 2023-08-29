--------------------------------------------------------------------------------
-- WARN do not save this file, or codespell will fix all misspellings 🙈
--------------------------------------------------------------------------------
-- INFO if abbreviations are not working, probably something has been mapped to 
-- in insert `<Space>`
-----------------------------------------------------------------------------------

local spellfixes = {
	teh = "the",
	markdwon = "markdown",
	keybaord = "keyboard",
	sicne = "since",
	nto = "not",
	reponse = "response",
	fodler = "folder",
	woudl = "would",
	fiel = "file",
	shwo = "show",
	retrun = "return",
	onyl = "only",
	esle = "else",
	treu = "true",
	ture = "true",
	terue = "true",
	fo = "of",
	oepn = "open",
	dwon = "down",
	ntoe = "note",
	verison = "version",
	ot = "to",
	ti = "it",
	cant = "can't",
	dont = "don't",
}

for wrong, correct in pairs(spellfixes) do
	-- TODO lua API for abbreviations in the next version https://www.reddit.com/r/neovim/comments/145pkj0/today_on_nightly_we_now_have_a_formal_lua_api_to/
	vim.cmd.inoreabbrev(wrong .. " "  .. correct)
end
