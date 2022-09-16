-- '--lua-filter=remove-wikilinks.lua'
function Str (str)
	return str.text:gsub('%[%[', '')
						:gsub('%]%]', '')
end
