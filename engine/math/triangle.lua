-- An isosceles triangle class. This is a triangle with size w, h centered on x, y pointed to the right (angle 0).
-- Implements every function that Polygon does.
Triangle = Object:extend()
Triangle:implement(Polygon)
function Triangle:init(x, y, w, h)
  self.x, self.y, self.w, self.h = x, y, w, h
  local x1, y1 = x + h/2, y
  local x2, y2 = x - h/2, y - w/2
  local x3, y3 = x - h/2, y + w/2
  self.vertices = {x1, y1, x2, y2, x3, y3}
  self:get_size()
  self:get_bounds()
  self:get_centroid()
end


-- An equilateral triangle class. This is a tringle with size w centered on x, y pointed to the right (angle 0).
-- Implements every function that Polygon does.
EquilateralTriangle = Object:extend()
EquilateralTriangle:implement(Polygon)
function EquilateralTriangle:init(x, y, w)
  self.x, self.y, self.w = x, y, w
  local h = math.sqrt(math.pow(w, 2) - math.pow(w/2, 2))
  local x1, y1 = x + h/2, y
  local x2, y2 = x - h/2, y - w/2
  local x3, y3 = x - h/2, y + w/2
  self.vertices = {x1, y1, x2, y2, x3, y3}
  self:get_size()
  self:get_bounds()
  self:get_centroid()
end
