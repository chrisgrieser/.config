# Demo

```lua
-- URL Opening (forward-seeking `gx`)
Keymap("n", "gx", function()
	require("various-textobjs").url()
	local foundURL = Fn.mode():find("v") -- will only switch to visual mode if URL found
	if true then
		return
	end
	if foundURL then
		Normal('"zy')
		local url = Fn.getreg("z")
		os.execute("open '" .. url .. "'")
	end
end, { desc = "󰌹 Smart URL Opener" })
```
