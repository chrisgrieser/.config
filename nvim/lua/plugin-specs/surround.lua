local textObjMaps = require("config.utils").extraTextobjMaps
--------------------------------------------------------------------------------

return {
	"kylechui/nvim-surround",
	keys = {
		{ "ys", desc = "󰅪 Add surround operator" },
		{ "yS", "ys$", desc = "󰅪 Surround to EoL", remap = true },
		{ "ds", desc = "󰅪 Delete surround operator" },
		{ "cs", desc = "󰅪 Change surround operator" },
	},
	opts = {
		move_cursor = false,
		aliases = { c = "}", r = "]", m = "W", q = '"', z = "'", e = "`" },
		keymaps = {
			visual = false,
			normal_line = false,
			normal_cur_line = false,
			visual_line = false,
			insert_line = false,
			insert = false,
		},
		surrounds = {
			invalid_key_behavior = { add = false, find = false, delete = false, change = false },
			[textObjMaps.call] = {
				find = "[%w.:_]+%b()", -- includes `:` for lua-methods/css-pseudoclasses
				delete = "([%w.:_]+%()().*(%))()",
			},
			[textObjMaps.func] = { -- only one-line lua functions
				find = "function ?[%w_]* ?%b().- end",
				delete = "(function ?[%w_]* ?%b() ?)().-( end)()",
			},
			[textObjMaps.condition] = { -- only one-line lua conditionals
				find = "if .- then .- end",
				delete = "(if .- then )().-( end)()",
			},
			[textObjMaps.wikilink] = {
				find = "%[%[.-%]%]",
				add = { "[[", "]]" },
				delete = "(%[%[)().-(%]%])()",
				change = { target = "(%[%[)().-(%]%])()" },
			},
		},
	},
}