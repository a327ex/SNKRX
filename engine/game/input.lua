Input = Object:extend()
function Input:init(joystick_index)
  self.mouse_buttons = {"m1", "m2", "m3", "m4", "m5", "wheel_up", "wheel_down"}
  self.gamepad_buttons = {"fdown", "fup", "fleft", "fright", "dpdown", "dpup", "dpleft", "dpright", "start", "back", "guide", "leftstick", "rightstick", "rb", "lb"}
  self.index_to_gamepad_button = {["a"] = "fdown", ["b"] = "fright", ["x"] = "fleft", ["y"] = "fup", ["back"] = "back", ["start"] = "start", ["guide"] = "guide", ["leftstick"] = "leftstick",
    ["rightstick"] = "rightstick", ["leftshoulder"] = "lb", ["rightshoulder"] = "rb", ["dpdown"] = "dpdown", ["dpup"] = "dpup", ["dpleft"] = "dpleft", ["dpright"] = "dpright",
  }
  self.index_to_gamepad_axis = {["leftx"] = "leftx", ["rightx"] = "rightx", ["lefty"] = "lefty", ["righty"] = "righty", ["triggerleft"] = "lt", ["triggerright"] = "rt"}
  self.gamepad_axis = {}
  self.joystick_index = joystick_index or 1
  self.joystick = love.joystick.getJoysticks()[self.joystick_index]
  self.keyboard_state = {}
  self.previous_keyboard_state = {}
  self.mouse_state = {}
  self.previous_mouse_state = {}
  self.gamepad_state = {}
  self.previous_gamepad_state = {}
  self.actions = {}
  self.textinput_buffer = ''
end


function Input:update(dt)
  for _, action in ipairs(self.actions) do
    self[action].pressed = false
    self[action].down = false
    self[action].released = false
  end

  for _, action in ipairs(self.actions) do
    for _, key in ipairs(self[action].keys) do
      if table.contains(self.mouse_buttons, key) then
        self[action].pressed = self[action].pressed or (self.mouse_state[key] and not self.previous_mouse_state[key])
        self[action].down = self[action].down or self.mouse_state[key]
        self[action].released = self[action].released or (not self.mouse_state[key] and  self.previous_mouse_state[key])
      elseif table.contains(self.gamepad_buttons, key) then
        self[action].pressed = self[action].pressed or (self.gamepad_state[key] and not self.previous_gamepad_state[key])
        self[action].down = self[action].down or self.gamepad_state[key]
        self[action].released = self[action].released or (not self.gamepad_state[key] and  self.previous_gamepad_state[key])
      else
        self[action].pressed = self[action].pressed or (self.keyboard_state[key] and not self.previous_keyboard_state[key])
        self[action].down = self[action].down or self.keyboard_state[key]
        self[action].released = self[action].released or (not self.keyboard_state[key] and self.previous_keyboard_state[key])
      end
    end
  end

  self.previous_mouse_state = table.copy(self.mouse_state)
  self.previous_gamepad_state = table.copy(self.gamepad_state)
  self.previous_keyboard_state = table.copy(self.keyboard_state)
  self.mouse_state.wheel_up = false
  self.mouse_state.wheel_down = false
end


function Input:set_mouse_grabbed(v)
  love.mouse.setGrabbed(v)
end


function Input:set_mouse_visible(v)
  love.mouse.setVisible(v)
end


function Input:bind(action, keys)
  if not self[action] then self[action] = {} end
  if type(keys) == "string" then self[action].keys = {keys}
  elseif type(keys) == "table" then self[action].keys = keys end
  table.insert(self.actions, action)
end


function Input:unbind(action)
  self[action] = nil
end


function Input:axis(key)
  return self.gamepad_axis[key]
end


function Input:textinput(text)
  self.textinput_buffer = self.textinput_buffer .. text
  return self.textinput_buffer
end


function Input:get_and_clear_textinput_buffer()
  local buffer = self.textinput_buffer
  self.textinput_buffer = ""
  return buffer
end


