local colors = require("colors")

sbar.bar({
  height = 40,
  color = colors.bar.bg,
  padding_left = 4,
  padding_right = 12,
  corner_radius = 7,
  blur_radius = 32,
  notch_width = 170,
  position = "top",
  topmost = false,
  sticky = true,
})
