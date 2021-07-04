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

  graphics.set_background_color(blue[0])
  Text2{group = self.ui, x = gw/2, y = gh/2, lines = {
    {text = '[fg]SNKRX', font = fat_font, alignment = 'center', height_offset = -15},
    {text = '[fg]loop update', font = pixul_font, alignment = 'center'},
  }}
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

  mercenary:draw(30, 30, 0, 1, 1, 0, 0, yellow2[-5])
end
