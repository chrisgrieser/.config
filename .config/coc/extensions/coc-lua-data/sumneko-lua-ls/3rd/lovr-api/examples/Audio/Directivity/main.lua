function lovr.load()
  source = lovr.audio.newSource('sine.wav')
  source:setEffectEnabled('spatialization')
  source:setDirectivity(.5, 2.0)
  source:setLooping(true)
  source:setVolume(.8)
  source:play()
end

function lovr.update(dt)
  local x, y, z = 0, 1, -1
  local yaw = lovr.timer.getTime() * 2
  source:setPose(x, y, z, yaw, 0, 1, 0)
  lovr.audio.setPose(lovr.headset.getPose())
end

function lovr.draw()
  shader = shader or lovr.graphics.newShader(
    [[out vec3 vNormal;
      vec4 position(mat4 p, mat4 t, vec4 v) {
        vNormal = normalize(lovrNormalMatrix * lovrNormal);
        return p * t * v;
      }]],
    [[in vec3 vNormal;
      vec4 color(vec4 g, sampler2D i, vec2 uv) {
        vec3 L = vec3(0., 1., 0.);
        vec3 N = normalize(vNormal);
        float NoL = dot(N, L) * .5 + .5;
        return vec4(vec3(NoL), 1.);
      }
    ]]
  )
  lovr.graphics.setShader(shader)
  local length = .1
  local r1, r2 = .06, .01
  local x, y, z, angle, ax, ay, az = source:getPose()
  lovr.graphics.cylinder(x, y, z, length, angle, ax, ay, az, r1, r2)
  lovr.graphics.setShader()
  if lovr.audio.getSpatializer() ~= 'phonon' then
    lovr.graphics.print('Warning: phonon spatializer is not active', 0, 1.2, -1, .05)
  end
end
