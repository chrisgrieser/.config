--------------------------------------------------------------------------------
-- INFO if abbreviations are not working, probably something has been mapped to
-- `<Space>` in insert mode
-----------------------------------------------------------------------------------

local spellfixes = {
	teh = "the",
	brwoser = "browser",
	markdwon = "markdown",
	dwon = "down",
	keybaord = "keyboard",
	sicne = "since",
	nto = "not",
	reponse = "response",
	fodler = "folder",
	woudl = "would",
	cleitn = "client",
	fiel = "file",
	shwo = "show",
	hwo = "how",
	tiem = "item",
	seperate = "separate",
	msot = "most",
	retrun = "return",
	onyl = "only",
	esle = "else",
	treu = "true",
	ture = "true",
	terue = "true",
	fo = "of",
	oepn = "open",
	ntoe = "note",
	verison = "version",
	ot = "to",
	ti = "it",
	cant = "can't",
	dont = "don't",
}

for wrong, correct in pairs(spellfixes) do
	-- TODO lua API for abbreviations for nvim 0.10
	-- vim.keymap.set("ia", wrong, correct)
	vim.cmd.inoreabbrev(wrong .. " " .. correct)
end
