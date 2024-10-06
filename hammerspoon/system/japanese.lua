local M = {}
local wu = require("win-management.window-utils")
local wf = hs.window.filter
--------------------------------------------------------------------------------

-- TOGGLE LANGUAGE
-- not done via Karabiner, since setting input method there is buggy: https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/to/select-input-source/

hs.hotkey.bind({ "option" }, "space", function()
	-- Japanese defined by METHOD, Latin languages by LAYOUT
	local isJapanese = hs.keycodes.currentMethod() ~= nil
	if isJapanese then
		hs.keycodes.setLayout("German")
	else
		hs.keycodes.setMethod("Hiragana")
	end
end)

--------------------------------------------------------------------------------
-- ANKI

M.wf_anki = wf.new("Anki"):subscribe(wf.windowCreated, function(newWin)
	local size = newWin:title() == "Add" and wu.center or wu.pseudoMax
	wu.moveResize(newWin, size)
end)

--------------------------------------------------------------------------------
return M
