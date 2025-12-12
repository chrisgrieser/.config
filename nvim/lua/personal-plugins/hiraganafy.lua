-- stylua: ignore
local romajiToHiraganaMap = {
	a  = "あ", i  = "い", u  = "う", e  = "え", o  = "お",
	ka = "か", ki = "き", ku = "く", ke = "け", ko = "こ",
	sa = "さ", shi= "し", su = "す", se = "せ", so = "そ",
	ta = "た", chi= "ち", tsu= "つ", te = "て", to = "と",
	na = "な", ni = "に", nu = "ぬ", ne = "ね", no = "の",
	ha = "は", hi = "ひ", fu = "ふ", he = "へ", ho = "ほ",
	ma = "ま", mi = "み", mu = "む", me = "め", mo = "も",
	ya = "や",            yu = "ゆ",            yo = "よ",
	ra = "ら", ri = "り", ru = "る", re = "れ", ro = "ろ",
	wa = "わ",                                  wo = "を",
	n  = "ん",
	ga = "が", gi = "ぎ", gu = "ぐ", ge = "げ", go = "ご",
	za = "ざ", ji = "じ", zu = "ず", ze = "ぜ", zo = "ぞ",
	da = "だ",                       de = "で", ["do"] = "ど",
	ba = "ば", bi = "び", bu = "ぶ", be = "べ", bo = "ぼ", -- typos: ignore-line
	pa = "ぱ", pi = "ぴ", pu = "ぷ", pe = "ぺ", po = "ぽ",
	kya = "きゃ", kyu = "きゅ", kyo = "きょ",
	sha = "しゃ", shu = "しゅ", sho = "しょ",
	cha = "ちゃ", chu = "ちゅ", cho = "ちょ",
	nya = "にゃ", nyu = "にゅ", nyo = "にょ",
	hya = "ひゃ", hyu = "ひゅ", hyo = "ひょ",
	mya = "みゃ", myu = "みゅ", myo = "みょ", -- typos: ignore-line
	rya = "りゃ", ryu = "りゅ", ryo = "りょ",
	gya = "ぎゃ", gyu = "ぎゅ", gyo = "ぎょ",
	ja  = "じゃ", ju  = "じゅ", jo  = "じょ",
	bya = "びゃ", byu = "びゅ", byo = "びょ",
	pya = "ぴゃ", pyu = "ぴゅ", pyo = "ぴょ",
}

return function()
	local cword = vim.fn.expand("<cword>"):lower()
	if not cword:find("^%w+$") then
		vim.notify("Word must be in Romaji.", vim.log.levels.WARN)
		return
	end

	-- handle small tsu
	local hiragana = cword:gsub("[kstnhmyrwgzdbp][kstnhmyrwgzdbp]", function(m)
		if m:sub(1, 1) == m:sub(2, 2) then return "っ" .. m:sub(1, 1) end
		return m
	end)

	-- group by length, to replace the longer romaji first
	local groups = vim.iter(romajiToHiraganaMap):fold({ {}, {}, {} }, function(acc, romaji, hira)
		table.insert(acc[#romaji], { romaji, hira })
		return acc
	end)

	-- from the longer to the short groups, replace each romaji found
	for i = 3, 1, -1 do
		for _, pair in ipairs(groups[i]) do
			hiragana = hiragana:gsub(pair[1], pair[2])
		end
	end

	vim.cmd.normal { "ciw" .. hiragana, bang = true }
end
