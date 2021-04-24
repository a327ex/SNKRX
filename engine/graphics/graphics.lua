graphics = {}
graphics.debug_queries = {}
graphics.debug_draw = false


-- All operations after this is called will be affected by the transform.
function graphics.push(x, y, r, sx, sy)
  love.graphics.push()
  love.graphics.translate(x or 0, y or 0)
  love.graphics.scale(sx or 1, sy or sx or 1)
  love.graphics.rotate(r or 0)
  love.graphics.translate(-x or 0, -y or 0)
end


-- All operations after this is called will not be affected by the transform set with graphics.push.
function graphics.pop()
  love.graphics.pop()
end


function graphics.translate(x, y)
  love.graphics.translate(x or 0, y or 0)
end


function graphics.rotate(r)
  love.graphics.rotate(r or 0)
end


function graphics.scale(sx, sy)
  love.graphics.scale(sx or 1, sy or sx or 1)
end


function graphics.update(dt)
  for i = #self.debug_queries, 1, -1 do
    local query = self.debug_queries[i]
    query.frames = query.frames - 1
    if query.frames <= 0 then table.remove(self.debug_queries, i) end
  end
end


-- Adds a polygon to be drawn to the screen for a few frames. Useful when debugging visual shapes.
function graphics.add_polygon_debug_query(vertices, frames)
  table.insert(self.debug_queries, {vertices = vertices, frames = frames, type = "polygon"})
end


function graphics.draw_debug_queries()
  for _, query in ipairs(self.debug_queries) do
    if query.type == "polygon" then
      self:polygon(query.vertices)
    end
  end
end


-- Prints text to the screen, alternative to using a Text object.
function graphics.print(text, font, x, y, r, sx, sy, ox, oy, color)
  local _r, g, b, a = love.graphics.getColor()
  if color then love.graphics.setColor(color.r, color.g, color.b, color.a) end
  love.graphics.print(text, font.font, x, y, r or 0, sx or 1, sy or 1, ox or 0, oy or 0)
  if color then love.graphics.setColor(_r, g, b, a) end
end


-- Prints text to the screen centered on x, y, alternative to using a Text object.
function graphics.print_centered(text, font, x, y, r, sx, sy, ox, oy, color)
  local _r, g, b, a = love.graphics.getColor()
  if color then love.graphics.setColor(color.r, color.g, color.b, color.a) end
  love.graphics.print(text, font.font, x, y, r or 0, sx or 1, sy or 1, (ox or 0) + font:get_text_width(text)/2, (oy or 0) + font.h/2)
  if color then love.graphics.setColor(_r, g, b, a) end
end


function graphics.shape(shape, color, line_width, ...)
  local r, g, b, a = love.graphics.getColor()
  if not color and not line_width then love.graphics[shape]("line", ...)
  elseif color and not line_width then
    love.graphics.setColor(color.r, color.g, color.b, color.a)
    love.graphics[shape]("fill", ...)
  else
    if color then love.graphics.setColor(color.r, color.g, color.b, color.a) end
    love.graphics.setLineWidth(line_width)
    love.graphics[shape]("line", ...)
    love.graphics.setLineWidth(1)
  end
  love.graphics.setColor(r, g, b, a)
end


-- Draws a rectangle of size w, h centered on x, y.
-- If rx, ry are passed in, then the rectangle will have rounded corners with radius of that size.
-- If color is passed in then the rectangle will be filled with that color (color is Color object)
-- If line_width is passed in then the rectangle will not be filled and will instead be drawn as a set of lines of the given width.
function graphics.rectangle(x, y, w, h, rx, ry, color, line_width)
  graphics.shape("rectangle", color, line_width, x - w/2, y - h/2, w, h, rx, ry)
end


-- Draws a rectangle of size w, h centered on x - w/2, y - h/2.
-- If rx, ry are passed in, then the rectangle will have rounded corners with radius of that size.
-- If color is passed in then the rectangle will be filled with that color (color is Color object)
-- If line_width is passed in then the rectangle will not be filled and will instead be drawn as a set of lines of the given width.
function graphics.rectangle2(x, y, w, h, rx, ry, color, line_width)
  graphics.shape("rectangle", color, line_width, x, y, w, h, rx, ry)
