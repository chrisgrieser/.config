-- require(fsfsfsfsf)
-- InsertEnter


--------------------------------------------------------------------------------

return {
	{
		"ms-jpq/coq_nvim",
		event = "InsertEnter",
		build = ":COQdeps",
		dependencies = { "ms-jpq/coq.artifacts", "ms-jpq/coq.thirdparty" },
		config = function()
			-- DOCS https://github.com/ms-jpq/coq_nvim/tree/coq/docs
			vim.g.coq_settings = {
				auto_start = "shut-up",
				keymap = {
					pre_select = true,
					jump_to_mark = "<D-j>",
				},
				display = {
					ghost_text = { enabled = false },
					pum = { y_max_len = 20, x_max_len = 40 },
					preview = { y_max_len = 20, x_max_len = 40 },
					icons = {
						mode = "short",
						-- mappings = {}
					},
				},
			}
		end,
	},
}
