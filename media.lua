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
end

--[[
build your party: hire heroes, rank them up and defeat endless waves of enemies
make synergies: combine heroes of the same class to unlock unique class passives
find passive items: further enhance your party with powerful passive items
create your build: explore the possibilities and combinations to create your own unique build
]]--
