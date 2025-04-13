" chrome-extension://dgogifpkoilgiofhhhodbodcfgomelhe/options.html
" ──────────────────────────────────────────────────────────────────────────
" DOCS
" https://github.com/akahuku/wasavi?tab=readme-ov-file#frequently-asked-questions
" https://github.com/akahuku/wasavi/wiki/All-Options-which-wasavi-recognizes
"───────────────────────────────────────────────────────────────────────────────

set theme=blight
set nolaunchbell
filesystem default gdrive

map [noremap] j gj
map [noremap] J 6gj
map [noremap] k gk
map [noremap] K 6gk
map [noremap] H g^
map [noremap] L g$
map [noremap] <space> ciw
map [noremap] <s-space> daw
map [noremap] U <c-r>

map [noremap] y "*y
map [noremap] yy "*yy
map [noremap] Y "*y$
map [noremap] p "*p
map [noremap] c "_c
map [noremap] C "_C

map [noremap] ww yyp
map <enter> ZZ

map _ mzo<Esc>k`z
map = mzO<Esc>j`z
