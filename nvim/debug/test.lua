
aut
	local authorInitials = author:find("%s") and author:sub(1, 1) .. author:match("%s(%S)") or author:sub(1, 2)
