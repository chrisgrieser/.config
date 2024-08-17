local s = [[
	hello world from #Lua"
	fix: 33
	feat: 1111
]]
for w in string.gmatch(s, "#(%d+)") do
  vim.notify(w)
end
