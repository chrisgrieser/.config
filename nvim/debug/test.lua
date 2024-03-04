local function one()
	vim.notify(debug.traceback("!!"))
end

local function two()
	one()
end

two()