end


-- Draws a dashed rectangle of size w, h centerd on x, y.
-- dash_size and gap_size correspond to the dimensions of the dashing behavior.
function graphics.dashed_rectangle(x, y, w, h, dash_size, gap_size, color, line_width)
  graphics.dashed_line(x - w/2, y - h/2, x + w/2, y - h/2, dash_size, gap_size, color, line_width)
  graphics.dashed_line(x - w/2, y - h/2, x - w/2, y + h/2, dash_size, gap_size, color, line_width)
  graphics.dashed_line(x - w/2, y + h/2, x + w/2, y + h/2, dash_size, gap_size, color, line_width)
  graphics.dashed_line(x + w/2, y - h/2, x + w/2, y + h/2, dash_size, gap_size, color, line_width)
end


-- Draws an isosceles triangle with size w, h centered on x, y pointed to the right (angle 0).
-- If color is passed in then the triangle will be filled with that color (color is Color object)
-- If line_width is passed in then the triangle will not be filled and will instead be drawn as a set of lines of the given width.
function graphics.triangle(x, y, w, h, color, line_width)
  local x1, y1 = x + h/2, y
  local x2, y2 = x - h/2, y - w/2
  local x3, y3 = x - h/2, y + w/2
  graphics.polygon({x1, y1, x2, y2, x3, y3}, color, line_width)
end


-- Draws an equilateral triangle with size w centered on x, y pointed to the right (angle 0).
-- If color is passed in then the triangle will be filled with that color (color is Color object)
-- If line_width is passed in then the triangle will not be filled and will instead be drawn as a set of lines of the given width.
function graphics.triangle_equilateral(x, y, w, color, line_width)
  local h = math.sqrt(math.pow(w, 2) - math.pow(w/2, 2))
  graphics.triangle(x, y, w, h, color, line_width)
end


-- Draws a circle of radius r centered on x, y.
-- If color is passed in then the circle will be filled with that color (color is Color object)
-- If line_width is passed in then the circle will not be filled and will instead be drawn as a set of lines of the given width.
function graphics.circle(x, y, r, color, line_width)
  graphics.shape("circle", color, line_width, x, y, r)
end


-- Draws an arc of radius r from angle r1 to angle r2 centered on x, y.
-- If color is passed in then the arc will be filled with that color (color is Color object)
-- If line_width is passed in then the arc will not be filled and will instead be drawn as a set of lines of the given width.
function graphics.arc(arctype, x, y, r, r1, r2, color, line_width)
  graphics.shape("arc", color, line_width, arctype, x, y, r, r1, r2)
end


-- Draws a polygon with the given points.
-- If color is passed in then the polygon will be filled with that color (color is Color object)
-- If line_width is passed in then the polygon will not be filled and will instead be drawn as a set of lines of the given width.
function graphics.polygon(vertices, color, line_width)
  graphics.shape("polygon", color, line_width, vertices)
end


-- Draws a line with the given points.
function graphics.line(x1, y1, x2, y2, color, line_width)
  local r, g, b, a = love.graphics.getColor()
  if color then love.graphics.setColor(color.r, color.g, color.b, color.a) end
  if line_width then love.graphics.setLineWidth(line_width) end
  love.graphics.line(x1, y1, x2, y2)
  love.graphics.setColor(r, g, b, a)
  love.graphics.setLineWidth(1)
end


function graphics.polyline(color, line_width, ...)
  local r, g, b, a = love.graphics.getColor()
  if color then love.graphics.setColor(color.r, color.g, color.b, color.a) end
  if line_width then love.graphics.setLineWidth(line_width) end
  love.graphics.line(...)
  love.graphics.setColor(r, g, b, a)
  love.graphics.setLineWidth(1)
end


-- Draws a line with rounded ends with the given points.
-- If color is passed in then the line will be filled with that color (color is Color object)
-- If line_width is passed in then the line will not be filled and will instead be drawn as a set of lines of the given width.
function graphics.rounded_line(x1, y1, x2, y2, color, line_width)
  love.graphics.push()
  love.graphics.translate(x1, y1)
  love.graphics.rotate(math.angle(x1, y1, x2, y2))
  love.graphics.translate(-x1, -y1)
  graphics.rectangle(x1, y1 - line_width/4, math.length(x2-x1, y2-y1), line_width/2, line_width/4, line_width/4, color)
  love.graphics.pop()
