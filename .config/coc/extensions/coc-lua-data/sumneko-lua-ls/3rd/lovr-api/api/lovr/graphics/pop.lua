return {
  tag = 'graphicsTransforms',
  summary = 'Pop the current transform off the stack.',
  description = [[
    Pops the current transform from the stack, returning to the transformation that was applied
    before `lovr.graphics.push` was called.
  ]],
  arguments = {},
  returns = {},
  notes = [[
    An error is thrown if there isn't a transform to pop.  This can happen if you forget to call
    push before calling pop, or if you have an unbalanced sequence of pushes and pops.
  ]],
  related = {
    'lovr.graphics.push'
  }
}
