-- DOCS https://pandoc.org/lua-filters.html#type-bulletlist

-- DEBUG 
-- pandoc test.md --write=markdown --lua-filter=remove-markdown-tasks.lua
-- pandoc test.md -t native
--------------------------------------------------------------------------------

function BulletList(items)
	local notTasks = {}
	for _, item in ipairs(items.content) do
		local first = item[1] -- not sure yet why needed, probably for nested lists
		if first and first.t == "Plain" then
			local content = pandoc.utils.stringify(first)
			local isTask = content:find("☒") or content:find("☐")
			if not isTask then table.insert(notTasks, first) end
		else
			table.insert(notTasks, first) -- just in case, though I haven't seen those yet
		end
	end
	return pandoc.BulletList(notTasks)
end
