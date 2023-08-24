--------------------------------------------------------------------------------
-- WARN do not save this file, or codespell will fix all misspellings 🙈
--------------------------------------------------------------------------------
-- INFO if abbreviations are not working, probably something has been mapped to 
-- in insert `<Space>`
-----------------------------------------------------------------------------------

local spellfixes = {
	teh = "the",
	keyboard = "keyboard",
	since = "since",
	nto = "not",
	response = "response",
	fodler = "folder",
	would = "would",
	fiel = "file",
	show = "show",
	return = "return",
	only = "only",
	else = "else",
	treu = "true",
	ture = "true",
	terue = "true",
	fo = "of",
	oepn = "open",
	dwon = "down",
	ntoe = "note",
	version = "version",
	ot = "to",
	ti = "it",
	["can't"] = "can't",
	dont = "don't",
}

for wrong, correct in pairs(spellfixes) do
	-- TODO lua API for abbreviations in the next version https://www.reddit.com/r/neovim/comments/145pkj0/today_on_nightly_we_now_have_a_formal_lua_api_to/
	vim.cmd.inoreabbrev(wrong .. " "  .. correct)
end
