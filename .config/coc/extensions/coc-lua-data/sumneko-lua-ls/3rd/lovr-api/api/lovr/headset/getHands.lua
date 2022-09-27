return {
  tag = 'input',
  summary = 'Get a list of currently tracked hand devices.',
  description = 'Returns a table with all of the currently tracked hand devices.',
  arguments = {},
  returns = {
    {
      name = 'hands',
      type = 'table',
      arguments = {},
      returns = {},
      description = 'The currently tracked hand devices.'
    }
  },
  notes = 'The hand paths will *always* be either `hand/left` or `hand/right`.',
  example = [[
    function lovr.update(dt)
      for i, hand in ipairs(lovr.headset.getHands()) do
        print(hand, lovr.headset.getPose(hand))
      end
    end
  ]]
}
