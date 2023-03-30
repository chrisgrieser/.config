# This is a test

```lua
local function harpoonFileNumber()
	local pwd = vim.loop.cwd() or ""
	local jsonPath = Fn.stdpath("data") .. "/harpoon.json"
	local json = ReadFile(jsonPath)
	if not json then
		return
	end
	local data = vim.json.decode(json)
	local project = data.projects[pwd]
	if not project then
		return
	end
	local fileNumber = #project.mark.marks
	return fileNumber
end
```
