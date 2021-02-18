-- The base Font class.
Font = Object:extend()
function Font:init(asset_name, font_size)
  self.font = love.graphics.newFont("assets/fonts/" .. asset_name .. ".ttf", font_size)
  self.h = self.font:getHeight()
end


function Font:get_text_width(text)
  return self.font:getWidth(text)
end


function Font:get_height()
  return self.font:getHeight()
end
