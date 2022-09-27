return {
  summary = 'An asset imported from a 3D model file.',
  description = [[
    A Model is a drawable object loaded from a 3D file format.  The supported 3D file formats are
    OBJ, glTF, and STL.
  ]],
  constructors = {
    'lovr.graphics.newModel',
    'lovr.headset.newModel'
  },
  example = [[
    local model

    function lovr.load()
      model = lovr.graphics.newModel('assets/model.gltf')
    end

    function lovr.draw()
      model:draw(0, 1, -1, 1, lovr.timer.getTime())
    end
  ]]
}
