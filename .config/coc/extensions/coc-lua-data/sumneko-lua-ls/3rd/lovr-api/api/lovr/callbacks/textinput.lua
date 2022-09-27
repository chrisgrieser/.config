return {
  tag = 'callbacks',
  summary = 'Called when text has been entered.',
  description = [[
    This callback is called when text has been entered.

    For example, when `shift + 1` is pressed on an American keyboard, `lovr.textinput` will be
    called with `!`.
  ]],
  arguments = {
    {
      name = 'text',
      type = 'string',
      description = 'The UTF-8 encoded character.'
    },
    {
      name = 'code',
      type = 'number',
      description = 'The integer codepoint of the character.'
    }
  },
  notes = [[
    Some characters in UTF-8 unicode take multiple bytes to encode.  Due to the way Lua works, the
    length of these strings will be bigger than 1 even though they are just a single character.
    `lovr.graphics.print` is compatible with UTF-8 but doing other string processing on these
    strings may require a library.  Lua 5.3+ has support for working with UTF-8 strings.
  ]],
  returns = {},
  related = {
    'lovr.keypressed',
    'lovr.keyreleased'
  }
}
