return {
  description = 'Different types of input devices supported by the `lovr.headset` module.',
  values = {
    {
      name = 'head',
      description = 'The headset.'
    },
    {
      name = 'hand/left',
      description = 'The left controller.'
    },
    {
      name = 'hand/right',
      description = 'The right controller.'
    },
    {
      name = 'left',
      description = 'A shorthand for hand/left.'
    },
    {
      name = 'right',
      description = 'A shorthand for hand/right.'
    },
    {
      name = 'elbow/left',
      description = 'A device tracking the left elbow.'
    },
    {
      name = 'elbow/right',
      description = 'A device tracking the right elbow.'
    },
    {
      name = 'shoulder/left',
      description = 'A device tracking the left shoulder.'
    },
    {
      name = 'shoulder/right',
      description = 'A device tracking the right shoulder.'
    },
    {
      name = 'chest',
      description = 'A device tracking the chest.'
    },
    {
      name = 'waist',
      description = 'A device tracking the waist.'
    },
    {
      name = 'knee/left',
      description = 'A device tracking the left knee.'
    },
    {
      name = 'knee/right',
      description = 'A device tracking the right knee.'
    },
    {
      name = 'foot/left',
      description = 'A device tracking the left foot or ankle.'
    },
    {
      name = 'foot/right',
      description = 'A device tracking the right foot or ankle.'
    },
    {
      name = 'camera',
      description = 'A device used as a camera in the scene.'
    },
    {
      name = 'keyboard',
      description = 'A tracked keyboard.'
    },
    {
      name = 'eye/left',
      description = 'The left eye.'
    },
    {
      name = 'eye/right',
      description = 'The right eye.'
    },
    {
      name = 'beacon/1',
      description = 'The first tracking device (i.e. lighthouse).'
    },
    {
      name = 'beacon/2',
      description = 'The second tracking device (i.e. lighthouse).'
    },
    {
      name = 'beacon/3',
      description = 'The third tracking device (i.e. lighthouse).'
    },
    {
      name = 'beacon/4',
      description = 'The fourth tracking device (i.e. lighthouse).'
    }
  },
  related = {
    'DeviceAxis',
    'DeviceButton',
    'lovr.headset.getPose',
    'lovr.headset.getPosition',
    'lovr.headset.getOrientation',
    'lovr.headset.getVelocity',
    'lovr.headset.getAngularVelocity',
    'lovr.headset.getSkeleton',
    'lovr.headset.isTracked',
    'lovr.headset.isDown',
    'lovr.headset.isTouched',
    'lovr.headset.wasPressed',
    'lovr.headset.wasReleased',
    'lovr.headset.getAxis',
    'lovr.headset.vibrate',
    'lovr.headset.animate'
  }
}
