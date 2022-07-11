-- https://stackoverflow.com/a/66605610

local refs = {}

local function store_refs (div)
	local ref_id = div.identifier:match 'ref%-(.*)$'
	if ref_id then
		refs[ref_id] = div.content
	end
end

local function replace_cite (cite)
	local citation = cite.citations[1]
	if citation and refs[citation.id] and #cite.citations == 1 then
		return pandoc.utils.blocks_to_inlines(refs[citation.id])
	end
end

return {
	{Div = store_refs},
	{Cite = replace_cite},
}
