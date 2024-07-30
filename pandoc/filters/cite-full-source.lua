-- https://stackoverflow.com/a/66605610
--------------------------------------------------------------------------------

local refs = {}

local function store_refs(div)
	local ref_id = div.identifier:match("ref%-(.*)$")
	if ref_id then refs[ref_id] = div.content end
end

local function replace_cite(cite)
	if #cite.citations ~= 1 then return end

	local citekey = cite.citations[1].id
	if citekey and refs[citekey] then
		local full_reference = pandoc.utils.blocks_to_inlines(refs[citekey])

		-- prefix citekey in front of the citation
		local prefix = { "__" .. citekey .. "__: " }
		return prefix .. full_reference
	end
end

return {
	{ Div = store_refs },
	{ Cite = replace_cite },
}
