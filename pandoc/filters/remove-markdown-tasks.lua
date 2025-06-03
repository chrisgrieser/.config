function BulletList(items)
	local new_items = {}

	for _, item in pairs(items) do
		if item and type(item) ~= "function" then
			local para = item[1]
			local content = pandoc.utils.stringify(para)

			-- Remove task items that start with a checkbox
			if not content:match("^%s*%[.?%]%s") then table.insert(new_items, item) end
		end
	end

	if #new_items == 0 then return nil end

	return pandoc.BulletList(new_items)
end
