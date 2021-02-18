-- The class responsible for loading and drawing tilesets.
-- This is primarily used by the Tilemap class.
Tileset = Object:extend()
function Tileset:init(image, tile_w, tile_h)
  self.image = image
  self.tile_w, self.tile_h = tile_w, tile_h
  self.grid = Grid(math.floor(self.image.w/self.tile_w), math.floor(self.image.h/self.tile_h), 0)
  self.w, self.h = self.grid.w, self.grid.h
  for i = 1, self.grid.w do
    for j = 1, self.grid.h do
      self.grid:set(i, j, love.graphics.newQuad((i-1)*self.tile_w, (j-1)*self.tile_h, self.tile_w, self.tile_h, self.image.w, self.image.h))
    end
  end
end


-- Draws a tile based on its tileset 1D index.
-- If the tileset has width 10 (10 columns) then the index 11 corresponds to the first tile in the second row.
function Tileset:draw_tile(index, x, y, r, sx, sy, ox, oy)
  love.graphics.draw(self.image.image, self:get_quad(index), x, y, r or 0, sx or 1, sy or sx or 1, ox or 0, oy or 0)
end


-- Returns the quad that represents the tile at the given index.
function Tileset:get_quad(index)
  return self.grid:get(math.index_to_coordinates(index, self.w))
end