end


-- Draws a dashed line with the given points.
-- dash_size and gap_size correspond to the dimensions of the dashing behavior.
-- If color is passed in then the lines will be filled with that color (color is Color object)
-- If line_width is passed in then the lines will not be filled and will instead be drawn as a set of lines of the given width.
function graphics.dashed_line(x1, y1, x2, y2, dash_size, gap_size, color, line_width)
  local r, g, b, a = love.graphics.getColor()
  if color then love.graphics.setColor(color.r, color.g, color.b, color.a) end
  if line_width then love.graphics.setLineWidth(line_width) end
  local dx, dy = x2-x1, y2-y1
  local an, st = math.atan2(dy, dx), dash_size + gap_size
  local len = math.sqrt(dx*dx + dy*dy)
  local nm = (len-dash_size)/st
  love.graphics.push()
    love.graphics.translate(x1, y1)
    love.graphics.rotate(an)
    for i = 0, nm do love.graphics.line(i*st, 0, i*st + dash_size, 0) end
    love.graphics.line(nm*st, 0, nm*st + dash_size, 0)
  love.graphics.pop()
end


-- Draws a dashed line with rounded ends with the given points.
-- dash_size and gap_size correspond to the dimensions of the dashing behavior.
-- If color is passed in then the lines will be filled with that color (color is Color object)
-- If line_width is passed in then the lines will not be filled and will instead be drawn as a set of lines of the given width.
function graphics.dashed_rounded_line(x1, y1, x2, y2, dash_size, gap_size, color, line_width)
  if color then love.graphics.setColor(color.r, color.g, color.b, color.a) end
  if line_width then love.graphics.setLineWidth(line_width) end
  local dx, dy = x2-x1, y2-y1
  local an, st = math.atan2(dy, dx), dash_size + gap_size
  local len = math.sqrt(dx*dx + dy*dy)
  local nm = (len-dash_size)/st
  love.graphics.push()
    love.graphics.translate(x1, y1)
    love.graphics.rotate(an)
    for i = 0, nm do
      love.graphics.push()
      love.graphics.translate(i*st, 0)
      love.graphics.rotate(math.angle(i*st, 0, i*st + dash_size, 0))
      love.graphics.translate(-i*st, -0)
      graphics.shape("rectangle", color, nil, i*st, 0, math.length((i*st + dash_size)-(i*st), 0-0), line_width/2, line_width/4, line_width/4)
      love.graphics.pop()
    end
    love.graphics.push()
    love.graphics.translate(nm*st, 0)
    love.graphics.rotate(math.angle(nm*st, 0, nm*st + dash_size, 0))
    love.graphics.translate(-nm*st, -0)
    graphics.shape("rectangle", color, nil, nm*st, 0, math.length((nm*st + dash_size)-(nm*st), 0-0), line_width/2, line_width/4, line_width/4)
    love.graphics.pop()
  love.graphics.pop()
end


-- Draws an ellipse with radius rx, ry centered on x, y.
-- If color is passed in then the ellipse will be filled with that color (color is Color object)
-- If line_width is passed in then the ellipse will not be filled and will instead be drawn as a set of lines of the given width.
function graphics.ellipse(x, y, rx, ry, color, line_width)
  graphics.shape("ellipse", color, line_width, x, y, rx, ry)
end


-- Sets the currently active shader, the passed in argument should be a Shader object.
function graphics.set_shader(shader)
  if not shader then love.graphics.setShader()
  else love.graphics.setShader(shader.shader) end
end


-- Sets the currently active color, the passed in argument should be a Color object.
function graphics.set_color(color)
  love.graphics.setColor(color.r, color.g, color.b, color.a)
end


-- Sets the currently active background color, the passed in argument should be a Color object.
function graphics.set_background_color(color)
  love.graphics.setBackgroundColor(color.r, color.g, color.b, color.a)
end


