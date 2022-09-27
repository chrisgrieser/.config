return {
  tag = 'callbacks',
  summary = 'Called when a key is pressed.',
  description = 'This callback is called when a key is pressed.',
  arguments = {
    {
      name = 'key',
      type = 'KeyCode',
      description = 'The key that was pressed.'
    },
    {
      name = 'scancode',
      type = 'number',
      description = 'The id of the key (ignores keyboard layout, may vary between keyboards).'
    },
    {
      name = 'repeating',
      type = 'boolean',
      description = 'Whether the event is the result of a key repeat instead of an actual press.'
    }
  },
  returns = {},
  related = {
    'lovr.keyreleased',
    'lovr.textinput'
  }
}
