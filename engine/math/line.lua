-- A line class.
-- Implements every function that Polygon does.
Line = Object:extend()
Line:implement(Polygon)
function Line:init(x1, y1, x2, y2)
  self.x1, self.y1, self.x2, self.y2 = x1, y1, x2, y2
  self.x, self.y = (self.x1 + self.x2)/2, (self.y1 + self.y2)/2
  self.vertices = {x1, y1, x2, y2}
  self:get_size()
  self:get_bounds()
  self:get_centroid()
end


-- Draws the line with the given color and width.
function Line:draw(color, line_width)
  graphics.line(self.x1, self.y1, self.x2, self.y2, color, line_width)
end


-- Noisifies the line, returning a Chain instance with the results.
-- offset corresponds to the maximum amount of perpendicular offseting each line will have
-- generations corresponds to the number of times the line will be subdivided
-- The higher the number of generations, the higher the number of final lines generates and the more granular the noisification will be
-- line:noisify(15, 4) -> noisifies the line with 15 maximum units of offseting with 4 generations
function Line:noisify(offset, generations)
  local lines = {}
  local generations = generations or 4
  local offset = offset or 8
  table.insert(lines, {x1 = self.x1, y1 = self.y1, x2 = self.x2, y2 = self.y2})

  for i = 1, generations do
    for i = #lines, 1, -1 do
      local spx, spy = lines[i].x1, lines[i].y1
      local epx, epy = lines[i].x2, lines[i].y2
      table.remove(lines, i)

      local mpx, mpy = (spx + epx)/2, (spy + epy)/2
      local pnx, pny = Vector(epx - spx, epy - spy):normalize():perpendicular():unpack()
      mpx = mpx + pnx*random:float(-offset, offset)
      mpy = mpy + pny*random:float(-offset, offset)
      table.insert(lines, i, {x1 = spx, y1 = spy, x2 = mpx, y2 = mpy})
      table.insert(lines, i+1, {x1 = mpx, y1 = mpy, x2 = epx, y2 = epy})
    end
    offset = offset/2
  end

  local vertices = {}
  for i, line in ipairs(lines) do
    if i == #lines then
      table.insert(vertices, line.x1)
      table.insert(vertices, line.y1)
      table.insert(vertices, line.x2)
      table.insert(vertices, line.y2)
    else
      table.insert(vertices, line.x1)
      table.insert(vertices, line.y1)
    end
  end
  return Chain(false, vertices)
end


-- Returns true if the point lies on the line.
-- colliding = line:is_colliding_with_point(x, y)
function Line:is_colliding_with_point(x, y)
  return mlib.segment.checkPoint(x, y, self.x1, self.y1, self.x2, self.y2)
end


-- Returns true if the line is colliding with this line.
-- colliding = line:is_colliding_with_line(other_line)
function Line:is_colliding_with_line(line)
  return mlib.segment.getIntersection(self.x1, self.y1, self.x2, self.y2, line.x1, line.y1, line.x2, line.y2)
end


-- Returns true if the chain is colliding with this line.
-- colliding = line:is_colliding_with_chain(chain)
function Line:is_colliding_with_chain(chain)
  return chain:is_colliding_with_line(self)
end


-- Returns true if the circle is colliding with this line.
-- colliding = line:is_colliding_with_circle(circle)
function Line:is_colliding_with_circle(circle)
  return mlib.circle.getSegmentIntersection(circle.x, circle.y, circle.rs, self.x1, self.y1, self.x2, self.y2)
end


-- Returns true if the polygon is colliding with this line .
-- colliding = line:is_colliding_with_polygon(polygon)
function Line:is_colliding_with_polygon(polygon)
  return mlib.polygon.getSegmentIntersection(self.x1, self.y1, self.x2, self.y2, polygon.vertices)
end
