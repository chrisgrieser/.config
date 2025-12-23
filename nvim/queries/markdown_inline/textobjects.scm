; extends

; mdlink
(inline_link
  (link_text) @mdlink.inner) @mdlink.outer

; emphasis
((strong_emphasis) @emphasis.inner @emphasis.outer
  (#offset! @emphasis.inner 0 2 0 -2))

((emphasis) @emphasis.inner @emphasis.outer
  (#offset! @emphasis.inner 0 1 0 -1))
