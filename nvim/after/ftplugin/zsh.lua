-- ABBREVIATIONS
local abbr = require("config.utils").bufAbbrev

abbr("//", "#")
abbr("delay", "sleep")
abbr("const", "local")
abbr("let", "local")
abbr("~=", "=~") -- lua uses `=~`
