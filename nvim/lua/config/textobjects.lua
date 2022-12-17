require("config/utils")
local varTextobjs = require("various-textobjs")
--------------------------------------------------------------------------------
-- New Text objects
-- af -> a [f]unction (treesitter)
-- ao -> a c[o]ndition (treesitter)
-- q -> comment (mnemonic: [q]uiet text) (treesitter)
-- Q -> consecutive comment (comments.nvim / custom)
-- aa -> an [a]rgument (treesitter)
-- al -> a cal[l] (treesitter)
-- ah -> a [h]unk (gitsigns)
-- ai -> an [i]ndentation (custom)
-- ad -> a [d]iagnostic (diagnostic-textobj)
-- n -> near the [e]nding of line (custom)
-- r -> rest of paragraph, linewise (custom)
-- av -> a [v]alue / variable assignment (custom)
-- aL -> a [L]oop (treesitter)
-- <Space> -> Subword (custom)

-- FILE-TYPE-SPECIFIC TEXT OBJECTS
-- al: a [l]ink (markdown, custom)
-- as: a [s]elector (css, custom)

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
keymap("n", "<C-M-Space>", '"_daW') -- HACK since <S-Space> not fully supported, requires karabiner remapping it
keymap("x", "<Space>", '"_c')

--------------------------------------------------------------------------------
-- VARIOUS TEXTOBJS

-- subword
keymap("o", "<Space>", varTextobjs.subword, { desc = "subword textobj" })

-- n: [n]ear end of the line
keymap({"o", "x"}, "n", varTextobjs.nearEoL, { desc = "almost ending of line textobj" })

-- r: [r]est of paragraph (linewise)
keymap({"o", "x"}, "r", varTextobjs.restOfParagraph, { desc = "rest of paragraph (linewise)" })

-- av/iv: value textobj
keymap({ "x", "o" }, "iv", function() varTextobjs.valueTextObj(true) end, { desc = "inner value textobj" })
keymap({ "x", "o" }, "av", function() varTextobjs.valueTextObj(false) end, { desc = "outer value textobj" })

-- ii/ai: indentation textobj
keymap({ "x", "o" }, "ii", function() varTextobjs.indentTextObj(false, false) end, { desc = "inner indentation textobj" })
keymap({ "x", "o" }, "ai", function() varTextobjs.indentTextObj(true, true) end, { desc = "outer indentation textobj" })

augroup("IndentedFileTypes", {})
autocmd("FileType", {
	group = "IndentedFileTypes",
	callback = function()
		local indentedFts = { "python", "yaml", "markdown" }
		if vim.tbl_contains(indentedFts, bo.filetype) then
			keymap(
				{ "x", "o" },
				"ai",
				function() indentationTextObj(true, false) end,
				{ buffer = true, desc = "indentation textobj with start border" }
			)
		end
	end,
})

--------------------------------------------------------------------------------
-- SPECIAL PLUGIN TEXT OBJECTS

for _, prefix in pairs { "a", "i" } do
	-- Git Hunks
	keymap({ "x", "o" }, prefix .. "h", ":Gitsigns select_hunk<CR>", { desc = "hunk textobj" })

	-- textobj-[d]iagnostic
	keymap(
		{ "x", "o" },
		prefix .. "d",
		function() require("textobj-diagnostic").nearest_diag() end,
		{ desc = "diagnostic textobj" }
	)
end

--------------------------------------------------------------------------------
-- SURROUND
-- need to be consistent with treesitter
local functionObjChar = "f"
local conditionObjChar = "o"
local callObjChar = "l"

-- HACK define these manually, since for some reason why do not work
keymap("n", "yss", "ys_", { remap = true })
keymap("n", "yS", "ys$", { remap = true })

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
		[functionObjChar] = {
			find = function() return require("nvim-surround.config").get_selection { motion = "a" .. functionObjChar } end,
			delete = function()
				local ft = bo.filetype
				local patt
				if ft == "lua" then
					patt = "^(.-function.-%b() ?)().-( ?end)()$"
				elseif ft == "javascript" or ft == "typescript" or ft == "bash" or ft == "zsh" or ft == "sh" then
					patt = "^(.-function.-%b() ?{)().*(})()$"
				else
					vim.notify("No function-surround defined for " .. ft, logWarn)
					patt = "()()()()"
				end
				return require("nvim-surround.config").get_selections {
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
				elseif ft == "typescript" or ft == "javascript" or ft == "bash" or ft == "zsh" or ft == "sh" then
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
			find = function() return require("nvim-surround.config").get_selection { motion = "a" .. callObjChar } end,
			delete = "^([^=%s]-% ?()().-(%))()$",
		},
		[conditionObjChar] = {
			find = function() return require("nvim-surround.config").get_selection { motion = "a" .. callObjChar } end,
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
				return require("nvim-surround.config").get_selections {
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
