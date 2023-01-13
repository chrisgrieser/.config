require("config.utils")
--------------------------------------------------------------------------------
-- New Text objects
-- af -> a [f]unction (treesitter)
-- ao -> a c[o]ndition (treesitter)
-- q -> comment (mnemonic: [q]uiet text) (treesitter)
-- u -> consec[u]tive comment (comments.nvim / custom)
-- aa -> an [a]rgument (treesitter)
-- al -> a cal[l] (treesitter)
-- gh -> [g]it [h]unk (gitsigns.nvim)
-- ai -> an [i]ndentation (custom)
-- ad -> a [d]iagnostic (custom)
-- an -> a [n]umber (custom)
-- n -> [n]ear the [e]nding of line (custom)
-- r -> [r]est of paragraph, linewise (custom)
-- av -> a [v]alue / right side of assignment (custom)
-- ak -> a [k]ey / left side of assignment (custom)
-- aL -> a [L]oop (treesitter)
-- <Space> -> inner subword (custom)
-- ge -> diagnostic (custom)
-- o -> c[o]lumn (custom)

-- FILE-TYPE-SPECIFIC TEXT OBJECTS
-- al: a [l]ink (markdown, custom) → overwrites in markdown unused call textobj
-- as: a [s]elector (css, custom) → overwrites in css unused sentence textobj
-- a/: a regex (js/ts, custom)
-- aE: a Cod(e) block (markdown, custom, mnemonic: big cod[e])
-- aR: a Double Square Brackets (custom, mnemonic: big [r]ectangular bracket)

-- BUILTIN ONES KEPT
-- ab: bracket
-- as: sentence
-- ap: paragraph
-- aw: word

-- REMAPPING OF BUILTIN TEXT OBJECTS
keymap({ "o", "x" }, "iq", 'i"') -- [q]uote
keymap({ "o", "x" }, "aq", 'a"')
keymap({ "o", "x" }, "iz", "i'") -- [z]ingle quote
keymap({ "o", "x" }, "az", "a'")
keymap({ "o", "x" }, "ae", "a`") -- t[e]mplate-string / inline cod[e]
keymap({ "o", "x" }, "ie", "i`")
keymap({ "o", "x" }, "ir", "i]") -- [r]ectangular brackets
keymap({ "o", "x" }, "ar", "a]")
keymap({ "o", "x" }, "ic", "i}") -- [c]urly brackets
keymap({ "o", "x" }, "ac", "a}")
keymap({ "o", "x" }, "am", "aW") -- [m]assive word
keymap({ "o", "x" }, "im", "iW")

--------------------------------------------------------------------------------
-- QUICK TEXTOBJ OPERATIONS
keymap("n", "<Space>", '"_ciw', { desc = "change word" })
keymap("n", "<M-S-CR>", 'daw', { desc = "delete word" }) -- HACK since <S-Space> not fully supported, requires karabiner remapping it
keymap("i", "<M-S-CR>", '<Space>') -- prevent accidental triggering in insert mode when typing quickly

--------------------------------------------------------------------------------
-- VARIOUS TEXTOBJS
-- stylua: ignore start

-- space: subword
keymap({"o", "x"}, "<Space>", function() require("various-textobjs").subword(true) end, { desc = "inner subword textobj" })

-- L: link
keymap({ "o", "x" }, "L", function() require("various-textobjs").url() end, { desc = "link textobj" })

-- n: [n]ear end of the line
keymap({ "o", "x" }, "n", function() require("various-textobjs").nearEoL() end, { desc = "near EoL textobj" })

-- o: c[o]lumn textobj
keymap("o", "o", function() require("various-textobjs").column() end, { desc = "column textobj" })

-- gG: entire buffer textobj
keymap( { "x", "o" }, "gG", function() require("various-textobjs").entireBuffer() end, { desc = "entire buffer textobj" })

-- r: [r]est of paragraph (linewise)
-- INFO not setting in visual mode, to keep visual block mode replace
keymap( "o", "r", function() require("various-textobjs").restOfParagraph() end, { desc = "rest of paragraph textobj" })

-- iv/av: value textobj
keymap({ "x", "o" }, "iv", function() require("various-textobjs").value(true) end, { desc = "inner value textobj" })
keymap({ "x", "o" }, "av", function() require("various-textobjs").value(false) end, { desc = "outer value textobj" })

-- ik/ak: value textobj
keymap({ "x", "o" }, "ik", function() require("various-textobjs").key(true) end, { desc = "inner key textobj" })
keymap({ "x", "o" }, "ak", function() require("various-textobjs").key(false) end, { desc = "outer key textobj" })

-- ge: diagnostic textobj (similar to ge for the next diagnostic)
keymap({ "x", "o" }, "ge", function() require("various-textobjs").diagnostic() end, { desc = "diagnostic textobj" })

-- in/an: number textobj
keymap( { "x", "o" }, "in", function() require("various-textobjs").number(true) end, { desc = "inner number textobj" })
keymap( { "x", "o" }, "an", function() require("various-textobjs").number(false) end, { desc = "outer number textobj" })

