-- A circle class.
Circle = Object:extend()
function Circle:init(x, y, rs)
  self.x, self.y = x, y
  self.rs = rs
  self.w, self.h = 2*self.rs, 2*self.rs
  self.x1, self.y1, self.x2, self.y2 = self.x - self.rs, self.y - self.rs, self.x + self.rs, self.y + self.rs
end


-- Draws the circle .
-- If color is passed in then the circle will be filled with that color (color is a Color instance)
-- If line_width is passed in then the circle will not be filled and will instead be drawn as a set of lines of the given width.
function Circle:draw(color, line_width)
  graphics.circle(self.x, self.y, self.rs, color, line_width)
end


-- Moves the circle directly to the given position.
-- circle:move_to(20, 20) -> moves the circle to position 20, 20
function Circle:move_to(x, y)
  self.x, self.y = x, y
end


-- Returns true if this polygon is colliding with the given shape.
-- colliding = polygon:is_colliding_with_shape(shape)
function Circle:is_colliding_with_shape(shape)
  if shape:is(Line) then
    return self:is_colliding_with_line(shape)
  elseif shape:is(Chain) then
    return self:is_colliding_with_chain(shape)
  elseif shape:is(Circle) then
    return self:is_colliding_with_circle(shape)
  elseif shape:is(Polygon) then
    return self:is_colliding_with_polygon(shape)
  elseif shape:is(Rectangle) then
    return self:is_colliding_with_polygon(shape)
  elseif shape:is(EmeraldRectangle) then
    return self:is_colliding_with_polygon(shape)
  elseif shape:is(Triangle) then
    return self:is_colliding_with_polygon(shape)
  elseif shape:is(EquilateralTriangle) then
    return self:is_colliding_with_polygon(shape)
  end
end


-- Returns true if the point is inside the circle.
-- colliding = polygon:is_colliding_with_point(x, y)
function Circle:is_colliding_with_point(x, y)
  return mlib.circle.checkPoint(x, y, self.x, self.y, self.rs)
end


-- Returns true if the line is colliding with this circle.
-- colliding = circle:is_colliding_with_line(line)
function Circle:is_colliding_with_line(line)
  return mlib.circle.getSegmentIntersection(self.x, self.y, self.rs, line.x1, line.y1, line.x2, line.y2)
end


-- Returns true if the chain is colliding with this circle.
-- colliding = circle:is_colliding_with_chain(chain)
function Circle:is_colliding_with_chain(chain)
  return chain:is_colliding_with_circle(self)
end


-- Returns true if the circle is colliding with this circle.
-- colliding = circle:is_colliding_with_circle(other_circle)
function Circle:is_colliding_with_circle(circle)
  return mlib.circle.isCircleCompletelyInside(self.x, self.y, self.rs, circle.x, circle.y, circle.rs) or
         mlib.circle.isCircleCompletelyInside(circle.x, circle.y, circle.rs, self.x, self.y, self.rs) or
         mlib.circle.getCircleIntersection(self.x, self.y, self.rs, circle.x, circle.y, circle.rs)
end


-- Returns true if the polygon is colliding with this circle.
-- colliding = circle:is_colliding_with_polygon(polygon)
function Circle:is_colliding_with_polygon(polygon)
  return mlib.polygon.isCircleCompletelyInside(self.x, self.y, self.rs, polygon.vertices) or
         mlib.circle.isPolygonCompletelyInside(self.x, self.y, self.rs, polygon.vertices) or
         mlib.polygon.getCircleIntersection(self.x, self.y, self.rs, polygon.vertices)
end
