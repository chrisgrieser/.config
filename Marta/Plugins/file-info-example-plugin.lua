-- https://marta.sh/api/tutorials/interacting-with-marta-apis/

plugin {
	id = "marta.example.fileinfo",
	name = "File information",
	apiVersion = "2.1"
}

action {
	id = "show",
	name = "Show file information",

	isApplicable = function(context)
		return context.activePane.model.hasActiveFiles
	end,

	apply = function(context)
		local files = context.activePane.model.activeFileInfos
		if #files == 0 then
			martax.alert("No files selected.")
			return
		end

		local text = ""
		for _, file in ipairs(files) do
			local name = file.name
			local entity

			if file.isFolder then
				entity = "[" .. name .. "]"
			else
				entity = name .. " (" .. martax.formatSize(file.size) .. ")"
			end

			text = text .. entity .. "\n"
		end

		martax.alert("Files: \n\n" .. text)
	end
}
