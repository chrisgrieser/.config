-- https://pandoc.org/lua-filters.html#setting-the-date-in-the-metadata

function Meta(m)
	-- do not set the date if it already has been set in the metadata
	if m.date then return end

	-- select date format based on document language
	local germanFormat = "%d. %B %Y" 
	local englishFormat = "%B %e, %Y"
	local format = m.lang:find("de") and germanFormat or englishFormat 

	m.date = os.date(format)
	return m
end
