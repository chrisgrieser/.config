vim.opt.foldlevel = 3

--------------------------------------------------------------------------------

Bufmap { "<leader>rp", "<cmd>%! jq .<CR>", desc = " Prettify Buffer" }
Bufmap { "<leader>rm", "<cmd>%! jq --compact-output .<CR>", desc = " Minify Buffer" }
Bufmap {
	"o",
	function()
		local line = vim.api.nvim_get_current_line()
		if line:find("[^,{[]$") then return "A,<cr>" end
		return "o"
	end,
	expr = true,
	desc = " Auto-add comma on `o`",
}
