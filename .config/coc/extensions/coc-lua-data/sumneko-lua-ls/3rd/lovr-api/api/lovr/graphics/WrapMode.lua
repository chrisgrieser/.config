return {
  summary = 'How to wrap Textures.',
  description = [[
    The method used to render textures when texture coordinates are outside of the 0-1 range.
  ]],
  values = {
    {
      name = 'clamp',
      description = 'The texture will be clamped at its edges.'
    },
    {
      name = 'repeat',
      description = 'The texture repeats.'
    },
    {
      name = 'mirroredrepeat',
      description = 'The texture will repeat, mirroring its appearance each time it repeats.'
    }
  }
}
