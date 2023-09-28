vim.notify("one two three", vim.log.levels.INFO, {
				title = "title",
})

require("notify.config").max_width()
