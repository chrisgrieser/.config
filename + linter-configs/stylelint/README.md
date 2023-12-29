# Compile stylelint config
To avoid a dependency on
[stylelint-config-standard](https://www.npmjs.com/package/stylelint-config-standard)
(and in turn it's dependencies) just for a ~100 lines of code, [this
script](create_stylelint_config.sh) is used to fetch the
`stylelint-config-standard` and `stylelint-config-recommended` and merge them
with my personal config.

This also makes the stylelint config more portable, for example for the
stylelint LSP.
