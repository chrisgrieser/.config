return {
  summary = 'Application permissions.',
  description = [[
    These are the different permissions that need to be requested using
    `lovr.system.requestPermission` on some platforms.
  ]],
  values = {
    {
      name = 'audiocapture',
      description = 'Requests microphone access.'
    }
  },
  related = {
    'lovr.system.requestPermission'
  }
}
