local M = {}
--------------------------------------------------------------------------------

-- TOGGLE LANGUAGE
-- not done via Karabiner, since setting input method there is buggy: https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/to/select-input-source/

hs.hotkey.bind({ "option", "control" }, "j", function()
	-- Japanese defined by METHOD, Latin languages by LAYOUT
	local isJapanese = hs.keycodes.currentMethod() ~= nil
	if isJapanese then
		hs.keycodes.setLayout("German")
	else
		hs.keycodes.setMethod("Hiragana")
	end
end)

--------------------------------------------------------------------------------
return M
