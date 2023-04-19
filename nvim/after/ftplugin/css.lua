local autocmd = vim.api.nvim_create_autocmd
local bo = vim.bo
local cmd = vim.cmd
local expand = vim.fn.expand
local fn = vim.fn
local keymap = vim.keymap.set
local u = require("config.utils")
--------------------------------------------------------------------------------

-- stylua: ignore start
keymap({ "o", "x" }, "is", "<cmd>lua require('various-textobjs').cssSelector(true)<CR>", { desc = "inner CSS Selector textobj", buffer = true })
keymap({ "o", "x" }, "as", "<cmd>lua require('various-textobjs').cssSelector(false)<CR>", { desc = "outer CSS Selector textobj", buffer = true })

keymap({ "o", "x" }, "ix", "<cmd>lua require('various-textobjs').htmlAttribute(true)<CR>", { desc = "inner HTML Attribute textobj", buffer = true })
keymap({ "o", "x" }, "ax", "<cmd>lua require('various-textobjs').htmlAttribute(false)<CR>", { desc = "outer HTML Attribute textobj", buffer = true })
-- stylua: ignore end

-- toggle !important
keymap("n", "<leader>i", function()
	local lineContent = fn.getline(".")
	if lineContent:find("!important") then
		lineContent = lineContent:gsub(" !important", "")
	else
		lineContent = lineContent:gsub(";", " !important;")
	end
	fn.setline(".", lineContent) ---@diagnostic disable-line: param-type-mismatch
end, { buffer = true, desc = "toggle !important" })

--------------------------------------------------------------------------------

-- extra trigger for auto-saving to work with hot reloads
autocmd("TextChanged", {
	buffer = 0, -- buffer-local autocmd
	callback = function() cmd.update(expand("%:p")) end,
})

--------------------------------------------------------------------------------
-- SHIMMERING FOCUS SPECIFIC

if expand("%:t") == "source.css" then
	-- goto comment marks (deferred, to override lsp-gotosymbol)
	vim.defer_fn(function()
		bo.grepprg = "rg --vimgrep --no-column" -- remove columns for readability
		keymap("n", "gs", function()
			cmd([[silent! lgrep "^(\# <<\|/\* <)" %]]) -- riggrep-search for navigaton markers in SF
			require("telescope.builtin").loclist {
				prompt_title = "Navigation Markers",
			}
		end, { desc = "Search Navigation Markers", buffer = true })
		-- search only for variables
		keymap("n", "gS", function()
			cmd([[silent! lgrep "^\s*--" %]]) -- riggrep-search for css variables
			require("telescope.builtin").loclist {
				prompt_title = "CSS Variables",
				prompt_prefix = "",
			}
		end, { desc = "Search CSS Variables", buffer = true })
	end, 300)

	-- next/prev comment marks
	keymap(
		{ "n", "x" },
		"<C-j>",
		[[/^\/\* <<CR>:nohl<CR>]],
		{ buffer = true, desc = "next comment mark" }
	)
	keymap(
		{ "n", "x" },
		"<C-k>",
		[[?^\/\* <<CR>:nohl<CR>]],
		{ buffer = true, desc = "prev comment mark" }
	)

	-- create comment mark
	keymap("n", "qw", function()
		local hr = {
			"/* ───────────────────────────────────────────────── */",
			"/* << ",
			"──────────────────────────────────────────────────── */",
			"",
			"",
		}
		fn.append(".", hr) ---@diagnostic disable-line undefined-field, param-type-mismatch
		local lineNum = u.getCursor(0)[1] + 2
		local colNum = #hr[2] + 2
		u.setCursor(0, { lineNum, colNum })
		cmd.startinsert { bang = true }
	end, { buffer = true })

	-- INFO: fix syntax highlighting
	-- various other solutions are described here: https://github.com/vim/vim/issues/2790
	-- using treesitter, this is less of an issue, but treesitter css
	-- highlighting isn't good yet, so…
	keymap("n", "zz", ":syntax sync fromstart<CR>", { buffer = true })
end
