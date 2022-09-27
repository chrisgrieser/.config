return {
  summary = 'An image that can be applied to Materials.',
  description = [[
    A Texture is an image that can be applied to `Material`s.  The supported file formats are
    `.png`, `.jpg`, `.hdr`, `.dds`, `.ktx`, and `.astc`.  DDS and ASTC are compressed formats, which
    are recommended because they're smaller and faster.
  ]],
  constructor = 'lovr.graphics.newTexture'
}
