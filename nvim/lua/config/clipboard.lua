require("config.utils")
--------------------------------------------------------------------------------

opt.clipboard = "unnamedplus"

-- keep the register clean
keymap("n", "x", '"_x')
keymap({"n", "x"}, "c", '"_c')
keymap("n", "cc", '"_cc')
keymap("n", "C", '"_C')
keymap("x", "p", "P", { desc = "paste without switching register" })

-- do not clutter the register if blank line is deleted
keymap("n", "dd", function()
	local isBlankLine = fn.getline("."):find("^%s*$") ---@diagnostic disable-line: param-type-mismatch, undefined-field
	local expr = isBlankLine and '"_dd' or "dd"
	return expr
end, { expr = true })

-- yanking without moving the cursor
augroup("yankImprovements", {})
autocmd({ "CursorMoved", "VimEnter" }, {
	group = "yankImprovements",
	callback = function() g.cursorPreYank = getCursor(0) end,
})

-- - yanking without moving the cursor
-- - highlighted yank
-- - saves yanks in numbered register, so `"1p` pastes previous yanks.
autocmd("TextYankPost", {
	group = "yankImprovements",
	callback = function()
		-- deletion does not need stickiness and also already shifts register, so
		-- only saving the last yank is required
		if vim.v.event.operator == "d" then g.lastYank = fn.getreg('"') end

		if vim.v.event.operator ~= "y" then return end

		-- highlighted yank
		vim.highlight.on_yank { timeout = 1500 }

		-- sticky yank & delete
		setCursor(0, g.cursorPreYank)

		-- add yanks and deletes to numbered registers
		if vim.v.event.regname ~= "" then return end
		for i = 8, 2, -1 do
			local regcontent = fn.getreg(tostring(i))
			fn.setreg(tostring(i + 1), regcontent)
		end
		fn.setreg("1", fn.getreg("0")) -- so both y and d copy to "1
		if g.lastYank then fn.setreg("2", g.lastYank) end
		g.lastYank = fn.getreg('"')
	end,
})

-- cycle through the last deletes/yanks ("2 till "9), starting at non-last delete/yank
keymap("n", "P", function()
	if not g.killringCount then g.killringCount = 2 end
	cmd.undo()
	normal('"' .. tostring(g.killringCount) .. "p")
	g.killringCount = g.killringCount + 1
	if g.killringCount > 9 then
		vim.notify("Reached end of killring.")
		g.killringCount = 2
	end
end, { desc = "cycle through killring" })

keymap("n", "p", function()
	g.killringCount = 2 -- normal pasting resets the killring
	normal("p")
end, { desc = "paste & reset killring" })

-- paste charwise reg as linewise & vice versa
keymap("n", "gp", function()
	local reg = "+"
	local regContent = fn.getreg(reg)
	local isLinewise = fn.getregtype(reg) == "V"

	local targetRegType
	if isLinewise then
		targetRegType = "v"
		regContent = regContent:gsub("^%s*", ""):gsub("%s*$", "")
	else
		targetRegType = "V"
	end

	fn.setreg(reg, regContent, targetRegType) ---@diagnostic disable-line: param-type-mismatch
	normal('"' .. reg .. "p") -- for whatever reason, not naming a register does not work here
	if targetRegType == "V" then normal("==") end
end, { desc = "paste differently" })
