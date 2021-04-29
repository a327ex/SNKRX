Media = Object:extend()
Media:implement(State)
function Media:init(name)
  self:init_state(name)
end


function Media:on_enter(from)
  camera.x, camera.y = gw/2, gh/2
  self.main = Group()
  self.effects = Group()
  self.ui = Group()

  self.mode = 'achievements'
  graphics.set_background_color(fg[0])
end


function Media:update(dt)
  self.main:update(dt*slow_amount)
  self.effects:update(dt*slow_amount)
  self.ui:update(dt*slow_amount)
end


function Media:draw()
  self.main:draw()
  self.effects:draw()
  self.ui:draw()

  if self.mode == 'achievements' then
    graphics.print_centered('GG', fat_font, 32, 32, 0, 1, 1, 0, 0, fg[-5])
  end
end
