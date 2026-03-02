local settings = require("settings")
local colors = require("colors")

local paddings = settings.paddings

sbar.default({
  updates = "when_shown",
  icon = {
    font = { family = settings.font.text, style = settings.font.style_map["Bold"], size = 14 },
    color = colors.icon_color,
    highlight_color = colors.highlight,
    padding_left = 0,
    padding_right = 0,
    background = { corner_radius = 7 },
  },
  label = {
    font = { family = settings.font.text, style = settings.font.style_map["Semibold"], size = 13 },
    color = colors.label_color,
    highlight_color = colors.highlight,
    padding_left = paddings,
    padding_right = paddings,
  },
  background = {
    height = 24,
    corner_radius = 7,
    padding_left = paddings,
    padding_right = paddings,
  },
  popup = {
    background = {
      color = colors.popup.bg,
      corner_radius = 7,
      shadow = { drawing = true, color = colors.bar.bg, angle = 90, distance = 64 },
    },
    blur_radius = 32,
  },
  padding_left = 4,
  padding_right = 4,
  scroll_texts = true,
})
