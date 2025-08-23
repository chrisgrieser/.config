local bkeymap = require("config.utils").bufKeymap

-- `gO` opens the heading-selection man pages
bkeymap("n", "gs", "gO", { remap = true })
