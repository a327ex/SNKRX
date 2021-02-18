-- The base Vector class.
local EPSILON = 0.0001
local EPSILON_SQUARED = EPSILON*EPSILON
Vector = Object:extend()
function Vector:init(x, y)
  self.x = x or 0
  self.y = y or x or 0
end


function Vector:clone()
  return Vector(self.x, self.y)
end


function Vector:unpack()
  return self.x, self.y
end


function Vector.__tostring(self)
  return "(" .. tonumber(self.x) .. ", " .. tonumber(self.y) .. ")"
end


function Vector:set(x, y)
  if not y then
    self.x = x.x
    self.y = x.y
  else
    self.x = x
    self.y = y
  end
  return self
end


function Vector:add(x, y)
  if not y then
    self.x = self.x + x.x
    self.y = self.y + x.y
  else
    self.x = self.x + x
    self.y = self.y + y
  end
  return self
end


function Vector:sub(x, y)
  if not y then
    self.x = self.x - x.x
    self.y = self.y - x.y
  else
    self.x = self.x - x
    self.y = self.y - y
  end
  return self
end


function Vector:mul(s)
  if type(s) == "table" then
    self.x = self.x*s.x
    self.y = self.y*s.y
  else
    self.x = self.x*s
    self.y = self.y*s
  end
  return self
end


function Vector:div(s)
  if type(s) == "table" then
    self.x = self.x*s.x
    self.y = self.y*s.y
  else
    self.x = self.x/s
    self.y = self.y/s
  end
  return self
end


function Vector:scale(k)
  self.x = self.x*k
  self.y = self.y*k
  return self
end


function Vector:rotate(p, r)
  local cos = math.cos(r)
  local sin = math.sin(r)
  local dx = self.x - p.x
  local dy = self.y - p.y
  self.x = dx*cos - sin*dy + p.x
  self.y = sin*dx + cos*dy + p.y
  return self
end


function Vector:floor()
  self.x = math.floor(self.x)
  self.y = math.floor(self.y)
  return self
end


function Vector:ceil()
  self.x = math.ceil(self.x)
  self.y = math.ceil(self.y)
  return self
end


function Vector:round(p)
  self.x = math.round(self.x, p)
  self.y = math.round(self.y, p)
  return self
end


function Vector:dot(v)
  return self.x*v.x + self.y*v.y
end


function Vector:is_perpendicular(v)
  return math.abs(self:dot(v)) < EPSILON_SQUARED
end


function Vector:cross(v)
  return self.x*v.y - self.y*v.x
end


function Vector:is_parallel(v)
  return math.abs(self:cross(v)) < EPSILON_SQUARED
end


function Vector:is_set()
  return self.x or self.y
end


function Vector:is_zero()
  return math.abs(self.x) < EPSILON and math.abs(self.y) < EPSILON
end


function Vector:zero()
  self.x = 0
  self.y = 0
  return self
end


function Vector:length()
  return math.sqrt(self.x*self.x + self.y*self.y)
end


function Vector:length_squared()
  return self.x*self.x + self.y*self.y
end


function Vector:normalize()
  if self:is_zero() then return self end
  return self:scale(1/self:length())
end


function Vector:perpendicular()
  return Vector(-self.y, self.x)
end


function Vector:left_normal()
  return Vector(self.y, -self.x)
end


function Vector:invert()
  self.x = self.x*-1
  self.y = self.y*-1
  return self
end


function Vector:project_to(v)
  local lsq = v:length_squared()
  local dp = self:dot(v)
  return Vector(dp*v.x/lsq, dp*v.y/lsq)
end


function Vector:truncate(max)
  local s = max*max/self:length_squared()
  s = (s > 1 and 1) or math.sqrt(s)
  self.x = self.x*s
  self.y = self.y*s
  return self
end


function Vector:angle_to(v)
  return math.atan2(v.y - self.y, v.x - self.x)
end


function Vector:angle()
  return math.atan2(self.y, self.x)
end


function Vector:distance_squared(v)
  local dx = v.x - self.x
  local dy = v.y - self.y
  return dx*dx + dy*dy
end


function Vector:distance(v)
  return math.sqrt(self:distance_squared(v))
end


function Vector:bounce(normal, bounce_coefficient)
  local d = (1 + (bounce_coefficient or 1))*self:dot(normal)
  self.x = self.x - d*normal.x
  self.y = self.y - d*normal.y
  return self
end


function Vector:overlaps_with_circle(cx, cy, r)
  return mlib.circle.checkPoint(self.x, self.y, cx, cy, r)
end


function Vector:overlaps_with_polygon(vs)
  return mlib.polygon.checkPoint(self.x, self.y, vs)
end


function Vector:overlaps_with_rectangle(x, y, w, h)
  return mlib.polygon.checkPoint(self.x, self.y, x - w/2, y - h/2, x + w/2, y - h/2, x + w/2, y + h/2, x - w/2, y + h/2)
end
