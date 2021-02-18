-- A basic color object.
-- Colors can be created in 3 forms:
-- color = Color('#ffffff')
-- color = Color(255, 255, 255)
-- color = Color(1, 1, 1)
-- You can access the colors values via .r, .g, .b and .a.
-- You can create a copy of a color by calling color:clone().
Color = Object:extend()
function Color:init(r, g, b, a)
  if type(r) == "string" then
    local hex = r:gsub("#", "")
    self.r = tonumber("0x" .. hex:sub(1, 2))/255
    self.g = tonumber("0x" .. hex:sub(3, 4))/255
    self.b = tonumber("0x" .. hex:sub(5, 6))/255
    self.a = 1
  else
    if r > 1 or g > 1 or b > 1 then
      self.r = r/255
      self.g = g/255
      self.b = b/255
      self.a = (a or 255)/255
    else
      self.r = r
      self.g = g
      self.b = b
      self.a = a or 1
    end
  end
end


function Color:clone()
  return Color(self.r, self.g, self.b, self.a)
end


function Color:lighten(v)
  local h, s, l = self:_to_hsl()
  l = l + v
  self.r, self.g, self.b = self:_to_rgb(h, s, l)
  return self
end


function Color:darken(v)
  local h, s, l = self:_to_hsl()
  l = l - v
  self.r, self.g, self.b = self:_to_rgb(h, s, l)
  return self
end


function Color:fade(v)
  self.a = self.a - v
  return self
end


function Color:_to_hsl()
  local max, min = math.max(self.r, self.g, self.b), math.min(self.r, self.g, self.b)
  local h, s, l
  l = (max + min)/2
  if max == min then h, s = 0, 0
  else
    local d = max - min
    if l > 0.5 then s = d/(2 - max - min) else s = d/(max + min) end
    if max == self.r then
      h = (self.g - self.b)/d
      if self.g < self.b then h = h + 6 end
    elseif max == self.g then h = (self.b - self.r)/d + 2
    elseif max == self.b then h = (self.r - self.g)/d + 4 end
    h = h/6
  end
  return h, s, l
end


function Color:_to_rgb(h, s, l)
  if s == 0 then return math.clamp(l, 0, 1), math.clamp(l, 0, 1), math.clamp(l, 0, 1) end
  local function to(p, q, t)
    if t < 0 then t = t + 1 end
    if t > 1 then t = t - 1 end
    if t < .16667 then return p + (q - p)*6*t end
    if t < .5 then return q end
    if t < .66667 then return p + (q - p)*(.66667 - t)*6 end
    return p
  end
  local q = l < .5 and l*(1 + s) or l + s - l*s
  local p = 2*l - q
  return math.clamp(to(p, q, h + .33334), 0, 1), math.clamp(to(p, q, h), 0, 1), math.clamp(to(p, q, h - .33334), 0, 1)
end
