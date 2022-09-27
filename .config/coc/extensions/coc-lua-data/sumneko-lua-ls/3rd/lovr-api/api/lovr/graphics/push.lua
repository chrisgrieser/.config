return {
  tag = 'graphicsTransforms',
  summary = 'Push a copy of the current transform onto the stack.',
  description = [[
    Pushes a copy of the current transform onto the transformation stack.  After changing the
    transform using `lovr.graphics.translate`, `lovr.graphics.rotate`, and `lovr.graphics.scale`,
    the original state can be restored using `lovr.graphics.pop`.
  ]],
  arguments = {},
  returns = {},
  notes = [[
    An error is thrown if more than 64 matrices are pushed.  This can happen accidentally if a push
    isn't followed by a corresponding pop.
  ]],
  related = {
    'lovr.graphics.pop'
  }
}
