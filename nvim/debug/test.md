# Harper false positives

With `Luasnip`, this is an opt-in feature, enabled via:

In your VSCode-style snippet, use the token `$TM_SELECTED_TEXT` at the location
where you want the selection to be inserted. (It's roughly the equivalent of
`LS_SELECT_RAW` in the `Luasnip` syntax.)
