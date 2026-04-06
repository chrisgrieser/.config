local qol = require("personal-plugins.md-qol")

---OPTIONS----------------------------------------------------------------------
vim.opt_local.expandtab = true
vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4
vim.opt_local.commentstring = "<!-- %s -->" -- add spaces

-- so two trailing spaces are highlighted, but not a single trailing space
vim.opt_local.listchars:remove("trail")
vim.opt_local.listchars:append { multispace = "·" }

-- hard-wrap when typing beyond `textwidth`
vim.schedule(function() vim.opt_local.formatoptions:append("t") end)

---ABBREVIATIONS----------------------------------------------------------------
BufAbbr("->", "→")

---ADD TITLE TO URLS------------------------------------------------------------
Bufmap {
	"p",
	function()
		require("personal-plugins.md-qol").addTitleToUrlIfMarkdown("+")
		return "]p" -- `]p` pastes and indents
	end,
	desc = "󰍔 Paste (+ add title if URL)",
	expr = true,
}
Bufmap { "<leader>cu", qol.addTitleToUrl, desc = "󰍔 Add title to URL" }

---AUTO-BULLET------------------------------------------------------------------
Bufmap { "o", function() qol.autoBullet("o") end, desc = "󰍔 Auto-bullet o" }
Bufmap { "O", function() qol.autoBullet("O") end, desc = "󰍔 Auto-bullet O" }
Bufmap { "<CR>", function() qol.autoBullet("<CR>") end, mode = "i", desc = "󰍔 Auto-bullet <CR>" }

---FORMATTING-------------------------------------------------------------------
-- stylua: ignore
Bufmap { "<D-u>", function() qol.cycle("list") end, mode = { "n", "x", "i" }, desc = "󰍔 Cycle list types" }
-- stylua: ignore
Bufmap { "<D-x>", function() qol.cycle("task") end, mode = { "n", "x", "i" }, desc = "󰍔 Cycle task states" }
Bufmap { "<D-k>", function() qol.wrap("mdlink") end, mode = { "n", "x", "i" }, desc = "󰍔 Link" }
Bufmap { "<D-b>", function() qol.wrap("**") end, mode = { "n", "x", "i" }, desc = "󰍔 Bold" }
Bufmap { "<D-i>", function() qol.wrap("*") end, mode = { "n", "x", "i" }, desc = "󰍔 Italic" }
Bufmap { "<D-e>", function() qol.wrap("`") end, mode = { "n", "x", "i" }, desc = "󰍔 Inline code" }

---HEADINGS---------------------------------------------------------------------
Bufmap { "<C-j>", "]]", desc = "󰍔 Next heading", remap = true } -- remap, since using filetype-mapping
Bufmap { "<C-k>", "[[", desc = "󰍔 Prev heading", remap = true }

-- <D-h> remapped to <D-5>, since used by macOS PENDING https://github.com/neovide/neovide/issues/3099
Bufmap {
	"<D-5>",
	function() qol.incrementHeading(1) end,
	mode = { "n", "i" },
	desc = "󰍔 Heading++",
}
Bufmap {
	"<D-H>",
	function() qol.incrementHeading(-1) end,
	mode = { "n", "i" },
	desc = "󰍔 Heading--",
}

---MISC-------------------------------------------------------------------------
Bufmap { "<leader>ep", qol.previewViaPandoc, desc = "󰍔 Preview" }
Bufmap { "gx", qol.followMdlinkOrWikilink, desc = "󰍔 Follow URL/Wikilink" }

-- `hyper` gets registered by neovide as `cmd+ctrl` (`<D-C-`)
Bufmap { "<D-C-e>", qol.codeBlockFromClipboard, mode = { "n", "i" }, desc = "󰍔 Codeblock" }

Bufmap {
	"<D-L>",
	function()
		local path = vim.api.nvim_buf_get_name(0)
		local uri = "obsidian://open?path=" .. vim.uri_encode(path)
		vim.ui.open(uri)
	end,
	desc = "󰍔 Open in Obsidian",
}

-- aliases frontmatter
Bufmap {
	"<leader>ra",
	function()
		local toInsert = { "aliases:", "  - " }
		qol.insertFrontmatter(toInsert)
	end,
	desc = "󰍔 Add aliases frontmatter",
}

--------------------------------------------------------------------------------
