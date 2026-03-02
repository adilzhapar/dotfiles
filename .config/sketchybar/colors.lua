-- Theme support: Catppuccin (default) or Dracula
local settings = require("settings")

local function hex(hex_str)
  return tonumber(hex_str:gsub("#", ""), 16)
end

-- Catppuccin Macchiato (default)
local CATPPUCCIN = {
  blue = 0xff8aadf4,
  teal = 0xff94e2d5,
  cyan = 0xff89dceb,
  grey = 0xff6e738d,
  green = 0xffa6da95,
  yellow = 0xffeed49f,
  orange = 0xfff5a97f,
  red = 0xffed8796,
  purple = 0xffc6a0f6,
  maroon = 0xffeba0ac,
  black = 0xff24273a,
  trueblack = 0xff000000,
  white = 0xffcad3f5,
}

-- Dracula Refined
local DRACULA = {
  blue = 0xff6272a4,
  teal = 0xff69ff94,
  cyan = 0xff8be9fd,
  grey = 0xff44475a,
  green = 0xff50fa7b,
  yellow = 0xfff1fa8c,
  orange = 0xffffb86c,
  red = 0xffff5555,
  purple = 0xffbd93f9,
  maroon = 0xffff79c6,
  black = 0xff282a36,
  trueblack = 0xff1c1c1c,
  white = 0xfff8f8f2,
}

local palette = (settings.theme == "dracula") and DRACULA or CATPPUCCIN

local colors = {
  -- Base palette (from active theme)
  blue = palette.blue,
  teal = palette.teal,
  cyan = palette.cyan,
  grey = palette.grey,
  green = palette.green,
  yellow = palette.yellow,
  orange = palette.orange,
  red = palette.red,
  purple = palette.purple,
  maroon = palette.maroon,
  black = palette.black,
  white = palette.white,

  transparent = 0x00000000,

  bar = {
    bg = (palette.black & 0x00ffffff) | (0xf0 << 24),
    border = palette.black,
  },
  popup = {
    bg = (palette.black & 0x00ffffff) | (0xc0 << 24),
    border = palette.grey,
  },
  bg1 = 0xff363a4f,   -- Surface0 (Catppuccin)
  bg2 = 0xff494d64,   -- Surface1 (Catppuccin)

  -- Token aliases for new config compatibility
  highlight = palette.cyan,
  icon_color = palette.white,
  icon_color_inactive = (palette.white & 0x00ffffff) | (0x40 << 24),
  label_color = (palette.white & 0x00ffffff) | (0xBF << 24),
}

-- Override bg1/bg2 for Dracula
if settings.theme == "dracula" then
  colors.bg1 = 0xff44475a
  colors.bg2 = 0xff6272a4
end

function colors.with_alpha(color, alpha)
  if alpha > 1.0 or alpha < 0.0 then return color end
  return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
end

-- get_color(name, opacity_percent) for compatibility with new config patterns
function colors.get_color(name, opacity)
  local c = palette[name] or palette.white
  if not opacity or opacity >= 100 then return c end
  local alpha = math.floor((opacity / 100) * 255)
  return (c & 0x00ffffff) | (alpha << 24)
end

return colors
