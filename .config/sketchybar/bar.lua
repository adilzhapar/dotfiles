local colors = require("colors")

sbar.bar({
  height = 40,
  color = colors.transparent,
  padding_left = 4,
  padding_right = 12,
  corner_radius = 7,
  blur_radius = 0,
  notch_width = 170,
  position = "top",
  topmost = false,
  sticky = true,
})
