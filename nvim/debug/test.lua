-- DOCS https://github.com/nvim-treesitter/nvim-treesitter#adding-queries
-- https://stackoverflow.com/questions/78714013/flutter-web-shows-a-gray-screen-in-hosting-only-without-any-error-in-debug-or-re

local icons = {
	github = " ",
	twitter = " ",
	youtube = " ",
	discord = " ",
	slack = " ",
	stackoverflow = "󰓌 ",
}

vim.keymap.set("n", "<leader>t", function()
	-- REQUIRED comment parser, `:TSInstall comment`
	local faviconNs = vim.api.nvim_create_namespace("favicon")
	vim.api.nvim_buf_clear_namespace(0, faviconNs, 0, -1)
	local urlNodes = {}
	local query = vim.treesitter.query.parse("comment", "(uri) @string.special.url")
	local ltree = vim.treesitter.get_parser(0)
	ltree:for_each_tree(function(tstree, _)
		local allNodes = query:iter_captures(tstree:root(), 0)
		for _, node in allNodes do
			table.insert(urlNodes, node)
		end
	end)
	vim.iter(urlNodes):each(function(node)
		local nodeText = vim.treesitter.get_node_text(node, 0)
		local host = nodeText:match("^https?://w?w?w?%.?(%w+)")
		local favicon = icons[host]
		if not favicon then return end

		local startRow, startCol = vim.treesitter.get_node_range(node)
		vim.api.nvim_buf_set_extmark(0, faviconNs, startRow, startCol, {
			virt_text = { { favicon, "Comment" } },
			virt_text_pos = "inline",
		})
	end)
end)
