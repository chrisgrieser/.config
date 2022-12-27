require("config/utils")
local varTextObj = require("various-textobjs")
--------------------------------------------------------------------------------
-- New Text objects
-- af -> a [f]unction (treesitter)
-- ao -> a c[o]ndition (treesitter)
-- q -> comment (mnemonic: [q]uiet text) (treesitter)
-- Q/u -> consecutive comment (comments.nvim / custom)
-- aa -> an [a]rgument (treesitter)
-- al -> a cal[l] (treesitter)
-- ah -> a [h]unk (gitsigns)
-- ai -> an [i]ndentation (custom)
-- ad -> a [d]iagnostic (custom)
-- an -> a [n]umber (custom)
-- n -> near the [e]nding of line (custom)
-- r -> rest of paragraph, linewise (custom)
-- av -> a [v]alue / variable assignment (custom)
-- aL -> a [L]oop (treesitter)
-- <Space> -> inner subword (custom)
-- . -> diagnostic (custom)
-- o -> c[o]lumn (custom)

-- FILE-TYPE-SPECIFIC TEXT OBJECTS
-- al: a [l]ink (markdown, custom) → overwrites unused call textobj
-- as: a [s]elector (css, custom) → overwrites unused sentence textobj
-- aC: a [C]ode block (markdown, custom)
-- aR: a [R]egex (js/ts, custom)
-- aD: a [D]ouble Square Brackets (custom)

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
keymap({ "o", "x" }, "at", "a`") -- [t]emplate-string
keymap({ "o", "x" }, "it", "i`")
keymap({ "o", "x" }, "ir", "i]") -- [r]ectangular brackets
keymap({ "o", "x" }, "ar", "a]")
keymap({ "o", "x" }, "ic", "i}") -- [c]urly brackets
keymap({ "o", "x" }, "ac", "a}")
keymap({ "o", "x" }, "am", "aW") -- [m]assive word
keymap({ "o", "x" }, "im", "iW")

--------------------------------------------------------------------------------
-- QUICK TEXTOBJ OPERATIONS
keymap("n", "C", '"_C')
keymap("n", "<Space>", '"_ciw') -- change word
keymap("n", "<M-S-CR>", '"_daw') -- HACK since <S-Space> not fully supported, requires karabiner remapping it
keymap("x", "<Space>", '"_c')

--------------------------------------------------------------------------------
-- VARIOUS TEXTOBJS

-- space: subword
keymap("o", "<Space>", function() varTextObj.subword(true) end, { desc = "inner subword textobj" })

-- n: [n]ear end of the line
keymap({ "o", "x" }, "n", varTextObj.nearEoL, { desc = "almost ending of line textobj" })

-- o: c[o]lumn textobj
keymap("o", "o", varTextObj.column, { desc = "column textobj" })

-- r: [r]est of paragraph (linewise)
-- INFO not setting in visual mode, to keep visual block mode replace
keymap("o", "r", varTextObj.restOfParagraph, { desc = "rest of paragraph (linewise)" })

-- iv/av: value textobj
keymap({ "x", "o" }, "iv", function() varTextObj.value(true) end, { desc = "inner value textobj" })
keymap({ "x", "o" }, "av", function() varTextObj.value(false) end, { desc = "outer value textobj" })

-- .: diagnostic textobj
keymap({ "x", "o" }, ".", varTextObj.diagnostic, { desc = "diagnostic textobj" })

-- in/an: number textobj
-- stylua: ignore start
keymap( { "x", "o" }, "in", function() varTextObj.number(true) end, { desc = "inner number textobj" })
keymap( { "x", "o" }, "an", function() varTextObj.number(false) end, { desc = "outer number textobj" })

-- iD/aD: double square brackets
keymap( { "x", "o" }, "iD", function() varTextObj.doubleSquareBrackets(true) end, { desc = "inner double square bracket" })
keymap( { "x", "o" }, "aD", function() varTextObj.doubleSquareBrackets(false) end, { desc = "outer double square bracket" })

-- ii/ai: indentation textobj
keymap({ "x", "o" }, "ii", function() varTextObj.indentation(true, true) end, { desc = "inner indentation textobj" })
keymap({ "x", "o" }, "ai", function() varTextObj.indentation(false, false) end, { desc = "outer indentation textobj" })
-- stylua: ignore end

augroup("IndentedFileTypes", {})
autocmd("FileType", {
	group = "IndentedFileTypes",
	callback = function()
		local indentedFts = { "python", "yaml", "markdown" }
		if vim.tbl_contains(indentedFts, bo.filetype) then
			keymap(
				{ "x", "o" },
				"ai",
				function() varTextObj.indentation(false, true) end,
				{ buffer = true, desc = "indentation textobj with start border" }
			)
		end
	end,
})

--------------------------------------------------------------------------------
-- SPECIAL PLUGIN TEXT OBJECTS

-- Git Hunks
keymap({ "x", "o" }, "ih", ":Gitsigns select_hunk<CR>", { desc = "hunk textobj" })
keymap({ "x", "o" }, "ah", ":Gitsigns select_hunk<CR>", { desc = "hunk textobj" })

--------------------------------------------------------------------------------
-- SURROUND
-- need to be consistent with the text obj mappings above
local functionObjChar = "f"
local conditionObjChar = "o"
local callObjChar = "l"
local doubleSquareBracketObjChar = "D"
local regexObjChar = "R"

-- HACK define these manually, since for some reason they do not work by default
keymap("n", "yss", "ys_", { remap = true })
keymap("n", "yS", "ys$", { remap = true })

local config = require("nvim-surround.config")

-- https://github.com/kylechui/nvim-surround/blob/main/doc/nvim-surround.txt#L483
require("nvim-surround").setup {
	aliases = { -- aliases should match the bindings for text objects
		["b"] = ")",
		["c"] = "}",
		["r"] = "]",
		["q"] = '"',
		["z"] = "'",
		["t"] = "`",
	},
	move_cursor = false,
	keymaps = {
		normal_cur = "<Nop>",
		normal_line = "<Nop>",
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
