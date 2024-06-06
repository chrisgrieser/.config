local lastCommitThatChangedFile = vim.system ({
	"git",
	"log",
	"--max-count=1",
	"--pretty=format:%H",
	"--",
	vim.api.nvim_buf_get_name(0),
}):wait().stdout
vim.notify("⭕ lastCommitThatChangedFile: " .. vim.inspect(lastCommitThatChangedFile.stdout))
