return {
  tag = 'input',
  summary = 'Get a Model for a device.',
  description = 'Returns a new Model for the specified device.',
  arguments = {
    {
      name = 'device',
      type = 'Device',
      default = [['head']],
      description = 'The device to load a model for.'
    },
    {
      name = 'options',
      type = 'table',
      default = '{}',
      description = 'Options for loading the model.',
      table = {
        {
          name = 'animated',
          type = 'boolean',
          default = 'false',
          description = 'Whether an animatable model should be loaded, for use with `lovr.headset.animate`.'
        }
      }
    }
  },
  returns = {
    {
      name = 'model',
      type = 'Model',
      description = 'The new Model, or `nil` if a model could not be loaded.'
    }
  },
  notes = 'This is only supported on the `openvr` and `vrapi` drivers right now.',
  example = [[
    local models = {}

    function lovr.draw()
      for i, hand in ipairs(lovr.headset.getHands()) do
        models[hand] = models[hand] or lovr.headset.newModel(hand)

        if models[hand] then
          local x, y, z, angle, ax, ay, az = lovr.headset.getPose(hand)
          models[hand]:draw(x, y, z, 1, angle, ax, ay, az)
        end
      end
    end
  ]],
  related = {
    'lovr.headset.animate'
  }
}
