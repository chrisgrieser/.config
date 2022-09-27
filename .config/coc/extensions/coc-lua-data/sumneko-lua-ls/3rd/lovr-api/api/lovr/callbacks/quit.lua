return {
  tag = 'callbacks',
  summary = 'Called before quitting.',
  description = [[
    This callback is called right before the application is about to quit.  Use it to perform any
    necessary cleanup work.  A truthy value can be returned from this callback to abort quitting.
  ]],
  arguments = {},
  returns = {
    {
      type = 'boolean',
      name = 'abort',
      description = 'Whether quitting should be aborted.'
    }
  },
  example = [[
    function lovr.quit()
      if shouldQuit() then
        return false
      else
        return true
      end
    end
  ]],
  related = {
    'lovr.event.quit',
    'lovr.load'
  }
}
