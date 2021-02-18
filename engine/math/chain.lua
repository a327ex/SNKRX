-- A chain class. If loop is true then this is the same as a polygon, otherwise its a collection of connected lines (an open polygon).
-- Implements every function that Polygon does.
Chain = Object:extend()
Chain:implement(Polygon)
function Chain:init(loop, vertices)
  self.loop = loop
  self.vertices = vertices
  self:get_size()
  self:get_bounds()
  self:get_centroid()
end


-- Draws the chain of lines with the given color and width.
function Chain:draw(color, line_width)
  if self.loop and not line_width then
    graphics.polygon(self.vertices, color, line_width)
  else
    for i = 1, #self.vertices-2, 2 do
      graphics.line(self.vertices[i], self.vertices[i+1], self.vertices[i+2], self.vertices[i+3], color, line_width)
      if self.loop and i == #self.vertices-2 then
        graphics.line(self.vertices[i], self.vertices[i+1], self.vertices[1], self.vertices[2], color, line_width)
      end
    end
  end
end


-- If loop is true, returns true if the point is inside the polygon.
-- If loop is false, returns true if the point lies on any of the chain's lines.
-- colliding = chain:is_colliding_with_point(x, y)
function Chain:is_colliding_with_point(x, y)
  if self.loop then
    return mlib.polygon.checkPoint(x, y, self.vertices)
  else
    for i = 1, #self.vertices-2, 2 do
      if mlib.segment.checkPoint(x, y, self.vertices[i], self.vertices[i+1], self.vertices[i+2], self.vertices[i+3]) then
        return true
      end
    end
  end
end


-- If loop is true, returns true if the line is colliding with the polygon.
-- If loop is false, returns true if the line is colliding with any of the chain's lines.
-- colliding = chain:is_colliding_with_line(line)
function Chain:is_colliding_with_line(line)
  if self.loop then
    return mlib.polygon.isSegmentInside(line.x1, line.y1, line.x2, line.y2, self.vertices)
  else
    for i = 1, #self.vertices-2, 2 do
      if mlib.segment.getIntersection(self.vertices[i], self.vertices[i+1], self.vertices[i+2], self.vertices[i+3], line.x1, line.y1, line.x2, line.y2) then
        return true
      end
    end
  end
end


-- If loop is true for both chains, returns true if the polygon is colliding with the polygon.
-- If loop is false for both chains, returns true if any of the lines of one chain are colliding with any of the lines of the other chain.
-- If one is true and the other is false, returns true if the one that's a polygon is colliding with any of the lines of the one that is a chain.
-- colliding = chain:is_colliding_with_chain(other_chain)
function Chain:is_colliding_with_chain(chain)
  if self.loop and chain.loop then
    return mlib.polygon.isPolygonInside(self.vertices, chain.vertices) or mlib.polygon.isPolygonInside(chain.vertices, self.vertices)
  elseif self.loop and not chain.loop then
    return chain:is_colliding_with_polygon(self)
  elseif not self.loop and chain.loop then
    return self:is_colliding_with_polygon(chain)
  else
    for i = 1, #self.vertices-2, 2 do
      for j = 1, #chain.vertices-2, 2 do
        if mlib.segment.getIntersection(self.vertices[i], self.vertices[i+1], self.vertices[i+2], self.vertices[i+3], chain.vertices[j], chain.vertices[j+1], chain.vertices[j+2], chain.vertices[j+3]) then
          return true
        end
      end
    end
  end
end


-- If loop is true, returns true if the circle is colliding with the polygon.
-- If loop is false, returns true if the circle is colliding with any of the chain's lines.
-- colliding = chain:is_colliding_with_circle(circle)
function Chain:is_colliding_with_circle(circle)
  if self.loop then
    return mlib.polygon.isCircleCompletelyInside(circle.x, circle.y, circle.rs, self.vertices) or
           mlib.circle.isPolygonCompletelyInside(circle.x, circle.y, circle.rs, self.vertices) or
           mlib.polygon.getCircleIntersection(circle.x, circle.y, circle.rs, self.vertices)
  else
    for i = 1, #self.vertices-2, 2 do
      if mlib.circle.getSegmentIntersection(circle.x, circle.y, circle.rs, self.vertices[i], self.vertices[i+1], self.vertices[i+2], self.vertices[i+3]) then
        return true
      end
    end
  end
end


-- If loop is true, returns true if the polygon is colliding with the polygon.
-- If loop is false, returns true if the polygon is colliding with any of the chain's lines.
-- colliding = chain:is_colliding_with_polygon(polygon)
function Chain:is_colliding_with_polygon(polygon)
  if self.loop then
    return mlib.polygon.isPolygonInside(self.vertices, polygon.vertices) or mlib.polygon.isPolygonInside(polygon.vertices, self.vertices)
  else
    for i = 1, #self.vertices-2, 2 do
      if mlib.polygon.getSegmentIntersection(self.vertices[i], self.vertices[i+1], self.vertices[i+2], self.vertices[i+3], polygon.vertices) then
        return true
      end
    end
  end
end
