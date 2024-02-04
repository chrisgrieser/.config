local pattern = "{.-[^%d,%s].-}"

local sample = "bla {t} fsf"

local match = sample:match(pattern)
vim.notify("👽 match: " .. vim.inspect(match))
