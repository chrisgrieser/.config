local u = require("config.utils")

-- fix my habits
u.ftAbbr("//", "#")
u.ftAbbr("--", "#")
u.ftAbbr("end", "fi") -- lua

u.applyTemplateIfEmptyFile("zsh")
