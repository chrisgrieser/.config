local u = require("config.utils")
--------------------------------------------------------------------------------

-- convert to yaml
vim.keymap.set("n", "<localleader>y", function()
	vim.cmd("silent update")
	local filename = vim.fn.expand("%")
	local nameAsYaml = vim.fn.expand("%:r") .. ".yaml"
	local yaml = vim.fn.system { "yq", "--output-format=yaml", filename }
	if vim.v.shell_error ~= 0 then
		u.notify("Error", yaml)
		return
	end
	local error = u.writeToFile(nameAsYaml, yaml, "w")
	if error then
		u.notify("Error", error)
		return
	end
	vim.fn.system { "open", "-R", nameAsYaml }
end, { buffer = true, desc = " Convert to yaml" })

