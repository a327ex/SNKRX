-- A canvas object for offscreen rendering.
Canvas = Object:extend()
function Canvas:init(w, h, opts)
  local opts = opts or {}
  self.w, self.h = w, h
  self.canvas = love.graphics.newCanvas(self.w, self.h, {msaa = opts.msaa})
  self.stencil = opts.stencil
end


-- Draws the canvas to the screen.
--[[
function init()
  canvas = Canvas(gw, gh)
end

function draw()
  canvas:draw_to(function()
    -- draw your game
  end)
  canvas:draw(0, 0, 0, sx, sy)
end
]]--
function Canvas:draw(x, y, r, sx, sy, ox, oy)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setBlendMode("alpha", "premultiplied")
  love.graphics.draw(self.canvas, x or 0, y or 0, r or 0, sx or 1, sy or 1, ox or 0, oy or 0)
  love.graphics.setBlendMode("alpha")
end


function Canvas:draw2(x, y, r, sx, sy, ox, oy)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.canvas, x or 0, y or 0, r or 0, sx or 1, sy or 1, ox or 0, oy or 0)
end


-- Takes in a function and uses it to draw to this canvas.
-- canvas:draw_to(function()
--   graphics.rectangle(gw/2, gh/2, 50, 50)
-- end)
function Canvas:draw_to(action)
  love.graphics.setCanvas({self.canvas, stencil = self.stencil})
  love.graphics.clear()
  action()
  love.graphics.setCanvas()
end


-- Sets this canvas as the active one.
function Canvas:set()
  current_canvas = self
  love.graphics.setCanvas(self.canvas)
end


-- Unsets this canvas as the active one.
function Canvas:unset()
  current_canvas = nil
  love.graphics.setCanvas()
end


-- Clears this canvas' buffer.
function Canvas:clear()
  love.graphics.clear()
end
