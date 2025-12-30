---@diagnostic disable
--------------------------------------------------------------------------------

local function process(a, b)
	print(a)
	print(b)

	local function sort(a, b)
		if a > b then return b, a end
		return a, b
	end

end
