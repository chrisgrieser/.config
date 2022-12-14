require("utils")
--------------------------------------------------------------------------------
-- OVERVIEW
-- af -> a [f]unction (treesitter)
-- ao -> a c[o]ndition (treesitter)
-- q -> comment (mnemonic: [q]uiet text) (treesitter)
-- Q -> consecutive (big) comment (comments.nvim)
-- aa -> an [a]rgument (treesitter)
-- al -> a cal[l] (treesitter)
-- ah -> a [h]unk (gitsigns)
-- ai -> an [i]ndentation (indent-textobj)
-- ad -> a [d]iagnostic (diagnostic-textobj)
-- ae -> almost to the [e]nding of line (mini.ai)
-- av -> a [v]alue / right-hand-side of key-value pair or variable assignment (mini.ai)
-- aL -> a [L]oop (treesitter)

-- FILE-TYPE-SPECIFIC TEXT OBJECTS
-- al: a [l]ink (markdown)
-- as: a [s]elector (css)

-- BUILTIN ONES KEPT
-- ab: bracket
-- as: sentence
-- ap: paragraph
-- aw: word

-- BUILTIN ONES CHANGES
keymap({"o", "x"}, "iq", 'i"') -- [q]uote
keymap({"o", "x"}, "aq", 'a"')
keymap({"o", "x"}, "iz", "i'") -- [z]ingle quote
keymap({"o", "x"}, "az", "a'")
keymap({"o", "x"}, "at", "a`") -- [t]emplate-string
keymap({"o", "x"}, "it", "i`")
keymap({"o", "x"}, "ir", "i]") -- [r]ectangular brackets
keymap({"o", "x"}, "ar", "a]")
keymap({"o", "x"}, "ic", "i}") -- [c]urly brackets
keymap({"o", "x"}, "ac", "a}")
keymap({"o", "x"}, "am", "aW") -- [m]assive word
keymap({"o", "x"}, "im", "iW")
keymap("o", "an", "gn") -- [n]ext search result
keymap("o", "in", "gn")
keymap("o", "r", "}") -- [r]est of the paragraph

--------------------------------------------------------------------------------
-- QUICK TEXTOBJ OPERATIONS
keymap("n", "C", '"_C')
keymap("n", "<Space>", '"_ciw') -- change word
keymap("n", "<C-M-Space>", '"_daw') -- wordaround, since <S-Space> not fully supported, requires karabiner remapping it
keymap("x", "<Space>", '"_c')

keymap("n", "c<Space>", function() -- change-subword ( = word excluding _ and - as word-parts)
	opt.iskeyword:remove {"_", "-"}
	cmd [[normal! "_diw]]
	cmd [[startinsert]] -- :normal does not allow to end in insert mode
	opt.iskeyword:append {"_", "-"}
end)

--------------------------------------------------------------------------------
-- SPECIAL PLUGIN TEXT OBJECTS

-- Git Hunks
keymap({"x", "o"}, "ih", ":Gitsigns select_hunk<CR>")
keymap({"x", "o"}, "ah", ":Gitsigns select_hunk<CR>")

-- map ai to aI in languages where aI is not used anyway
augroup("indentobject", {})
autocmd("FileType", {
	group = "indentobject",
	callback = function()
		local ft = bo.filetype
		if not (ft == "yaml" or ft == "python" or ft == "markdown") then
			keymap({"x", "o"}, "ai", "aI", {remap = true, buffer = true})
		end
	end
})

-- textobj-[d]iagnostic
keymap({"x", "o"}, "id", function() require("textobj-diagnostic").nearest_diag() end)
keymap({"x", "o"}, "ad", function() require("textobj-diagnostic").nearest_diag() end)

-- disable text-objects from mini.ai in favor of my own
local miniaiConfig = {
	n_lines = 15, -- number of lines within which to search textobj
	custom_textobjects = {
		b = false,
		q = false,
		t = false,
		f = false,
		a = false,
	},
	mappings = {
		around_next = "",
		inside_next = "",
		around_last = "",
		inside_last = "",
		goto_left = "",
		goto_right = "",
	},
}

-- custom text object "e": from cursor to [e]end of line minus 1 char
miniaiConfig.custom_textobjects.e = function()
	local row = fn.line(".")
	local col = fn.col(".")
	local eol = fn.col("$") - 1
	local from = {line = row, col = col}
	local to = {line = row, col = eol - 1}
	return {from = from, to = to}
end

-- https://github.com/echasnovski/mini.nvim/blob/main/doc/mini-ai.txt#L215
augroup("value-textobj", {})
autocmd("FileType", {
	group = "value-textobj",
	callback = function()
		-- this way, comments for various filetypes are excluded from the value-textobj
		local comStr = bo.commentstring
			:gsub("%%s.*", "")-- remove replaceholder and back side of comment
			:gsub("(.)", "%1?") -- make all letters of the comment optional
		local pattern = "[=:] ?()().-()[;,]?() ?" .. comStr .. "[][-_(){}/ %w]*\n"
		b.miniai_config = {
			custom_textobjects = {
				v = {pattern}
			}
		}
	end
})

require("mini.ai").setup(miniaiConfig)

--------------------------------------------------------------------------------
-- SURROUND
-- need to be consistent with treesitter
local functionObjChar = "f" -- test
local conditionObjChar = "o"
local callObjChar = "l"

-- HACK define these manually, since for some reason why do not work
keymap("n", "yss", "ys_", {remap = true})
keymap("n", "yS", "ys$", {remap = true})

require("nvim-surround").setup {
	aliases = {-- aliases should match the bindings for text objects
		["b"] = ")",
		["c"] = "}",
		["r"] = "]",
		["q"] = '"',
		["z"] = "'",
		["t"] = "`",
	},
	move_cursor = false,
	keymaps = {
		insert = "<Nop>",
		insert_line = "<Nop>",
		normal_cur = "<Nop>",
		normal_line = "<Nop>",
		normal_cur_line = "<Nop>",
		visual = "s",
	},
	surrounds = {
		[functionObjChar] = {
			find = function()
				return require("nvim-surround.config").get_selection {motion = "a" .. functionObjChar}
			end,
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
						{"function ()", "\t"},
						{"", "end"},
					}
				elseif ft == "typescript" or ft == "javascript" or ft == "bash" or ft == "zsh" or ft == "sh" then
					return {
						{"function () {", "\t"},
						{"", "}"},
					}
				end
				vim.notify("No function-surround defined for " .. ft, logWarn)
				return {{""}, {""}}
			end,
		},
		[callObjChar] = {
			find = function()
				return require("nvim-surround.config").get_selection {motion = "a" .. callObjChar}
			end,
			delete = "^([^=%s]-% ?()().-(%))()$",
		},
		[conditionObjChar] = {
			find = function()
				return require("nvim-surround.config").get_selection {motion = "a" .. callObjChar}
			end,
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
						{"if true then", "\t"},
						{"", "end"},
					}
				elseif ft == "typescript" or ft == "javascript" then
					return {
						{"if (true) {", "\t"},
						{"", "}"},
					}
				end
				vim.notify("No if-surround defined for " .. ft, logWarn)
				return {{""}, {""}}
			end,
		}
	}
}
