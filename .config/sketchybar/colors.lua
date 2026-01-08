-- Catppuccin Macchiato
return {
  black = 0xff181926,   -- Crust
  white = 0xffcad3f5,   -- Text
  red = 0xffed8796,     -- Red
  green = 0xffa6da95,   -- Green
  blue = 0xff8aadf4,    -- Blue
  yellow = 0xffeed49f,  -- Yellow
  orange = 0xfff5a97f,  -- Peach
  magenta = 0xffc6a0f6, -- Mauve
  grey = 0xff6e738d,    -- Overlay0
  transparent = 0x00000000,

  bar = {
    bg = 0xf024273a,    -- Base with ~94% alpha
    border = 0xff24273a, -- Base
  },
  popup = {
    bg = 0xc024273a,    -- Base with ~75% alpha
    border = 0xff6e738d  -- Overlay0
  },
  bg1 = 0xff363a4f,     -- Surface0
  bg2 = 0xff494d64,     -- Surface1

  with_alpha = function(color, alpha)
    if alpha > 1.0 or alpha < 0.0 then return color end
    return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
  end,
}
