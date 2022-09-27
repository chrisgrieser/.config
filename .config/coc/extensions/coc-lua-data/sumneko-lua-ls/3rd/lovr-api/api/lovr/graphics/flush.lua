return {
  tag = 'graphicsPrimitives',
  summary = 'Flush any pending batched draw calls.',
  description = [[
    Flushes the internal queue of draw batches.  Under normal circumstances this is done
    automatically when needed, but the ability to flush manually may be helpful if you're
    integrating a LÖVR project with some external rendering code.
  ]],
  arguments = {},
  returns = {},
  related = {
    'lovr.graphics.clear',
    'lovr.graphics.discard'
  }
}
