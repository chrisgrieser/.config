return {
  tag = 'modules',
  summary = 'Plays sound.',
  description = [[
    The `lovr.audio` module is responsible for playing sound effects and music.  To play a sound,
    create a `Source` object and call `Source:play` on it.  Currently ogg, wav, and mp3 audio
    formats are supported.
  ]],
  sections = {
    {
      name = 'Sources',
      tag = 'sources',
      description = 'Sources are objects that represent a single sound instance.'
    },
    {
      name = 'Listener',
      tag = 'listener',
      description = [[
        The listener is a virtual object in 3D space that "hears" all the sounds that are playing.
        It can be positioned and oriented in 3D space, which controls how Sources in the world are
        heard.  Usually this would be locked to the headset pose.
      ]]
    },
    {
      name = 'Devices',
      tag = 'devices',
      description = [[
        It's possible to list the available audio devices on the system, and pick a specific device
        to use for either playback or capture.  Devices can also be manually started and stopped.
        Other useful features of `lovr.audio.setDevice` include the ability to stream all audio data
        to a custom sink and the option to create a device in exclusive mode for higher performance.
        By default, the default playback device is automatically initialized and started, but this
        can be configured using `lovr.conf`.
      ]]
    }
  }
}