-- iR/aR: double square brackets
keymap( { "x", "o" }, "iR", function() require("various-textobjs").doubleSquareBrackets(true) end, { desc = "inner double square bracket" })
keymap( { "x", "o" }, "aR", function() require("various-textobjs").doubleSquareBrackets(false) end, { desc = "outer double square bracket" })

-- ii/ai: indentation textobj
keymap({ "x", "o" }, "ii", function() require("various-textobjs").indentation(true, true) end, { desc = "inner indent textobj" })
keymap({ "x", "o" }, "ai", function() require("various-textobjs").indentation(false, false) end, { desc = "outer indent textobj" })

augroup("IndentedFileTypes", {})
autocmd("FileType", {
	group = "IndentedFileTypes",
	callback = function()
		local indentedFts = { "python", "yaml", "markdown" }
		if vim.tbl_contains(indentedFts, bo.filetype) then
			keymap( { "x", "o" }, "ai", function() require("various-textobjs").indentation(false, true) end, { buffer = true, desc = "indent textobj w/ start border" })
		end
	end,
})

-- Git Hunks
keymap({ "x", "o" }, "gh", ":Gitsigns select_hunk<CR>", { desc = "hunk textobj" })

-- stylua: ignore end
--------------------------------------------------------------------------------
-- SURROUND
-- need to be consistent with the text obj mappings above
local functionObjChar = "f"
local conditionObjChar = "o"
local callObjChar = "l"
local doubleSquareBracketObjChar = "R"
local regexObjChar = "/"

-- HACK define these manually, since for some reason they do not work by default
keymap("n", "yss", "ys_", { remap = true, desc = "surround line" })
keymap("n", "yS", "ys$", { remap = true, desc = "surround till EoL" })

local config = require("nvim-surround.config")

-- https://github.com/kylechui/nvim-surround/blob/main/doc/nvim-surround.txt#L483
require("nvim-surround").setup {
	aliases = { -- aliases should match the bindings for text objects
		["b"] = ")",
		["c"] = "}",
		["r"] = "]",
		["q"] = '"',
		["z"] = "'",
		["e"] = "`",
	},
	move_cursor = false,
	keymaps = {
		normal_cur = "<Nop>", -- mapped on my own (see above)
		normal_line = "<Nop>", -- mapped on my own (see above)
		normal_cur_line = "<Nop>",
		visual = "s",
	},
	surrounds = {
		[doubleSquareBracketObjChar] = {
			find = "%[%[.-%]%]",
			add = { "[[", "]]" },
			delete = "(%[%[)().-(%]%])()",
			change = {
				target = "(%[%[)().-(%]%])()",
			},
		},
		[regexObjChar] = {
			find = "/.-/",
			add = { "/", "/" },
			delete = "(/)().-(/)()",
			change = {
				target = "(/)().-(/)()",
			},
		},
		[functionObjChar] = {
			find = function() return config.get_selection { motion = "a" .. functionObjChar } end,
			delete = function()
				local ft = bo.filetype
				local patt
				if ft == "lua" then
					patt = "^(.-function.-%b() ?)().-( ?end)()$"
				elseif
					ft == "javascript"
					or ft == "typescript"
					or ft == "bash"
					or ft == "zsh"
					or ft == "sh"
				then
					patt = "^(.-function.-%b() ?{)().*(})()$"
				else
					vim.notify("No function-surround defined for " .. ft, logWarn)
					patt = "()()()()"
				end
				return config.get_selections {
					char = functionObjChar,
					pattern = patt,
				}
			end,
			add = function()
				local ft = bo.filetype
				if ft == "lua" then
					return {
						{ "function ()", "\t" },
						{ "", "end" },
					}
				elseif
					ft == "typescript"
					or ft == "javascript"
					or ft == "bash"
					or ft == "zsh"
					or ft == "sh"
				then
					return {
						{ "function () {", "\t" },
						{ "", "}" },
					}
				end
				vim.notify("No function-surround defined for " .. ft, logWarn)
				return { { "" }, { "" } }
			end,
		},
		[callObjChar] = {
			find = function() return config.get_selection { motion = "a" .. callObjChar } end,
			delete = "^([^=%s]+%()().-(%))()$", -- https://github.com/kylechui/nvim-surround/blob/main/doc/nvim-surround.txt#L357
		},
		[conditionObjChar] = {
			find = function() return config.get_selection { motion = "a" .. conditionObjChar } end,
			delete = function()
				local ft = bo.filetype
				local patt
				if ft == "lua" then
					patt = "^(if .- then)().-( ?end)()$"
				elseif ft == "javascript" or ft == "typescript" then
					patt = "^(if %b() ?{?)().-( ?}?)()$"
				else
					vim.notify("No conditional-surround defined for " .. ft, logWarn)
					patt = "()()()()"
				end
				return config.get_selections {
					char = conditionObjChar,
					pattern = patt,
				}
			end,
			add = function()
				local ft = bo.filetype
				if ft == "lua" then
					return {
						{ "if true then", "\t" },
						{ "", "end" },
					}
				elseif ft == "typescript" or ft == "javascript" then
					return {
						{ "if (true) {", "\t" },
						{ "", "}" },
					}
				end
				vim.notify("No if-surround defined for " .. ft, logWarn)
				return { { "" }, { "" } }
			end,
		},
	},
}
