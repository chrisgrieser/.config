-- This demo renders a scene to a canvas, then renders the canvas to screen filtered through a shader.
--
-- Sample contributed by andi mcc

local useCanvas = true -- Set this to false to see the scene with no postprocessing.

-- A shader program consists of a vertex shader (which describes how to transform polygons)
-- and a fragment shader (which describes how to color pixels).
-- For a full-screen shader, the vertex shader should just pass the polygon through unaltered.
-- This is the same as the "default" full-screen shader used by lovr.graphics.plane:
local screenShaderVertex = [[
  vec4 position(mat4 projection, mat4 transform, vec4 vertex) {
    return vertex;
  }
]]

-- For the fragment shader: We are going to create a separable gaussian blur.
-- A "separable" blur means we first blur horizontally, then blur vertically to get a 2D blur.
local screenShaderFragment = [[
  // This one-dimensional blur filter samples five points and averages them by different amounts.
  // Weights and offsets taken from http://rastergrid.com/blog/2010/09/efficient-gaussian-blur-with-linear-sampling/

  // The weights for the center, one-point-out, and two-point-out samples
  #define WEIGHT0 0.2270270270
  #define WEIGHT1 0.3162162162
  #define WEIGHT2 0.0702702703

  // The distances-from-center for the samples
  #define OFFSET1 1.3846153846
  #define OFFSET2 3.2307692308

  // The Canvas texture to sample from.
  uniform sampler2DMultiview canvas;

  // UVs are sampled from a texture over the range 0..1.
  // This uniform is set outside the shader so we know what UV distance "one pixel" is.
  uniform vec2 resolution;

  // This uniform will be set every draw to determine whether we are sampling horizontally or vertically.
  uniform vec2 direction;

  // lovr's shader architecture will automatically supply a main(), which will call this color() function
  vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) {
    vec2 pixelOff = direction / resolution;
    vec4 color = vec4(0.0);
    color += textureMultiview(canvas, uv) * WEIGHT0;
    color += textureMultiview(canvas, uv + pixelOff * OFFSET1) * WEIGHT1;
    color += textureMultiview(canvas, uv - pixelOff * OFFSET1) * WEIGHT1;
    color += textureMultiview(canvas, uv + pixelOff * OFFSET2) * WEIGHT2;
    color += textureMultiview(canvas, uv - pixelOff * OFFSET2) * WEIGHT2;
    return color;
  }
]]

-- The vertex and fragment shaders will be combined together into a shader program
local screenShader

-- Image of an eyechart
local eyechart

-- This table will contain two canvases we will use as scratch space
local tempCanvas

function lovr.load()
  -- Load the eyechart image
  -- Source: https://www.publicdomainpictures.net/view-image.php?image=244244&picture=eye-chart-test-vintage
  -- Creative Commons 0 / Public Domain license
  local texture = lovr.graphics.newTexture('eye-chart-test-vintage-cc0.jpg')
  local textureWidth, textureHeight = texture:getDimensions()
  eyechart = {
    scale = .75,
    aspect = textureHeight / textureWidth,
    material = lovr.graphics.newMaterial( texture )
  }

  -- Configure the shader
  if useCanvas then
    local width, height = lovr.headset.getDisplayDimensions()

    -- Compile the shader
    screenShader = lovr.graphics.newShader(screenShaderVertex, screenShaderFragment)

    -- Set the resolution uniform
    screenShader:send("resolution", {width, height})

    -- Create two temporary canvases
    tempCanvas = {
      lovr.graphics.newCanvas(width, height),
      lovr.graphics.newCanvas(width, height)
    }

    tempCanvas[1]:getTexture():setWrap('clamp')
    tempCanvas[2]:getTexture():setWrap('clamp')
  end
end

-- The scene is drawn in this callback
local function sceneDraw()
  lovr.graphics.clear() -- Because we are drawing to a canvas, we must manually clear
  lovr.graphics.setShader(nil)

  -- Draw text on the left and right
  for _, sign in ipairs {-1, 1} do
    lovr.graphics.push()
    lovr.graphics.rotate(sign * math.pi/2, 0, 1, 0)
    lovr.graphics.print("MOVE CLOSER", 0, 0, -10, 5)
    lovr.graphics.pop()
  end

  lovr.graphics.plane(eyechart.material, 0, 1.7, -1, eyechart.scale, eyechart.scale * eyechart.aspect)
end

-- This simple callback is used to draw one canvas onto another
local function fullScreenDraw(source)
  screenShader:send('canvas', source:getTexture())
  lovr.graphics.fill()
end

function lovr.draw()
  if not useCanvas then

    -- No-postprocessing path: Call scene-draw callback without doing anything fancy
    sceneDraw()

  else

    -- Start by drawing the scene to one of our temp canvases.
    tempCanvas[1]:renderTo(sceneDraw)
    tempCanvas[2]:renderTo(function() lovr.graphics.clear() end)

    -- We now have the scene in a texture (a canvas), which means we can apply a full-screen effect
    -- by rendering the texture with a shader material. However, because our blur is separable,
    -- we will need to do this twice, once for horizontal blur and once for vertical.
    -- We would also like to do multiple blur passes at larger and larger scales, to get a blurrier blur.
    -- To achieve these many passes we will render from canvas A into B, and then B back into A, and repeat.
    lovr.graphics.setShader(screenShader)

    screenShader:send("direction", {1, 0})
    tempCanvas[2]:renderTo(fullScreenDraw, tempCanvas[1])

    screenShader:send("direction", {0, 1})
    tempCanvas[1]:renderTo(fullScreenDraw, tempCanvas[2])

    screenShader:send("direction", {2, 0})
    tempCanvas[2]:renderTo(fullScreenDraw, tempCanvas[1])

    screenShader:send("direction", {0, 2})
    tempCanvas[1]:renderTo(fullScreenDraw, tempCanvas[2])

    screenShader:send("direction", {4, 0})
    tempCanvas[2]:renderTo(fullScreenDraw, tempCanvas[1])

    screenShader:send("direction", {0, 4})
    screenShader:send("canvas", tempCanvas[2]:getTexture())
    lovr.graphics.fill() -- On the final pass, render directly to the screen.
  end
end
