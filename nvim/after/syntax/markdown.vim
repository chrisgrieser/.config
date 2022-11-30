" syntax highlighting for yaml header
syntax include @Yaml syntax/yaml.vim
syntax region yamlFrontmatter start=/\%^---$/ end=/^---$/ keepend contains=@Yaml
