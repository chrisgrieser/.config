return {
  summary = 'Apply an animation to the pose of the Model.',
  description = [[
    Applies an animation to the current pose of the Model.

    The animation is evaluated at the specified timestamp, and mixed with the current pose of the
    Model using the alpha value.  An alpha value of 1.0 will completely override the pose of the
    Model with the animation's pose.
  ]],
  arguments = {
    name = {
      type = 'string',
      description = 'The name of an animation.'
    },
    index = {
      type = 'number',
      description = 'The index of an animation.'
    },
    time = {
      type = 'number',
      description = 'The timestamp to evaluate the keyframes at, in seconds.'
    },
    alpha = {
      type = 'number',
      default = '1',
      description = 'How much of the animation to mix in, from 0 to 1.'
    }
  },
  returns = {},
  variants = {
    {
      arguments = { 'name', 'time', 'alpha' },
      returns = {}
    },
    {
      arguments = { 'index', 'time', 'alpha' },
      returns = {}
    }
  },
  notes = [[
    For animations to properly show up, use a Shader created with the `animated` flag set to `true`.
    See `lovr.graphics.newShader` for more.

    Animations are always mixed in with the current pose, and the pose only ever changes by calling
    `Model:animate` and `Model:pose`.  To clear the pose of a Model to the default, use
    `Model:pose(nil)`.
  ]],
  examples = {
    {
      description = 'Render an animated model, with a custom speed.',
      code = [[
        function lovr.load()
          model = lovr.graphics.newModel('model.gltf')
          shader = lovr.graphics.newShader('unlit', { flags = { animated = true } })
        end

        function lovr.draw()
          local speed = 1.0
          model:animate(1, lovr.timer.getTime() * speed)
          model:draw()
        end
      ]]
    },
    {
      description = 'Mix from one animation to another, as the trigger is pressed.',
      code = [[
        function lovr.load()
          model = lovr.graphics.newModel('model.gltf')
          shader = lovr.graphics.newShader('unlit', { flags = { animated = true } })
        end

        function lovr.draw()
          local t = lovr.timer.getTime()
          local mix = lovr.headset.getAxis('right', 'trigger')

          model:pose()
          model:animate(1, t)
          model:animate(2, t, mix)

          model:draw()
        end
      ]]
    }
  },
  related = {
    'Model:pose',
    'Model:getAnimationCount',
    'Model:getAnimationName',
    'Model:getAnimationDuration'
  }
}