function graphics.set_line_width(line_width)
  love.graphics.setLineWidth(line_width)
end


-- Sets the line style, possible values are 'rough' and 'smooth'.
function graphics.set_line_style(style)
  love.graphics.setLineStyle(style)
end


-- Sets the default filter mode, possible values are 'nearest' and 'linear'.
function graphics.set_default_filter(min, max)
  love.graphics.setDefaultFilter(min, max)
end


function graphics.set_mouse_visible(value)
  love.mouse.setVisible(value)
end


function graphics.stencil(...)
  love.graphics.stencil(...)
end


function graphics.set_stencil_test(...)
  love.graphics.setStencilTest(...)
end


-- Draws the image masked by a shape, meaning that only parts inside (or outside) the shape that intersects the image are drawn.
-- By default only parts that intersect with the shape are drawn, pass the third argument as true to make it so that only parts that don't intersect are drawn.
-- action is a function that draws the image.
-- mask_action is a function that draws the shape.
function graphics.draw_with_mask(action, mask_action, invert_mask)
  graphics.stencil(function() mask_action() end)
  if not invert_mask then graphics.set_stencil_test('greater', 0)
  else graphics.set_stencil_test('notequal', 1) end
  action()
  graphics.set_stencil_test()
end


local stencil_mask_shader = love.graphics.newShader[[
vec4 effect(vec4 color, Image texture, vec2 tc, vec2 pc) {
  vec4 t = Texel(texture, tc);
  if (t.a == 0.0) {
    discard;
  }
  return t;
}
]]

-- Draws the second image on top of the first, but only the portions of the second image that aren't transparent are drawn.
-- This essentially applies the second image as a texture on top of the shape of the first.
-- action1 and action2 are functions that draw the images.
-- graphics.draw_intersection(function() player_image:draw(player.x, player.y) end, function() gradient_image:draw(player.x, player.y) end) -> draws the player with a gradient applied to it
function graphics.draw_intersection(action1, action2)
  graphics.stencil(function() love.graphics.setShader(stencil_mask_shader); action1(); love.graphics.setShader() end, 'replace', 1)
  graphics.set_stencil_test('greater', 0)
  action2()
  graphics.set_stencil_test()
end


-- A very specific function to be used with rtfx.bat to generated RTFX animations.
-- This is not very useful in contexts other than this very specific thing, so it should probably not be here.
-- TODO: some kind of plugin system for functions like these that are very specific and not generalizable but still useful.
function graphics.generate_rtfx_animation(w, h)
  local files = system.enumerate_files("assets/frames")
  if #files <= 0 then return end
  local frames = {}
  for _, file in ipairs(files) do table.insert(frames, love.image.newImageData(file)) end

  local out_frames = {}
  local idw, idh = frames[1]:getDimensions()
  local tw, th = w or 4, h or 4
  local ow, oh = idw/tw, idh/th

  for k = 1, #frames do
    local image_data = frames[k]
    local out_image_data = love.image.newImageData(ow, oh)
    for i = 1, image_data:getWidth(), tw do
      for j = 1, image_data:getHeight(), th do
        local yes_or_no = {}
        for x = 0, tw-1 do
          for y = 0, th-1 do
            local r, g, b, a = image_data:getPixel(i+x-1, j+y-1)
            -- if r >= 0.01 and g >= 0.01 and b >= 0.01 then table.insert(yes_or_no, 1) end
            if a >= 0.5 then table.insert(yes_or_no, 1) end
          end
        end
        if #yes_or_no >= (tw*th)/2 then
          out_image_data:setPixel(math.floor((i-1)/tw), math.floor((j-1)/th), 1, 1, 1, 1)
        end
      end
    end
    table.insert(out_frames, out_image_data)
  end

  local spritesheet_data = love.image.newImageData(ow*#out_frames, oh)
  for k = 1, #out_frames do
    for i = 0, out_frames[k]:getWidth()-1 do
      for j = 0, out_frames[k]:getHeight()-1 do
        spritesheet_data:setPixel(i + (k-1)*ow, j, out_frames[k]:getPixel(i, j))
      end
    end
  end
  spritesheet_data:encode("png", "anim.png")
end
