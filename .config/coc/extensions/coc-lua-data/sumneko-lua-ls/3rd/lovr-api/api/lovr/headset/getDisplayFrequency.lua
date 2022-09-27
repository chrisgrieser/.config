return {
  tag = 'headset',
  summary = 'Get the refresh rate of the headset display.',
  description = 'Returns the refresh rate of the headset display, in Hz.',
  arguments = {},
  returns = {
    {
      name = 'frequency',
      type = 'number',
      description = 'The frequency of the display, or `nil` if I have no idea what it is.'
    }
  }
}
