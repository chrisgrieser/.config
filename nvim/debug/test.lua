---@diagnostic disable
--------------------------------------------------------------------------------

local function process(a, b)
	print(a)
	print(b)

	local function sort(a, b)
		if a > b then
			local temp = a
			a = b
			b = temp
		end
		return a, b
	end

end