function Input:bind_all()
  -- Set direct input binds for every keyboard and mouse key
  -- Mostly to be used if you want to skip the action system and refer to keys directly (i.e. for internal tools or menus that don't need their keys changed ever)
  local keyboard_binds = {['a'] = {'a'}, ['b'] = {'b'}, ['c'] = {'c'}, ['d'] = {'d'}, ['e'] = {'e'}, ['f'] = {'f'}, ['g'] = {'g'}, ['h'] = {'h'}, ['i'] = {'i'}, ['j'] = {'j'}, ['k'] = {'k'}, ['l'] = {'l'}, ['m'] = {'m'}, ['n'] = {'n'}, ['o'] = {'o'}, ['p'] = {'p'}, ['q'] = {'q'}, ['r'] = {'r'}, ['s'] = {'s'}, ['t'] = {'t'}, ['u'] = {'u'}, ['v'] = {'v'}, ['w'] = {'w'}, ['x'] = {'x'}, ['y'] = {'y'}, ['z'] = {'z'}, ['0'] = {'0'}, ['1'] = {'1'}, ['2'] = {'2'}, ['3'] = {'3'}, ['4'] = {'4'}, ['5'] = {'5'}, ['6'] = {'6'}, ['7'] = {'7'}, ['8'] = {'8'}, ['9'] = {'9'}, ['space'] = {'space'}, ['!'] = {'!'}, ['"'] = {'"'}, ['#'] = {'#'}, ['$'] = {'$'}, ['&'] = {'&'}, ["'"] = {"'"}, ['('] = {'('}, [')'] = {')'}, ['*'] = {'*'}, ['+'] = {'+'}, [','] = {','}, ['-'] = {'-'}, ['.'] = {'.'}, ['/'] = {'/'}, [':'] = {':'}, [';'] = {';'}, ['kp0'] = {'kp0'}, ['kp1'] = {'kp1'}, ['kp2'] = {'kp2'}, ['kp3'] = {'kp3'}, ['kp4'] = {'kp4'}, ['kp5'] = {'kp5'}, ['kp6'] = {'kp6'}, ['kp7'] = {'kp7'}, ['kp8'] = {'kp8'}, ['kp9'] = {'kp9'}, ['kp.'] = {'kp.'}, ['kp,'] = {'kp,'}, ['kp/'] = {'kp/'}, ['kp*'] = {'kp*'}, ['kp-'] = {'kp-'}, ['kp+'] = {'kp+'}, ['kpenter'] = {'kpenter'}, ['kp='] = {'kp='}, ['up'] = {'up'}, ['down'] = {'down'}, ['right'] = {'right'}, ['left'] = {'left'}, ['home'] = {'home'}, ['pageup'] = {'pageup'}, ['pagedown'] = {'pagedown'}, ['insert'] = {'insert'}, ['backspace'] = {'backspace'}, ['tab'] = {'tab'}, ['clear'] = {'clear'}, ['return'] = {'return'}, ['delete'] = {'delete'}, ['f1'] = {'f1'}, ['f2'] = {'f2'}, ['f3'] = {'f3'}, ['f4'] = {'f4'}, ['f5'] = {'f5'}, ['f6'] = {'f6'}, ['f7'] = {'f7'}, ['f8'] = {'f8'}, ['f9'] = {'f9'}, ['f10'] = {'f10'}, ['f11'] = {'f11'}, ['f12'] = {'f12'}, ['f13'] = {'f13'}, ['f14'] = {'f14'}, ['f15'] = {'f15'}, ['f16'] = {'f16'}, ['f17'] = {'f17'}, ['f18'] = {'f18'}, ['numlock'] = {'numlock'}, ['capslock'] = {'capslock'}, ['scrolllock'] = {'scrolllock'}, ['rshift'] = {'rshift'}, ['lshift'] = {'lshift'}, ['rctrl'] = {'rctrl'}, ['lctrl'] = {'lctrl'}, ['ralt'] = {'ralt'}, ['lalt'] = {'lalt'}, ['rgui'] = {'rgui'}, ['lgui'] = {'lgui'}, ['mode'] = {'mode'}, ['escape'] = {'escape'}}
  for k, v in pairs(keyboard_binds) do self:bind(k, v) end
  self:bind('m1', {'m1'})
  self:bind('m2', {'m2'})
  self:bind('m3', {'m3'})
  self:bind('m4', {'m4'})
  self:bind('m5', {'m5'})
  self:bind('wheel_up', {'wheel_up'})
  self:bind('wheel_down', {'wheel_down'})
end
