return {
  summary = 'Different access hints for shader resources.',
  description = [[
    When binding writable resources to shaders using `Shader:sendBlock` and `Shader:sendImage`, an
    access pattern can be specified as a hint that says whether you plan to read or write to the
    resource (or both).  Sometimes, LÖVR or the GPU driver can use this hint to get better
    performance or avoid stalling.
  ]],
  values = {
    {
      name = 'read',
      description = 'The Shader will use the resource in a read-only fashion.'
    },
    {
      name = 'write',
      description = 'The Shader will use the resource in a write-only fashion.'
    },
    {
      name = 'readwrite',
      description = 'The resource will be available for reading and writing.'
    }
  }
}
