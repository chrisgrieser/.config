

local pattern = "(hsl%()[%%%d,/deg ]+(%))"

local sample = "hsl(123%, 123, 123 / 0)"

local match = sample:match(pattern)
vim.notify("👽 match: " .. vim.inspect(match))

