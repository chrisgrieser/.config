local ffi = require 'ffi'
local C = ffi.os == 'Windows' and ffi.load('glfw3') or ffi.C

ffi.cdef [[
  enum {
    GLFW_CURSOR = 0x00033001,
    GLFW_CURSOR_NORMAL = 0x00034001,
    GLFW_CURSOR_HIDDEN = 0x00034002,
    GLFW_CURSOR_DISABLED = 0x00034003,
    GLFW_ARROW_CURSOR = 0x00036001,
    GLFW_IBEAM_CURSOR = 0x00036002,
    GLFW_CROSSHAIR_CURSOR = 0x00036003,
    GLFW_HAND_CURSOR = 0x00036004,
    GLFW_HRESIZE_CURSOR = 0x00036005,
    GLFW_VRESIZE_CURSOR = 0x00036006
  };

  typedef struct {
    int width;
    int height;
    unsigned char* pixels;
  } GLFWimage;

  typedef struct GLFWcursor GLFWcursor;
  typedef struct GLFWwindow GLFWwindow;
  typedef void(*GLFWmousebuttonfun)(GLFWwindow*, int, int, int);
  typedef void(*GLFWcursorposfun)(GLFWwindow*, double, double);
  typedef void(*GLFWscrollfun)(GLFWwindow*, double, double);

  GLFWwindow* glfwGetCurrentContext(void);
  void glfwGetInputMode(GLFWwindow* window, int mode);
  void glfwSetInputMode(GLFWwindow* window, int mode, int value);
  void glfwGetCursorPos(GLFWwindow* window, double* x, double* y);
  void glfwSetCursorPos(GLFWwindow* window, double x, double y);
  GLFWcursor* glfwCreateCursor(const GLFWimage* image, int xhot, int yhot);
  GLFWcursor* glfwCreateStandardCursor(int kind);
  void glfwSetCursor(GLFWwindow* window, GLFWcursor* cursor);
  int glfwGetMouseButton(GLFWwindow* window, int button);
  void glfwGetWindowSize(GLFWwindow* window, int* width, int* height);
  GLFWmousebuttonfun glfwSetMouseButtonCallback(GLFWwindow* window, GLFWmousebuttonfun callback);
  GLFWcursorposfun glfwSetCursorPosCallback(GLFWwindow* window, GLFWcursorposfun callback);
  GLFWcursorposfun glfwSetScrollCallback(GLFWwindow* window, GLFWscrollfun callback);
]]

local window = C.glfwGetCurrentContext()

local mouse = {}

-- LÖVR uses framebuffer scale for everything, but glfw uses window scale for events.
-- It is necessary to convert between the two at all boundaries.
function mouse.getScale()
  local x, _ = ffi.new('int[1]'), ffi.new('int[1]')
  C.glfwGetWindowSize(window, x, _)
  return lovr.graphics.getWidth() / x[0]
end

function mouse.getX()
  local x = ffi.new('double[1]')
  C.glfwGetCursorPos(window, x, nil)
  return x[0] * mouse.getScale()
end

function mouse.getY()
  local y = ffi.new('double[1]')
  C.glfwGetCursorPos(window, nil, y)
  return y[0] * mouse.getScale()
end

function mouse.getPosition()
  local x, y = ffi.new('double[1]'), ffi.new('double[1]')
  local scale = mouse.getScale()
  C.glfwGetCursorPos(window, x, y)
  return x[0] * scale, y[0] * scale
end

function mouse.setX(x)
  local y = mouse.getY()
  local scale = mouse.getScale()
  C.glfwSetCursorPos(window, x / scale, y / scale)
end

function mouse.setY(y)
  local x = mouse.getX()
  local scale = mouse.getScale()
  C.glfwSetCursorPos(window, x / scale, y / scale)
end

function mouse.setPosition(x, y)
  local scale = mouse.getScale()
  C.glfwSetCursorPos(window, x / scale, y / scale)
end

function mouse.isDown(button, ...)
  if not button then return false end
  return C.glfwGetMouseButton(window, button - 1) > 0 or mouse.isDown(...)
end

function mouse.getRelativeMode()
  return C.glfwGetInputMode(window, C.GLFW_CURSOR) == C.GLFW_CURSOR_DISABLED
end

function mouse.setRelativeMode(enable)
  C.glfwSetInputMode(window, C.GLFW_CURSOR, enable and C.GLFW_CURSOR_DISABLED or C.GLFW_CURSOR_NORMAL)
end

function mouse.newCursor(source, hotx, hoty)
  if type(source) == 'string' or tostring(source) == 'Blob' then
    source = lovr.data.newImage(source, false)
  else
    assert(tostring(source) == 'Image', 'Bad argument #1 to newCursor (Image expected)')
  end
  local image = ffi.new('GLFWimage', source:getWidth(), source:getHeight(), source:getPointer())
  return C.glfwCreateCursor(image, hotx or 0, hoty or 0)
end

function mouse.getSystemCursor(kind)
  local kinds = {
    arrow = C.GLFW_ARROW_CURSOR,
    ibeam = C.GLFW_IBEAM_CURSOR,
    crosshair = C.GLFW_CROSSHAIR_CURSOR,
    hand = C.GLFW_HAND_CURSOR,
    sizewe = C.GLFW_HRESIZE_CURSOR,
    sizens = C.GLFW_VRESIZE_CURSOR
  }
  assert(kinds[kind], string.format('Unknown cursor %q', tostring(kind)))
  return C.glfwCreateStandardCursor(kinds[kind])
end

function mouse.setCursor(cursor)
  C.glfwSetCursor(window, cursor)
end

C.glfwSetMouseButtonCallback(window, function(target, button, action, mods)
  if target == window then
    local x, y = mouse.getPosition()
    lovr.event.push(action > 0 and 'mousepressed' or 'mousereleased', x, y, button + 1, false)
  end
end)

local px, py = mouse.getPosition()
C.glfwSetCursorPosCallback(window, function(target, x, y)
  if target == window then
    local scale = mouse.getScale()
    x = x * scale
    y = y * scale
    lovr.event.push('mousemoved', x, y, x - px, y - py, false)
    px, py = x, y
  end
end)

C.glfwSetScrollCallback(window, function(target, x, y)
  if target == window then
    local scale = mouse.getScale()
    lovr.event.push('wheelmoved', x * scale, y * scale)
  end
end)

return mouse
