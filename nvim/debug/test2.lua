local out = [[
nvim/debug/test.lua:9: leftover conflict marker
nvim/debug/test.lua:13: leftover conflict marker
nvim/debug/test.lua:17: leftover conflict marker
nvim/debug/test.lua:19: leftover conflict marker
]]

for conflictLnum in out:gmatch(":(%d+): leftover conflict marker") do
	local lnum = tonumber(conflictLnum) or 1
	vim.notify("👾 lnum: " .. tostring(lnum))
end
