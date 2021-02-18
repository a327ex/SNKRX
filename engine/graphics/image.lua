-- The base Image class.
Image = Object:extend()
function Image:init(asset_name)
  self.image = love.graphics.newImage("assets/images/" .. asset_name .. ".png")
  self.w = self.image:getWidth()
  self.h = self.image:getHeight()
end


function Image:draw(x, y, r, sx, sy, ox, oy, color)
  local _r, g, b, a
  if color then
    _r, g, b, a = love.graphics.getColor()
    graphics.set_color(color)
  end
  love.graphics.draw(self.image, x, y, r or 0, sx or 1, sy or sx or 1, self.w/2 + (ox or 0), self.h/2 + (oy or 0))
  if color then love.graphics.setColor(_r, g, b, a) end
end




-- The base Quad class. Useful for loading pieces of images as independent Image objects. Every function that takes in an Image also takes in a Quad.
Quad = Object:extend()
function Quad:init(image, tile_w, tile_h, tile_coordinates)
  self.image = image
  self.quad = love.graphics.newQuad((tile_coordinates[1]-1)*tile_w, (tile_coordinates[2]-1)*tile_h, tile_w, tile_h, self.image.w, self.image.h)
  self.w, self.h = tile_w, tile_h
end


function Quad:draw(x, y, r, sx, sy, ox, oy)
  love.graphics.draw(self.image.image, self.quad, x, y, r or 0, sx or 1, sy or sx or 1, self.w/2 + (ox or 0), self.h/2 + (oy or 0))
end





-- A linear gradient image.
-- The first argument is the direction of the gradient and can be either 'horizontal' or 'vertical'.
GradientImage = Object:extend()
function GradientImage:init(direction, ...)
  local colors = {...}
  local mesh_data = {}

  if direction == "horizontal" then
    for i = 1, #colors do
      local color = colors[i]
      local x = (i-1)/(#colors-1)
      table.insert(mesh_data, {x, 1, x, 1, color.r, color.g, color.b, color.a or 1})
      table.insert(mesh_data, {x, 0, x, 0, color.r, color.g, color.b, color.a or 1})
    end
  elseif direction == "vertical" then
    for i = 1, #colors do
      local color = colors[i]
      local y = (i-1)/(#colors-1)
      table.insert(mesh_data, {1, y, 1, y, color.r, color.g, color.b, color.a or 1})
      table.insert(mesh_data, {0, y, 0, y, color.r, color.g, color.b, color.a or 1})
    end
  end

  self.mesh = love.graphics.newMesh(mesh_data, "strip", "static")
end


-- Draws the gradient image with size w, h centered on x, y.
function GradientImage:draw(x, y, w, h, r, sx, sy, ox, oy)
  graphics.push(x, y, r)
  love.graphics.draw(self.mesh, x - (sx or 1)*(w + (ox or 0))/2, y - (sy or 1)*(h + (oy or 0))/2, 0, w*(sx or 1), h*(sy or sx or 1))
  graphics.pop()
end
