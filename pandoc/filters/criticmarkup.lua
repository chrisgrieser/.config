-- a lua filter for panodoc
-- run pandoc your_word_doc.docx --track-change=all -t markdown --lua-filter=criticmarkup.lua
-- TODO: Detect substitutions in adjacent insertion/deletions
-- TODO: capture whole comment hightlight rather than just start point of comment
function Span(elem)
  if elem.classes[1] and elem.classes[1] == "insertion" then
    local opener = { pandoc.RawInline(FORMAT, "{++ ") }
    local closer = { pandoc.RawInline(FORMAT, " ++}") }
    return opener .. elem.content .. closer
  elseif
    elem.classes[1] and elem.classes[1] == "deletion" then
    local opener = { pandoc.RawInline(FORMAT, "{-- ") }
    local closer = { pandoc.RawInline(FORMAT, " --}") }
    return opener .. elem.content .. closer
  elseif
    elem.classes[1] and elem.classes[1] == "comment-start" then
    if elem.t == nil then
      return pandoc.RawInline(FORMAT, "")
    end
    local opener = { pandoc.RawInline(FORMAT, "{>> ") }
    local closer = { pandoc.RawInline(FORMAT, " ("), pandoc.RawInline(FORMAT, elem.attributes.author), pandoc.RawInline(FORMAT, ")<<}")}
    return opener .. elem.content .. closer
  elseif
    elem.classes[1] and (elem.classes[1] == "comment-end" or elem.classes[1] == "paragraph-insertion") then
    return pandoc.RawInline(FORMAT, "")
  else
    return nil
  end
end
