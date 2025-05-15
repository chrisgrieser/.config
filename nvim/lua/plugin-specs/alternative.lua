return {
	"Goose97/alternative.nvim",

	keys = { "+", "ü" },
	opts = {
		rules = {
			-- DOCS https://github.com/linduxed/alternative.nvim/tree/missing-custom-utils?tab=readme-ov-file#built-in-rules
			"general.boolean_flip",
			"general.number_increment_decrement",
			"general.compare_operator_flip",
			"javascript.if_condition_flip",
			"javascript.ternary_to_if_else",
			["javascript.function_definition_variants"] = { preview = false },
			["javascript.arrow_function_implicit_return"] = { preview = false },
			"typescript.function_definition_variants",
			"lua.if_condition_flip",
			["lua.ternary_to_if_else"] = { preview = false },
		},
		keymaps = {
			alternative_next = "+",
			alternative_prev = "ü", -- next to `+` on German keyboard
		},
	},
}
