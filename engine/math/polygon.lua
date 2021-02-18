-- A polygon class.
Polygon = Object:extend()
function Polygon:init(vertices)
  self.vertices = vertices
  self:get_size()
  self:get_bounds()
  self:get_centroid()
end


-- Draws the polygon.
-- If color is passed in then the polygon will be filled with that color (color is a Color instance)
-- If line_width is passed in then the polygon will not be filled and will instead be drawn as a set of lines of the given width.
function Polygon:draw(color, line_width)
  graphics.polygon(self.vertices, color, line_width)
end


-- Noisifies each line that makes up the polygon.
-- offset corresponds to the maximum amount of perpendicular offseting each line will have
-- generations corresponds to the number of times the line will be subdivided
-- The higher the number of generations, the higher the number of final lines generates and the more granular the noisification will be
-- polygon:noisify(15, 4) -> noisifies the polygon with 15 maximum units of offseting with 4 generations
function Polygon:noisify(offset, generations)
  local noisified_vertices = {}
  for i = 1, #self.vertices, 2 do
    local x1, y1 = vs[i], vs[i+1]
    local x2, y2 = vs[i+2], vs[i+3]
    if not x2 and not y2 then x2, y2 = vs[1], vs[2] end
    local noisified_line = math.noisify_line(x1, y1, x2, y2, offset, generations)
    table.insert(noisified_vertices, noisified_line)
  end
  local flattened = table.flatten(noisified_vertices)
  local final_vertices = {}
  for i = 1, #flattened, 2 do
    local x1, y1 = flattened[i], flattened[i+1]
    local x2, y2 = flattened[i+2], flattened[i+3]
    if not x2 and not y2 then x2, y2 = flattened[1], flattened[2] end
    if math.distance(x1, y1, x2, y2) > 0.025 then
      table.insert(final_vertices, x1)
      table.insert(final_vertices, y1)
    end
  end
  self.vertices = final_vertices
end


local path_to_polygon = function(path)
  local vs = {}
  for i = 1, path:size() do
    local p = path:get(i)
    table.insert(vs, tonumber(p.x))
    table.insert(vs, tonumber(p.y))
  end
  return vs
end


local polygon_to_path = function(vs)
  local path = clipper.Path()
  for i = 1, #vs, 2 do path:add(vs[i], vs[i+1]) end
  return path
end


-- Inflates the polygon around its center.
-- polygon:inflate(10) -> inflates the polygon by 10 units
function Polygon:inflate(s)
  self.vertices = path_to_polygon(clipper.ClipperOffset():offsetPath(polygon_to_path(self.vertices), s, 'miter', 'closedPolygon'):get(1))
end


-- Moves the polygon directly to the given position.
-- polygon:move_to(20, 20) -> moves the polygon to position 20, 20
function Polygon:move_to(x, y)
  if self.x and self.y then self:translate(x - self.x, y - self.y) end
  self.x, self.y = x, y
end


-- Translates the polygon by the given amount.
-- polygon:translate(20, 20) -> moves the polygon by 20, 20 units
function Polygon:translate(x, y)
  for i = 1, #self.vertices, 2 do
    self.vertices[i] = self.vertices[i] + x
    self.vertices[i+1] = self.vertices[i+1] + y
  end
end


-- Scales the polygon by the given amount around the given pivot.
-- polygon:scale(2) -> scales the polygon by 2 around its center (if set) or 0
function Polygon:scale(sx, sy, ox, oy)
  for i = 1, #self.vertices, 2 do
    self.vertices[i], self.vertices[i+1] = math.scale_point(self.vertices[i], self.vertices[i+1], sx or 1, sy or sx or 1, ox or self.cx or 0, oy or self.cy or 0)
  end
end


-- Rotates the polygon by the given amount around the given pivot.
-- polygon:rotate(math.pi/4) -> rotates the polygon by 45 degrees around its center (if set) or 0
function Polygon:rotate(r, ox, oy)
  for i = 1, #self.vertices, 2 do
    self.vertices[i], self.vertices[i+1] = math.rotate_point(self.vertices[i], self.vertices[i+1], r, ox or self.cx or 0, oy or self.cy or 0)
  end
end


