### Proposal: Syntax-free Wikilinks in Frontmatter

So with tags, we not have to write something like this: 
```yaml
---
tags: ["#WIP", "#done", "#lol"]
---
```

Since Obsidian supports leaving out the (redundant) `#`, therefore also allowing yaml-parsing without quotes:
```yaml
---
tags: [WIP, done, lol]
---
```

So why not do the same thing with wikilinks in the frontmatter? Instead of:
```yaml
---
relatedNotes: 
  - "[[Hippo]]"
  - "[[Vulcan]]"
  - "[[Magic]]"
---
```

Obsidian could allow:
```yaml
---
relatedNotes: 
  - Hippo
  - Vulcan
  - Magic
---
```

To enable this, the user would have to set `wikilink` as a property type.

The benefits of this would be:
1. less typing, cleaner look
2. syntax highlighting, since the differentiation between the property types `wikilink` and `text` would make them distinguishable (if given different classes)
3. consistency with how Obsidian already works with tags
