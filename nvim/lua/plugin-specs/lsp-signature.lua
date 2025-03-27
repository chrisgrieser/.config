return {
	"ray-x/lsp_signature.nvim",

	-- broken since nvim 0.11 PENDING https://github.com/ray-x/lsp_signature.nvim/issues/354
	enabled = false,

	event = "BufReadPre",
	opts = {
		hint_prefix = " 󰏪 ",
		hint_scheme = "Todo",
		floating_window = false,
		always_trigger = true,
	},
}
