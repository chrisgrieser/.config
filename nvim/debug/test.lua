local installedTools = require("mason-registry").get_installed_packages()
local nonLspInstalled = vim.tbl_filter(
	function(t) return t.name == "vale" end,
	installedTools
)


blaa = {}
nonLspInstalled[1]:uninstall()
bla = {

}
