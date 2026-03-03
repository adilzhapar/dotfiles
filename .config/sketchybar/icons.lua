local settings = require("settings")

-- SF Symbols (default - matches reference)
local sf_symbols = {
  loading = "􀖇",
  apple = "􀣺",
  gear = "􀍟",
  cpu = "􀫥",
  clipboard = "􀉄",

  switch = { on = "􁏮", off = "􁏯" },

  volume = {
    _100 = "􀊩",
    _66 = "􀊧",
    _33 = "􀊥",
    _10 = "􀊡",
    _0 = "􀊣",
    headphones = "􀊣",
  },

  battery = {
    _100 = "􀛨",
    _75 = "􀺸",
    _50 = "􀺶",
    _25 = "􀛩",
    _0 = "􀛪",
    charging = "􀢋",
  },

  wifi = {
    upload = "􀄨",
    download = "􀄩",
    connected = "􀙇",
    disconnected = "􀙈",
    router = "􁓤",
  },
  ethernet = {
    upload = "􀄨",
    download = "􀄩",
    connected = "􀌗",
    disconnected = "􀟜",
    router = "􁓤",
  },

  media = {
    back = "􀊊",
    forward = "􀊌",
    play_pause = "􀊈",
  },

  dnd_on = "􀆺",
  dnd_off = "􀆹",
  disk = "􀋊",
  date = "􀀁",
  calendar = "􀃭",
  clock = "􀐫",

  yabai = {
    grid = "􀧍",
    stack = "􀏭",
    float = "􀢌",
    fullscreen = "􀂓",
    fullscreen_zoom = "􀂓",
    parent_zoom = "􀧋",
    split_vertical = "􀘜",
    split_horizontal = "􀧋",
  },
}

-- Nerd Font fallback
local nerdfont = {
  loading = "􀖇",
  apple = "􀣺",
  gear = "􀍟",
  cpu = "󰘚",
  clipboard = "􀉄",
  switch = { on = "􁏮", off = "􁏯" },
  volume = { _100 = "􀊩", _66 = "􀊧", _33 = "􀊥", _10 = "􀊡", _0 = "􀊣", headphones = "􀊣" },
  battery = { _100 = "􀛨", _75 = "􀺸", _50 = "􀺶", _25 = "􀛩", _0 = "􀛪", charging = "􀢋" },
  wifi = { upload = "􀄨", download = "􀄩", connected = "􀙇", disconnected = "􀙈", router = "􁓤" },
  ethernet = { upload = "􀄨", download = "􀄩", connected = "􀌗", disconnected = "􀟜", router = "􁓤" },
  media = { back = "􀊊", forward = "􀊌", play_pause = "􀊈" },
  dnd_on = "􀆺", dnd_off = "􀆹", disk = "􀋊", date = "􀀁", calendar = "􀃭", clock = "􀐫",
  yabai = { grid = "􀧍", stack = "􀏭", float = "􀢌", fullscreen = "􀂓", fullscreen_zoom = "􀂓", parent_zoom = "􀧋", split_vertical = "􀘜", split_horizontal = "􀧋" },
}

if settings.icons == "NerdFont" then
  return nerdfont
else
  return sf_symbols
end