-- Returns the polygons size.
-- This calculates the bounding box of the polygon and sets that size to the .w, .h attributes.
-- w, h = polygon:get_size()
function Polygon:get_size()
  local min_x, min_y, max_x, max_y = 1000000, 1000000, -1000000, -1000000
  for i = 1, #self.vertices, 2 do
    if self.vertices[i] < min_x then min_x = self.vertices[i] end
    if self.vertices[i] > max_x then max_x = self.vertices[i] end
    if self.vertices[i+1] < min_y then min_y = self.vertices[i+1] end
    if self.vertices[i+1] > max_y then max_y = self.vertices[i+1] end
  end
  self.w, self.h = math.abs(max_x - min_x), math.abs(max_y - min_y)
  return self.w, self.h
end


-- Returns the polygons bounding box top-left and bottom-right positions.
-- This calculates the bounding box of the polygon and sets those positions to the .x1, .y1, .x2, .y2 attributes.
-- x1, y1, x2, y2 = polygon:get_bounds()
function Polygon:get_bounds()
  local min_x, min_y, max_x, max_y = 1000000, 1000000, -1000000, -1000000
  for i = 1, #self.vertices, 2 do
    if self.vertices[i] < min_x then min_x = self.vertices[i] end
    if self.vertices[i] > max_x then max_x = self.vertices[i] end
    if self.vertices[i+1] < min_y then min_y = self.vertices[i+1] end
    if self.vertices[i+1] > max_y then max_y = self.vertices[i+1] end
  end
  self.x1, self.y1, self.x2, self.y2 = min_x, min_y, max_x, max_y
  return self.x1, self.y1, self.x2, self.y2
end


-- Returns the centroid of the polygon.
-- This calculates the centroid (average of all points) and sets it to the .x, .y attributes.
-- x, y = polygon:get_centroid()
-- TODO: implement get_visual_center https://github.com/mapbox/polylabel/blob/master/polylabel.js
function Polygon:get_centroid()
  local sum_x, sum_y = 0, 0
  for i = 1, #self.vertices, 2 do
    sum_x = sum_x + self.vertices[i]
    sum_y = sum_y + self.vertices[i+1]
  end
  self.cx, self.cy = sum_x/(#self.vertices/2), sum_y/(#self.vertices/2)
  return self.cx, self.cy
end


-- Returns true if this polygon is colliding with the given shape.
-- colliding = polygon:is_colliding_with_shape(shape)
function Polygon:is_colliding_with_shape(shape)
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


-- Returns true if the point is inside the polygon.
-- colliding = polygon:is_colliding_with_point(x, y)
function Polygon:is_colliding_with_point(x, y)
  return mlib.polygon.checkPoint(x, y, self.vertices)
end


-- Returns true if the line is colliding with this polygon.
-- colliding = polygon:is_colliding_with_line(line)
function Polygon:is_colliding_with_line(line)
  return mlib.polygon.isSegmentInside(line.x1, line.y1, line.x2, line.y2, self.vertices)
end


-- Returns true if the chain is colliding with this polygon.
-- colliding = polygon:is_colliding_with_chain(chain)
function Polygon:is_colliding_with_chain(chain)
  return chain:is_colliding_with_polygon(self)
end


-- Returns true if the circle is colliding with this circle.
-- colliding = polygon:is_colliding_with_circle(circle)
function Polygon:is_colliding_with_circle(circle)
  return mlib.polygon.isCircleCompletelyInside(circle.x, circle.y, circle.rs, self.vertices) or
         mlib.circle.isPolygonCompletelyInside(circle.x, circle.y, circle.rs, self.vertices) or
         mlib.polygon.getCircleIntersection(circle.x, circle.y, circle.rs, self.vertices)
end


-- Returns true if the polygon is colliding with this polygon.
-- colliding = polygon:is_colliding_with_polygon(other_polygon)
function Polygon:is_colliding_with_polygon(polygon)
  return mlib.polygon.isPolygonInside(self.vertices, polygon.vertices) or mlib.polygon.isPolygonInside(polygon.vertices, self.vertices)
end


-- Returned results can be either the merged polygons or the holes inside them (or a polygon inside a hole, or a hole inside that polygon, and so on...)
-- Unfortunately for now it doesn't really report which polygons are which, so this function has some limited utility.
function Polygon.merge_polygons(polygons)
  local cl = clipper.Clipper()
  local paths = clipper.Paths()
  for _, polygon in ipairs(polygons) do paths:add(polygon_to_path(polygon.vertices)) end
  cl:addPaths(paths, 'subject')
  local out = cl:execute('union')
  local out_polygons = {}
  for i = 1, out:size() do table.insert(out_polygons, path_to_polygon(out:get(i))) end
  return out_polygons
end
