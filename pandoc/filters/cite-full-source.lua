-- https://stackoverflow.com/a/66605610
--------------------------------------------------------------------------------

local refs = {}

local function store_refs(div)
	local ref_id = div.identifier:match("ref%-(.*)$")
	if ref_id then refs[ref_id] = div.content end
end

local function replace_cite(cite)

	local citekey = cite.citations[1]
	if citekey and refs[citekey] and #cite.citations == 1 then
		local full_reference = pandoc.utils.blocks_to_inlines(refs[citekey])
		local prefix = { citekey .. " – "} -- prefix citekey in front of the citation
		return prefix .. full_reference
	end
end

return {
	{ Div = store_refs },
	{ Cite = replace_cite },
}
