--------------------------------------------------------------------------------
-- INFO if abbreviations are not working, probably something has been mapped to
-- `<Space>` in insert mode
-----------------------------------------------------------------------------------

local spellfixes = {
	teh = "the",
	THe = "The",
	curosr = "cursor",
	defualt = "default",
	brwoser = "browser",
	markdwon = "markdown",
	dwon = "down",
	keybaord = "keyboard",
	sicne = "since",
	ignroe = "ignore",
	nto = "not",
	reponse = "response",
	nromal = "normal",
	fodler = "folder",
	woudl = "would",
	cleitn = "client",
	fiel = "file",
	shwo = "show",
	hwo = "how",
	tiem = "item",
	ahve = "have",
	seperate = "separate",
	seperator = "separator",
	msot = "most",
	retrun = "return",
	onyl = "only",
	esle = "else",
	treu = "true",
	ture = "true",
	flase = "false",
	fales = "false",
	fo = "of",
	oepn = "open",
	ntoe = "note",
	verison = "version",
	ot = "to",
	ti = "it",
	cant = "can't",
	dont = "don't",
	doestn = "doesn't",
	doesnt = "doesn't",
}

for wrong, correct in pairs(spellfixes) do
	-- TODO lua API for abbreviations for nvim 0.10
	-- vim.keymap.set("ia", wrong, correct)
	vim.cmd.inoreabbrev(wrong .. " " .. correct)
end
