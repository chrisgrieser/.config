local file = "/Users/chrisgrieser/.config/nvim/lua/funcs/ff.lua"

local globToTemplateMap = {
	["**/*.py"] = "template.py",
	[vim.g.localRepos .. "/**/lua/**/*.lua"] = "module.lua",
	["**/lua/funcs/*.lua"] = "module.lua",
	["**/*.applescript"] = "template.applescript",
	["**/Alfred.alfredpreferences/workflows/**/*.js"] = "jxa.js",
	["**/*Justfile"] = "justfile.just",
	["**/*.sh"] = "template.zsh",
	["**/*typos.toml"] = "typos.toml",
	["**/.github/workflows/**/*.y*ml"] = "github-action.yaml",
}
local matchingGlob = vim.iter(globToTemplateMap)
	:find(function(glob, _) return vim.glob.to_lpeg(glob):match(file) end)
local templateFile = globToTemplateMap[matchingGlob]
vim.notify("👾 templateFile: " .. tostring(templateFile))
