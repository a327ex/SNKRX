-- A tilemap class responsible for the loading and drawing of maps made of tiles.
-- The x, y coordinates passed in represent the center of the map.
-- A tileset object containing the tileset to be used by the map must be passed in, as well as a grid object containing the map itself.
-- If tile_rules is also passed in, then the grid instance must contain its values in relation to what the tiling rules expect.
-- If no tiling rules are present then the grid will contain the 1D index of each tile in the tileset, so if the tileset has 5 columns, the first element in the second row will be numbered 6 in the grid.
-- If solid_rules is passed in, then the that function should receive a tile index and return true on those that are supposed to form a solid object, for instance:
-- function(index) return index ~= 0 end would make every tile index that isn't 0 into a solid object.
-- The created solids are stored in .solids after the tilemap instance is created. They should be added to the same group that you want gameplay objects to collide with the map's solid walls.
-- Solids are evaluated before tile rules are applied to the tile grid.
Tilemap = Object:extend()
function Tilemap:init(x, y, tileset, tile_grid, tile_rules, solid_rules)
  self.tileset = tileset
  self.grid = tile_grid
  self.x, self.y = x, y
  self.w, self.h = self.grid.w*self.tileset.tile_w, self.grid.h*self.tileset.tile_h
  self.tile_rules = tile_rules
  self.solid_rules = solid_rules

  -- Create solids from the tile grid
  local tw, th = self.tileset.tile_w, self.tileset.tile_h
  if self.solid_rules then
    local ox, oy = self.x - self.w/2, self.y - self.h/2
    local tile_polygons = {}
    for i = 1, self.grid.w do
      for j = 1, self.grid.h do
        if self.solid_rules(self.grid:get(i, j)) then
          table.insert(tile_polygons, Polygon({ox + (i-1)*tw, oy + (j-1)*th, ox + i*tw, oy + (j-1)*th, ox + i*tw, oy + j*th, ox + (i-1)*tw, oy + j*th}))
        end
      end
    end
    self.solids_vertices = {}
    for _, solid in ipairs(Polygon.merge_polygons(tile_polygons)) do
      table.insert(self.solids_vertices, solid)
    end
  end

  if self.tile_rules:is(TilekitRules) then
    self.grid = Grid(self.grid.w, self.grid.h, self.tile_rules.process({w = self.grid.w, h = self.grid.h, data = self.grid.grid}).data)
  end

  -- Create spritebatch
  self.spritebatch = love.graphics.newSpriteBatch(self.tileset.image.image, 8192, 'static')
  for i = 1, self.grid.w do
    for j = 1, self.grid.h do
      local v = self.grid:get(i, j)
      if v ~= 0 then
        self.spritebatch:add(self.tileset:get_quad(v), (i-1)*tw, (j-1)*th)
      end
    end
  end
end


function Tilemap:draw(r, sx, sy, ox, oy)
  love.graphics.draw(self.spritebatch, self.x - self.w/2, self.y - self.h/2, r or 0, sx or 1, sy or sx or 1, ox or 0, oy or 0)
end




-- This class is responsible for loading tile rules exported by rxi's Tilekit https://rxi.itch.io/tilekit
-- An instance of this class should be passed in as the third argument for a Tilemap instance
TilekitRules = Object:extend()
function TilekitRules:init(rules_filename)
  self.process = require('assets/maps/' .. rules_filename)
end
