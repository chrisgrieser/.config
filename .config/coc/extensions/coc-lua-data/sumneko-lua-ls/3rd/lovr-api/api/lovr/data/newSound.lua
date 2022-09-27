return {
  summary = 'Create a new Sound.',
  description = [[
    Creates a new Sound.  A sound can be loaded from an audio file, or it can be created empty with
    capacity for a certain number of audio frames.

    When loading audio from a file, use the `decode` option to control whether compressed audio
    should remain compressed or immediately get decoded to raw samples.

    When creating an empty sound, the `contents` parameter can be set to `'stream'` to create an
    audio stream.  On streams, `Sound:setFrames` will always write to the end of the stream, and
    `Sound:getFrames` will always read the oldest samples from the beginning.  The number of frames
    in the sound is the total capacity of the stream's buffer.
  ]],
  arguments = {
    frames = {
      type = 'number',
      description = 'The number of frames the Sound can hold.'
    },
    format = {
      type = 'SampleFormat',
      default = [['f32']],
      description = 'The sample data type.'
    },
    channels = {
      type = 'ChannelLayout',
      default = [['stereo']],
      description = 'The channel layout.'
    },
    sampleRate = {
      type = 'number',
      default = '48000',
      description = 'The sample rate, in Hz.'
    },
    contents = {
      type = '*',
      default = 'nil',
      description = [[
        A Blob containing raw audio samples to use as the initial contents, 'stream' to create an
        audio stream, or `nil` to leave the data initialized to zero.
      ]]
    },
    filename = {
      type = 'string',
      description = 'The filename of a sound to load.'
    },
    blob = {
      type = 'Blob',
      description = 'The Blob containing audio file data to load.'
    },
    decode = {
      type = 'boolean',
      description = 'Whether compressed audio files should be immediately decoded.'
    }
  },
  returns = {
    sound = {
      type = 'Sound',
      description = 'Sounds good.'
    }
  },
  variants = {
    {
      description = 'Create a raw or stream Sound from a frame count and format info:',
      arguments = { 'frames', 'format', 'channels', 'sampleRate', 'contents' },
      returns = { 'sound' }
    },
    {
      description = [[
        Load a sound from a file.  Compressed audio formats (OGG, MP3) can optionally be decoded
        into raw sounds.
      ]],
      arguments = { 'filename', 'decode' },
      returns = { 'sound' }
    },
    {
      description = [[
        Load a sound from a Blob containing the data of an audio file.  Compressed audio formats
        (OGG, MP3) can optionally be decoded into raw sounds.

        If the Blob contains raw audio samples, use the first variant instead of this one.
      ]],
      arguments = { 'blob', 'decode' },
      returns = { 'sound' }
    }
  },
  notes = [[
    It is highly recommended to use an audio format that matches the format of the audio module:
    `f32` sample formats at a sample rate of 48000, with 1 channel for spatialized sources or 2
    channels for unspatialized sources.  This will avoid the need to convert audio during playback,
    which boosts performance of the audio thread.

    The WAV importer supports 16, 24, and 32 bit integer data and 32 bit floating point data.  The
    data must be mono, stereo, or 4-channel full-sphere ambisonic.  The `WAVE_FORMAT_EXTENSIBLE`
    extension is supported.

    Ambisonic channel layouts are supported for import (but not yet for playback).  Ambisonic data
    can be loaded from WAV files.  It must be first-order full-sphere ambisonic data with 4
    channels.  If the WAV has a `WAVE_FORMAT_EXTENSIBLE` chunk with an `AMBISONIC_B_FORMAT` format
    GUID, then the data is understood as using the AMB format with Furse-Malham channel ordering and
    normalization.  *All other* 4-channel files are assumed to be using the AmbiX format with ACN
    channel ordering and SN3D normalization.  AMB files will get automatically converted to AmbiX on
    import, so ambisonic Sounds will always be in a consistent format.

    OGG and MP3 files will always have the `f32` format when loaded.
  ]]
}
