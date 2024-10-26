local ok, node = pcall(vim.treesitter.get_node)
if not (ok and node) then return end

local acc = {}
repeat
	table.insert(acc, vim.treesitter.get_node_text(node, 0))
	node = node:parent()
until not node
vim.notify("🖨️ acc: " .. vim.inspect(acc))
