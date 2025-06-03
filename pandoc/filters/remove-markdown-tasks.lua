function BulletList(items)
	local new_items = {}

	-- filter out task list items from BulletLists
	for _, item in ipairs(items) do
		local first_elem = item[1]
		if first_elem.t == "Para" and first_elem.c[1].t == "Str" then
			local text = pandoc.utils.stringify(first_elem)
			if not text:match("^%[.%]%s") then table.insert(new_items, item) end
		else
			table.insert(new_items, item)
		end
	end

	if #new_items == 0 then return nil end

	return pandoc.BulletList(new_items)
end
