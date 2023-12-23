local query = vim.treesitter.query.parse(
	"markdown",
	[[
		(fenced_code_block) @codeblock

		(block_quote_marker) @quote
		(block_quote (paragraph (inline (block_continuation) @quote)))
		(block_quote (paragraph (block_continuation) @quote))
		(block_quote (block_continuation) @quote)
	]]
)
vim.notify("🪚 query: " .. tostring(query))
