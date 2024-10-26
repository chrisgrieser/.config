local ok, node = pcall(vim.treesitter.get_node)
if not (ok and node) then return end

while true do
	local text = vim.treesitter.get_node_text(node, 0)
	
end
vim.notify("🖨️ text: " .. tostring(text))
