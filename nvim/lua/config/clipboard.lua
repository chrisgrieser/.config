require("config.utils")
--------------------------------------------------------------------------------

-- keep the register clean
Keymap("n", "x", '"_x')
Keymap({ "n", "x" }, "c", '"_c')
Keymap("n", "cc", '"_cc')
Keymap("n", "C", '"_C')
Keymap("x", "p", "P", { desc = "paste without switching register" })

-- do not clutter the register if blank line is deleted
Keymap("n", "dd", function()
	local isBlankLine = Fn.getline("."):find("^%s*$") ---@diagnostic disable-line: param-type-mismatch, undefined-field
	local expr = isBlankLine and '"_dd' or "dd"
	return expr
end, { expr = true })

-- yanking without moving the cursor
Autocmd({ "CursorMoved", "VimEnter" }, {
	callback = function() g.cursorPreYank = GetCursor(0) end,
})

-- - yanking without moving the cursor
-- - highlighted yank
-- - saves yanks in numbered register, so `"1p` pastes previous yanks.
Autocmd("TextYankPost", {
	callback = function()
		-- highlighted yank
		vim.highlight.on_yank { timeout = 1500 }

		-- abort when recording, since this only leads to bugs then
		local isRecording = Fn.reg_recording() ~= ""
		local isPlaying = Fn.reg_executing() ~= ""
		if isRecording or isPlaying then return end

		-- deletion does not need stickiness and also already shifts register, so
		-- only saving the last yank is required
		if vim.v.event.operator == "d" then g.lastYank = Fn.getreg('"') end

		if vim.v.event.operator ~= "y" then return end

		-- sticky yank & delete
		SetCursor(0, g.cursorPreYank)

		-- add yanks and deletes to numbered registers
		if vim.v.event.regname ~= "" then return end
		for i = 8, 2, -1 do
			local regcontent = Fn.getreg(tostring(i))
			Fn.setreg(tostring(i + 1), regcontent)
		end
		Fn.setreg("1", Fn.getreg("0")) -- so both y and d copy to "1
		if g.lastYank then Fn.setreg("2", g.lastYank) end
		g.lastYank = Fn.getreg('"')
	end,
})

-- cycle through the last deletes/yanks ("2 till "9), starting at non-last delete/yank
Keymap("n", "P", function()
	if not g.killringCount then g.killringCount = 2 end
	Cmd.undo()
	Normal('"' .. tostring(g.killringCount) .. "p")
	g.killringCount = g.killringCount + 1
	if g.killringCount > 9 then
		vim.notify("Reached end of killring.")
		g.killringCount = 2
	end
end, { desc = "cycle through killring" })

Keymap("n", "p", function()
	g.killringCount = 2 -- normal pasting resets the killring
	Normal("p")
end, { desc = "paste & reset killring" })

-- paste charwise reg as linewise & vice versa
Keymap("n", "gp", function()
	local reg = "+"
	local regContent = Fn.getreg(reg)
	local isLinewise = Fn.getregtype(reg) == "V"

	local targetRegType
	if isLinewise then
		targetRegType = "v"
		regContent = regContent:gsub("^%s*", ""):gsub("%s*$", "")
	else
		targetRegType = "V"
	end

	Fn.setreg(reg, regContent, targetRegType) ---@diagnostic disable-line: param-type-mismatch
	Normal('"' .. reg .. "p") -- for whatever reason, not naming a register does not work here
	if targetRegType == "V" then Normal("==") end
end, { desc = "paste differently" })
