-- based on: https://pandoc.org/lua-filters.html#setting-the-date-in-the-metadata

function Meta(metadata)
	-- do not set the date if it already has been set in the metadata
	if metadata.date then return end

	-- select date format based on document language, defaulting to English
	local germanFormat = "%d. %B %Y" 
	local englishFormat = "%B %e, %Y"
	local lang = metadata.lang
	local format = (lang and lang:find("^de")) and germanFormat or englishFormat 

	metadata.date = os.date(format)
	return metadata
end
