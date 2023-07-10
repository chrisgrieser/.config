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
	terue = "true",
	fo = "of",
	dwon = "down",
	ntoe = "note",
	verison = "version",
	ot = "to",
	cant = "can't",
}

for wrong, correct in pairs(spellfixes) do
	-- TODO lua API for abbreviations in the next version https://www.reddit.com/r/neovim/comments/145pkj0/today_on_nightly_we_now_have_a_formal_lua_api_to/
	vim.cmd.inoreabbrev(wrong .. " "  .. correct)
end
