-- https://new.reddit.com/r/neovim/comments/1ehidxy/you_can_remove_padding_around_neovim_instance/
-- https://github.com/neovim/neovim/issues/16572#issuecomment-1954420136
--------------------------------------------------------------------------------

local hasCommentsParser, urlCommentsQuery =
	pcall(vim.treesitter.query.parse, "comment", "(uri) @string.special.url")
if not hasCommentsParser then return end

local rootTree = vim.treesitter.get_parser(0):parse()[1]:root()
local commentUrlIter = urlCommentsQuery:iter_captures(rootTree, 0)
vim.iter(commentUrlIter):each(function(_, node)
	Chainsaw(node:type()) -- 🪚
end)

