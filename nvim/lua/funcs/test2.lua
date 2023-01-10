
local marks = { "A", "B" }
local globalMarks = fn.getmarklist()
globalMarks = vim.tbl_filter(
	function(item) return vim.tbl_contains(marks, item.mark:sub(2, 2)) end,
	globalMarks
)
vim.pretty_print(globalMarks)
