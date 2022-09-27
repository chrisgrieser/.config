return {
  tag = 'callbacks',
  summary = 'Called when a key is released.',
  description = 'This callback is called when a key is released.',
  arguments = {
    {
      name = 'key',
      type = 'KeyCode',
      description = 'The key that was released.'
    },
    {
      name = 'scancode',
      type = 'number',
      description = 'The id of the key (ignores keyboard layout, may vary between keyboards).'
    }
  },
  returns = {},
  related = {
    'lovr.keypressed',
    'lovr.textinput'
  }
}
